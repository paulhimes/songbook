//
//  SongPageController.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongPageController.h"
#import "SongTitleView.h"
#import "BookCodec.h"
#import "Section+Helpers.h"
#import "Song+Helpers.h"

@import AVFoundation;

static const float kTextScaleThreshold = 1;
static const NSTimeInterval kPlayerAnimationDuration = 0.5;

@interface SongPageController () <UITextViewDelegate, UIToolbarDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate, AVAudioPlayerDelegate>

@property (nonatomic, readonly) Song *song;

@property (nonatomic, strong) NSArray *relatedSongs;

@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet SafeTextView *textView;
@property (weak, nonatomic) IBOutlet SongTitleView *titleView;

@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

//@property (nonatomic, strong) UITableView *relatedItemsView;

@property (nonatomic, strong) NSNumber *gestureStartTextSize;
@property (nonatomic) NSUInteger glyphIndex;
@property (nonatomic) CGFloat glyphOriginalYCoordinateInMainView;
@property (nonatomic) CGFloat glyphYCoordinateInMainView;
@property (nonatomic) CGPoint touchStartPoint;
@property (nonatomic) CGPoint latestTouchPoint;

// Caching for speed optimization.
@property (nonatomic, strong) NSParagraphStyle *numberAndTitleParagraphStyle;
@property (nonatomic, strong) NSParagraphStyle *subtitleParagraphStyle;
@property (nonatomic, strong) NSDictionary *songComponentRanges;

@end

@implementation SongPageController

//- (void)setSong:(Song *)song
//{
//    _song = song;
//    
//    self.relatedSongs = [self.song.relatedSongs allObjects];
//}

- (NSParagraphStyle *)numberAndTitleParagraphStyle
{
    if (!_numberAndTitleParagraphStyle) {
        _numberAndTitleParagraphStyle = [self paragraphStyleFirstLineIndent:0
                                                            andNormalIndent:self.titleView.titleOriginX];
    }
    return _numberAndTitleParagraphStyle;
}

- (NSParagraphStyle *)subtitleParagraphStyle
{
    if (!_subtitleParagraphStyle) {
        _subtitleParagraphStyle = [self paragraphStyleFirstLineIndent:self.titleView.titleOriginX
                                                      andNormalIndent:self.titleView.titleOriginX];
    }
    return _subtitleParagraphStyle;
}

- (NSDictionary *)songComponentRanges
{
    if (!_songComponentRanges) {
        _songComponentRanges = [self.song stringComponentRanges];
    }
    return _songComponentRanges;
}

- (void)viewDidLoad
{
//    [self.relatedItemsView setHeight:self.relatedItemsView.contentHeight];
//    [self.textView addSubview:self.relatedItemsView];
    
    self.titleView.number = self.song.number;
    self.titleView.title = self.song.title;
    
    CGFloat titleContentOriginY = self.titleView.contentOriginY;
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 44, 0);
    
    self.topBar.delegate = self;
    self.bottomBar.delegate = self;
    
    self.playerView.backgroundColor = [Theme paperColor];

    [super viewDidLoad];
    
    self.textView.contentOffsetCallsAllowed = NO;
    
    self.view.backgroundColor = [Theme paperColor];
    self.textView.backgroundColor = [Theme paperColor];
    
    self.topBar.barTintColor = [Theme paperColor];
    self.bottomBar.barTintColor = [Theme paperColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add custom menu items (for text views).
    [UIMenuController sharedMenuController].menuItems = @[[[UIMenuItem alloc] initWithTitle:@"Share…"
                                                                                     action:@selector(shareSelection:)],
                                                          [[UIMenuItem alloc] initWithTitle:@"Report Problem…"
                                                                                     action:@selector(reportError:)]];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self dismissPlayer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.titleView setNeedsDisplay];
    
    // Auto scroll to the highlight if there is no bookmark.
    if (self.bookmarkedCharacterIndex == 0 && self.bookmarkedCharacterYOffset == 0) {
        [self scrollToCharacterAtIndex:self.highlightRange.location];
    } else {
        [self scrollCharacterAtIndex:self.bookmarkedCharacterIndex toYCoordinate:self.bookmarkedCharacterYOffset];
    }
    
    [self updateBarVisibility];
}

- (NSManagedObject *)modelObject
{
    return self.song;
}

- (Song *)song
{
    Song *song;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:nil];
    if ([managedObject isKindOfClass:[Song class]]) {
        song = (Song *)managedObject;
    }
    return song;
}

//- (UITableView *)relatedItemsView
//{
//    if (!_relatedItemsView) {
//        _relatedItemsView = [[UITableView alloc] init];
//        _relatedItemsView.dataSource = self;
//        _relatedItemsView.delegate = self;
//        _relatedItemsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//        _relatedItemsView.scrollEnabled = NO;
//        _relatedItemsView.separatorInset = UIEdgeInsetsZero;
//        _relatedItemsView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }
//    return _relatedItemsView;
//}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:standardTextSize];
    normalAttributes[NSForegroundColorAttributeName] = [Theme textColor];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:kTitleNumberFontSize];
    numberAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kTitleFontSize];
    titleAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [Theme darkerGrayColor];
    
    NSMutableDictionary *subtitleAttributes = [normalAttributes mutableCopy];
    subtitleAttributes[NSParagraphStyleAttributeName] = self.subtitleParagraphStyle;
    subtitleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kSubtitleFontSize];
    
    NSMutableDictionary *verseTitleAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *verseTitleParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    verseTitleParagraphStyle.alignment = NSTextAlignmentCenter;
    verseTitleAttributes[NSParagraphStyleAttributeName] = verseTitleParagraphStyle;
    
    NSMutableDictionary *chorusAttributes = [normalAttributes mutableCopy];
    chorusAttributes[NSParagraphStyleAttributeName] = [self paragraphStyleFirstLineIndent:standardTextSize andNormalIndent:0];
    
    NSMutableDictionary *ghostChorusAttributes = [chorusAttributes mutableCopy];
    [ghostChorusAttributes addEntriesFromDictionary:ghostAttributes];
    
    NSMutableDictionary *footerAttributes = [normalAttributes mutableCopy];
    NSMutableParagraphStyle *footerParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    footerParagraphStyle.alignment = NSTextAlignmentRight;
    footerAttributes[NSParagraphStyleAttributeName] = footerParagraphStyle;
    footerAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kSubtitleFontSize];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[self.song string]];
    
    [attributedString addAttributes:normalAttributes range:NSMakeRange(0, attributedString.length)];
    
    [self applyAttributes:numberAttributes toRanges:self.songComponentRanges[kSongNumberRangesKey] ofString:attributedString];
    [self applyAttributes:titleAttributes toRanges:self.songComponentRanges[kTitleRangesKey] ofString:attributedString];
    [self applyAttributes:subtitleAttributes toRanges:self.songComponentRanges[kSubtitleRangesKey] ofString:attributedString];
    [self applyAttributes:verseTitleAttributes toRanges:self.songComponentRanges[kVerseTitleRangesKey] ofString:attributedString];
    [self applyAttributes:chorusAttributes toRanges:self.songComponentRanges[kChorusRangesKey] ofString:attributedString];
    [self applyAttributes:ghostAttributes toRanges:self.songComponentRanges[kGhostRangesKey] ofString:attributedString];
    [self applyAttributes:footerAttributes toRanges:self.songComponentRanges[kFooterRangesKey] ofString:attributedString];
    
    // Highlight a portion of the text.
    [attributedString addAttributes:@{NSForegroundColorAttributeName:[Theme redColor],
                                      NSStrokeWidthAttributeName:@(-2)}
                              range:self.highlightRange];
    
    return [attributedString copy];
}

- (void)applyAttributes:(NSDictionary *)attributes toRanges:(NSArray *)ranges ofString:(NSMutableAttributedString *)string
{
    for (NSValue *rangeValue in ranges) {
        NSRange range = [rangeValue rangeValue];
        [string addAttributes:attributes range:range];
    }
}

- (NSParagraphStyle *)paragraphStyleFirstLineIndent:(CGFloat)firstLineIndent
                                    andNormalIndent:(CGFloat)normalIndent
{
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.firstLineHeadIndent = firstLineIndent;
    paragraphStyle.headIndent = normalIndent;
    return paragraphStyle;
}

- (NSArray *)matchingSongFiles
{
    // Generate the target song file URL.
    NSUInteger songIndex = [self.song.section.songs indexOfObject:self.song];
    NSUInteger sectionIndex = [self.song.section.book.sections indexOfObject:self.song.section];
    NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:bookDirectory
                                                   includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                      options:0
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"Error enumerating url: %@", url);
                                                                     return YES;
                                                                 }];
    
    NSString *matchStringA = [NSString stringWithFormat:@"%lu-%lu.", (unsigned long)sectionIndex, (unsigned long)songIndex];
    NSString *matchStringB = [NSString stringWithFormat:@"%lu-%lu-", (unsigned long)sectionIndex, (unsigned long)songIndex];
    
    NSMutableArray *matchingSongFiles = [@[] mutableCopy];
    for (NSURL *url in directoryEnumerator) {
        // Skip directories.
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue]) {
            continue;
        }
        
        NSString *fileExtension = [url pathExtension];
        NSString *fileName = [url lastPathComponent];

        if (([fileName rangeOfString:matchStringA].location == 0 ||
             [fileName rangeOfString:matchStringB].location == 0) &&
            ([fileExtension localizedCaseInsensitiveCompare:@"m4a"] == NSOrderedSame ||
             [fileExtension localizedCaseInsensitiveCompare:@"mp3"] == NSOrderedSame ||
             [fileExtension localizedCaseInsensitiveCompare:@"wav"] == NSOrderedSame)) {
                
            [matchingSongFiles addObject:url];
        }
    }
    
    [matchingSongFiles sortUsingComparator:^NSComparisonResult(NSURL *songFile1, NSURL *songFile2) {
        return [[songFile1 lastPathComponent] localizedCaseInsensitiveCompare:[songFile2 lastPathComponent]];
    }];
    
    return matchingSongFiles;
}

//#pragma mark - UITableViewDataSource
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.relatedSongs count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    if (!cell) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
//    }
//    
//    Song *relatedSong = self.relatedSongs[indexPath.row];
//    
//    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
//    numberAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
//    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
//    titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
//    
//    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
//                                                                                         attributes:nil];
//    if (relatedSong.number) {
//        [attributedString appendString:[NSString stringWithFormat:@"%d", [relatedSong.number integerValue]]attributes:numberAttributes];
//        [attributedString appendString:@" " attributes:titleAttributes];
//    }
//    
//    [attributedString appendString:relatedSong.title attributes:titleAttributes];
//    
//    cell.textLabel.attributedText = attributedString;
//
//    
//    return cell;
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return [self.relatedSongs count] > 0 ? 1 : 0;
//}
//
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    return @"Related Songs";
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [self.delegate pageController:self selectedModelObject:self.relatedSongs[indexPath.row]];
//}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateBarVisibility];
}

- (IBAction)activityAction:(id)sender
{
    NSArray *matchingSongFiles = [self matchingSongFiles];
    
    if ([matchingSongFiles count]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        if ([matchingSongFiles count] == 1) {
            [actionSheet addButtonWithTitle:@"Play Tune"];
        } else {
            [matchingSongFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [actionSheet addButtonWithTitle:[NSString stringWithFormat:@"Play Tune %lu", (unsigned long)(idx + 1)]];
            }];
        }
        
        [actionSheet addButtonWithTitle:@"Share Book"];
        [actionSheet addButtonWithTitle:@"Share Book & Tunes"];
        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //iPhone, present action sheet from view.
            [actionSheet showInView:self.textView];
        } else {
            //iPad, present the action sheet from bar button.
            [actionSheet showFromBarButtonItem:self.activityButton animated:YES];
        }
    } else {
        [super activityAction:sender];
    }
}

#pragma mark - Song Playback

- (void)playSongFile:(NSURL *)songFile
{
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    self.progressView.progress = 0;
    
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.playerView.alpha = 1;
    } completion:^(BOOL finished) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songFile error:nil];
        self.audioPlayer.delegate = self;
        
        if (self.audioPlayer) {
            
            self.playbackTimer = [NSTimer timerWithTimeInterval:0.01
                                                         target:self
                                                       selector:@selector(playbackTimerUpdate)
                                                       userInfo:nil
                                                        repeats:YES];

            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
            [runloop addTimer:self.playbackTimer forMode:UITrackingRunLoopMode];

            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }];
}

- (IBAction)stopPlayingAction:(id)sender
{
    [self dismissPlayer];
}

- (void)dismissPlayer
{
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.playerView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
        
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }];
}

- (void)playbackTimerUpdate
{
    float progress = 0.0;
    if (self.audioPlayer) {
        progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    }
    
    if (progress > self.progressView.progress) {
        [self.progressView setProgress:progress animated:YES];
    }
}

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateBarVisibility];
}

- (void)updateBarVisibility
{
    BOOL shouldShowScrollIndicator = YES;
    
    CGFloat offsetY = self.textView.contentOffset.y;
    
    if (offsetY <= 0) {
        self.topBar.hidden = YES;
        self.titleView.hidden = YES;
        shouldShowScrollIndicator = NO;
    } else {
        self.topBar.hidden = NO;
        self.titleView.hidden = NO;
    }
    
    CGFloat textViewHeight = self.textView.frame.size.height;
    CGFloat textViewContentHeight = [self.textView contentHeight];
    CGFloat textViewOldSchoolContentHeight = self.textView.contentSize.height;
    
    if (offsetY + textViewHeight >= MAX(textViewContentHeight, textViewOldSchoolContentHeight)) {
        shouldShowScrollIndicator = NO;
        [self.bottomBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    } else {
        [self.bottomBar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    }
    
    self.textView.showsVerticalScrollIndicator = shouldShowScrollIndicator;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.textView.contentOffsetCallsAllowed = YES;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (ABS(targetContentOffset->y) <= 1) {
        targetContentOffset->y = 0;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        // Update the bookmark.
        self.textView.contentOffsetCallsAllowed = NO;
        [self updateBookmark];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // Update the bookmark.
    self.textView.contentOffsetCallsAllowed = NO;
    [self updateBookmark];
}

- (void)updateBookmark
{
    // Save the glyph index of the glyph closest to 0,0 of the textView's frame.
    CGPoint topLeftVisibleCornerOfTextView = [self.textView convertPoint:self.textView.frame.origin fromView:self.view];

    // Convert to the text container's coordinate space.
    topLeftVisibleCornerOfTextView.x -= self.textView.textContainerInset.left;
    topLeftVisibleCornerOfTextView.y -= self.textView.textContainerInset.top;

    // Get the glyph index.
    NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForPoint:topLeftVisibleCornerOfTextView
                                                            inTextContainer:self.textView.textContainer
                                             fractionOfDistanceThroughGlyph:NULL];

    // Convert to character index.
    self.bookmarkedCharacterIndex = [self.textView.layoutManager characterIndexForGlyphAtIndex:glyphIndex];
    
    // Get the character's location relative to the main view.
    CGPoint glyphLocationInMainView = [self locationInMainViewOfGlyphAtIndex:glyphIndex];
    
    // Get the character's location relative to the frame origin of the text view.
    CGPoint glyphLocationRelativeToTextViewFrameOrigin = CGPointMake(glyphLocationInMainView.x - self.textView.frame.origin.x,
                                                                     glyphLocationInMainView.y - self.textView.frame.origin.y);
    
    // Save the y offset of the character relative to the frame origin of the text view.
    self.bookmarkedCharacterYOffset = glyphLocationRelativeToTextViewFrameOrigin.y;
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    if (bar == self.topBar) {
        return UIBarPositionBottom;
    } else if (bar == self.bottomBar) {
        return UIBarPositionTop;
    }
    return UIBarPositionAny;
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
        CGPoint gesturePoint = [sender locationInView:self.textView];
        
        // Convert to the text container's coordinate space.
        gesturePoint.x -= self.textView.textContainerInset.left;
        gesturePoint.y -= self.textView.textContainerInset.top;
        
        self.glyphIndex = [self.textView.layoutManager glyphIndexForPoint:gesturePoint inTextContainer:self.textView.textContainer fractionOfDistanceThroughGlyph:NULL];
        
        self.glyphOriginalYCoordinateInMainView = [self locationInMainViewOfGlyphAtIndex:self.glyphIndex].y;
        
        self.touchStartPoint = [sender locationInView:self.view];
        self.latestTouchPoint = self.touchStartPoint;
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {

        [self scaleTextWithScale:sender.scale
                      touchPoint:self.latestTouchPoint
                 minimumFontSize:kMinimumStandardTextSize
                 maximumFontSize:kMaximumStandardTextSize];

        [userDefaults synchronize];
        self.glyphIndex = 0;
        self.glyphOriginalYCoordinateInMainView = 0;
        self.glyphYCoordinateInMainView = 0;
        self.touchStartPoint = CGPointZero;
        self.latestTouchPoint = CGPointZero;
        
        // Limit the content offset to the actual content size.
        CGFloat minimumContentOffset = 0;
        CGFloat maximumContentOffset = MAX([self.textView contentHeight] - self.textView.frame.size.height, 0);
        CGFloat contentOffsetY = self.textView.contentOffset.y;
        contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
        
        [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
        [self updateBookmark];
        
    } else {
        
        CGPoint updatedTouchPoint = [sender locationInView:self.view];
        self.latestTouchPoint = updatedTouchPoint;
        
        [self scaleTextWithScale:sender.scale
                      touchPoint:updatedTouchPoint
                 minimumFontSize:1
                 maximumFontSize:kSuperMaximumStandardTextSize];
    }
}

- (CGPoint)locationInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGPoint glyphLocationInTextView = [self.textView locationForGlyphAtIndex:glyphIndex];
    
    // Convert to the main view's coordinate space.
    CGPoint glyphLocationInMainView = [self.view convertPoint:glyphLocationInTextView fromView:self.textView];
    
    return glyphLocationInMainView;
}

- (void)scaleTextWithScale:(CGFloat)scale
                touchPoint:(CGPoint)touchPoint
           minimumFontSize:(CGFloat)minimumFontSize
           maximumFontSize:(CGFloat)maximumFontSize
{
    
    // Scale the existing text size by the gesture recognizer's scale.
    float scaledSize = [self.gestureStartTextSize floatValue] * scale;
    
    // Limit the scaled size to sane bounds.
    float scaledAndLimitedSize = MIN(maximumFontSize, MAX(minimumFontSize, scaledSize));
    
    CGFloat touchPointVerticalShift = touchPoint.y - self.touchStartPoint.y;
    self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;
    
    // Only update the text scale if the change is significant enough.
    NSNumber *currentTextSize = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    if (fabsf([currentTextSize floatValue] - scaledAndLimitedSize) > kTextScaleThreshold) {
        [[NSUserDefaults standardUserDefaults] setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
    }
    
    CGFloat currentYCoordinateOfGlyphInMainView = [self locationInMainViewOfGlyphAtIndex:self.glyphIndex].y;
    CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
    CGFloat contentOffsetY = self.textView.contentOffset.y - glyphVerticalError;
    
    [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
}

- (void)scrollToCharacterAtIndex:(NSUInteger)characterIndex
{
    CGFloat viewHeight = self.textView.frame.size.height;
    CGFloat targetYCoordinate = viewHeight - (viewHeight / M_PHI);
    [self scrollCharacterAtIndex:characterIndex toYCoordinate:targetYCoordinate];
}

- (void)scrollCharacterAtIndex:(NSUInteger)characterIndex toYCoordinate:(CGFloat)yCoordinate
{
    NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:characterIndex];
    CGFloat currentYCoordinateOfGlyphInMainView = [self locationInMainViewOfGlyphAtIndex:glyphIndex].y;
    CGFloat glyphVerticalError = yCoordinate - currentYCoordinateOfGlyphInMainView;
    CGFloat currentContentOffsetY = self.textView.contentOffset.y;
    CGFloat contentOffsetY = currentContentOffsetY - glyphVerticalError;

    // Limit the content offset to the actual content size.
    CGFloat minimumContentOffset = 0;
    CGFloat maximumContentOffset = MAX([self.textView contentHeight] - self.textView.frame.size.height, 0);
    contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
    
    [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
    [self updateBookmark];
}

#pragma mark - Menu actions.

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(reportError:)) {
        return [self.song.section.book.contactEmail length] && [MFMailComposeViewController canSendMail];
    } else {
        return [super canPerformAction:action withSender:sender];
    }
}

- (void)shareSelection:(id)sender
{
    NSArray *activityItems = @[[self buildSharingString]];
    UIActivityViewController *activityViewController = [[NoStatusActivityViewController alloc] initWithActivityItems:activityItems
                                                                                               applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //iPad, present the view controller inside a popover
        if (![self.activityPopover isPopoverVisible]) {
            self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            CGRect selectionBoundingRect = CGRectNull;
            NSArray *selectionRects = [self.textView selectionRectsForRange:self.textView.selectedTextRange];
            for (int i = 0; i < [selectionRects count]; i++) {
                CGRect selectionRect = ((UITextSelectionRect *)selectionRects[i]).rect;
                if (i == 0) {
                    selectionBoundingRect = selectionRect;
                } else {
                    selectionBoundingRect = CGRectUnion(selectionBoundingRect, selectionRect);
                }
            }
            [self.activityPopover presentPopoverFromRect:selectionBoundingRect inView:self.textView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            //Dismiss if the button is tapped while pop over is visible
            [self.activityPopover dismissPopoverAnimated:YES];
        }
    }
}

- (void)reportError:(id)sender
{
    // Could not open the file.
    UIAlertView *reportAlertView = [[UIAlertView alloc] initWithTitle:@"Report Problem"
                                                              message:@"Would you like to report an error in this song?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Report", nil];
    [reportAlertView show];
}

- (NSString *)buildSharingString
{
    NSString *mainContent = [self.textView.text substringWithRange:self.textView.selectedRange];
    NSString *prefix = self.textView.selectedRange.location ? @"…" : @"";
    NSString *suffix = self.textView.selectedRange.location + self.textView.selectedRange.length < [self.textView.text length] ? @"…" : @"";
    return [NSString stringWithFormat:@"%@%@%@", prefix, mainContent, suffix];
}

- (NSString *)buildProblemReportString
{
    // Get the complete song text.
    NSString *songText = self.song.string;
    
    // Create an attributed string.
    NSMutableAttributedString *attributedSongText = [[NSMutableAttributedString alloc] initWithString:songText];
    
    // Determine the fonts to use.
    UIFont *preferredFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    UIFont *preferredFontBold = [UIFont fontWithDescriptor:[[preferredFont fontDescriptor] fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold] size:preferredFont.pointSize];
    
    // Set the font.
    [attributedSongText addAttribute:NSFontAttributeName
                               value:preferredFont
                               range:NSMakeRange(0, attributedSongText.length)];
    
    // Bold and color the selected range.
    [attributedSongText addAttributes:@{NSForegroundColorAttributeName: [Theme redColor],
                                        NSFontAttributeName:preferredFontBold}
                                range:self.textView.selectedRange];
    
    // Convert the attributed string to HTML.
    NSData *htmlData = [attributedSongText dataFromRange:NSMakeRange(0, attributedSongText.length)
                                      documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                   error:nil];
    NSString *htmlString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];

    return htmlString;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Cancel
            break;
        case 1:
            // Report
            [self sendEmailProblemReport];
            break;
        default:
            break;
    }
}

- (void)sendEmailProblemReport
{
    // Email the file data.
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    
    Book *book = self.song.section.book;
    
    NSString *sectionTitle = self.song.section.title;
    
    NSMutableString *songID = [@"" mutableCopy];
    if (self.song.number) {
        [songID appendString:[self.song.number stringValue]];
    }
    if ([self.song.title length]) {
        if ([songID length]) {
            [songID appendString:@" "];
        }
        [songID appendString:self.song.title];
    }

    [mailController setSubject:[NSString stringWithFormat:@"Songbook Problem Report: %@ - Version %@ - %@ - %@ - %lu", book.title, book.version, sectionTitle, songID, (unsigned long)self.textView.selectedRange.location]];
    
    if ([book.contactEmail length]) {
        [mailController setToRecipients:@[book.contactEmail]];
    }
    
    [mailController setMessageBody:[self buildProblemReportString] isHTML:YES];
    
    NSURL *fileURL = [BookCodec exportBookFromDirectory:self.coreDataStack.databaseDirectory includeExtraFiles:NO progress:nil];
    NSData *exportData = [NSData dataWithContentsOfURL:fileURL];
    NSError *deleteError;
    if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError]) {
        NSLog(@"Failed to delete temporary export file: %@", deleteError);
    }
    [mailController addAttachmentData:exportData
                             mimeType:@"application/vnd.paulhimes.songbook.songbook"
                             fileName:[fileURL lastPathComponent]];
    
    [self presentViewController:mailController animated:YES completion:^{}];
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *matchingSongFiles = [self matchingSongFiles];
    if ([matchingSongFiles count]) {
        if (buttonIndex < [matchingSongFiles count]) {
            [self playSongFile:matchingSongFiles[buttonIndex]];
        } else {
            buttonIndex -= [matchingSongFiles count];
            
            if (buttonIndex == 0) {
                [self shareBookWithExtraFiles:NO];
            } else if (buttonIndex == 1) {
                [self shareBookWithExtraFiles:YES];
            }
        }
    } else {
        [super actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self dismissPlayer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self dismissPlayer];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self dismissPlayer];
}

@end
