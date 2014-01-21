//
//  SongPageController.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongPageController.h"
#import "Verse.h"
#import "SongTitleView.h"
#import "Book+Helpers.h"
#import "BookCodec.h"
#import "Section+Helpers.h"

static const float kTextScaleThreshold = 1;

@interface SongPageController () <UITextViewDelegate, UIToolbarDelegate, UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, readonly) Song *song;

@property (nonatomic, strong) NSArray *relatedSongs;

@property (weak, nonatomic) IBOutlet UIToolbar *topBar;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet SafeTextView *textView;
@property (weak, nonatomic) IBOutlet SongTitleView *titleView;

//@property (nonatomic, strong) UITableView *relatedItemsView;

@property (nonatomic, strong) NSNumber *gestureStartTextSize;
@property (nonatomic) NSUInteger glyphIndex;
@property (nonatomic) CGFloat glyphOriginalYCoordinateInMainView;
@property (nonatomic) CGFloat glyphYCoordinateInMainView;
@property (nonatomic) CGPoint touchStartPoint;
@property (nonatomic) CGPoint latestTouchPoint;

@property (nonatomic) BOOL hasAutoScrolledToHighlight;

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
    //    NSLog(@"titleContentOriginY %f", titleContentOriginY);
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 44, 0);
    
    self.topBar.delegate = self;
    self.bottomBar.delegate = self;

    [super viewDidLoad];
    
    [self.textView setDebugColor:[UIColor redColor]];
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.titleView setNeedsDisplay];
    
    // Auto scroll the first time only.
    if (!self.hasAutoScrolledToHighlight) {
        self.hasAutoScrolledToHighlight = YES;
        [self scrollToCharacterAtIndex:self.highlightRange.location];
    }
}

- (NSManagedObject *)modelObject
{
    return self.song;
}

- (Song *)song
{
    Song *song;
    NSError *getSongError;
    NSManagedObject *managedObject = [self.coreDataStack.managedObjectContext existingObjectWithID:self.modelID error:&getSongError];
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
//        [_relatedItemsView setDebugColor:[UIColor purpleColor]];
//    }
//    return _relatedItemsView;
//}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:standardTextSize];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:kTitleNumberFontSize];
    numberAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:kTitleFontSize];
    titleAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [UIColor grayColor];
    
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

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL shouldShowScrollIndicator = YES;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    if (offsetY <= 0) {
        self.topBar.hidden = YES;
        self.titleView.hidden = YES;
        shouldShowScrollIndicator = NO;
    } else {
        self.topBar.hidden = NO;
        self.titleView.hidden = NO;
    }
    
    if ([scrollView isKindOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)scrollView;

        CGFloat textViewHeight = textView.frame.size.height;
        CGFloat textViewTopContainerInset = textView.textContainerInset.top;
        CGFloat textViewBottomContainerInset = textView.textContainerInset.bottom;
        CGRect textViewContentRect = [textView.layoutManager usedRectForTextContainer:textView.textContainer];
        CGFloat textViewTextKitHeight = textViewContentRect.size.height + textViewTopContainerInset + textViewBottomContainerInset;
        
        if (offsetY + textViewHeight >= textViewTextKitHeight) {
            shouldShowScrollIndicator = NO;
            [self.bottomBar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        } else {
            [self.bottomBar setBackgroundImage:nil forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        }
    }
    
    scrollView.showsVerticalScrollIndicator = shouldShowScrollIndicator;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
                     withVelocity:(CGPoint)velocity
              targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (ABS(targetContentOffset->y) <= 1) {
        targetContentOffset->y = 0;
    }
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
        
        self.glyphOriginalYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];
        
        self.touchStartPoint = [sender locationInView:self.view];
        self.latestTouchPoint = self.touchStartPoint;
        
        self.textView.contentOffsetCallsDisabled = YES;
        
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
        
        self.textView.contentOffsetCallsDisabled = NO;
        
        // Limit the content offset to the actual content size.
        CGFloat minimumContentOffset = 0;
        CGFloat maximumContentOffset = MAX(self.textView.contentSize.height - (self.textView.frame.size.height - self.textView.textContainerInset.bottom - self.textView.textContainerInset.top), 0);
        CGFloat contentOffsetY = self.textView.contentOffset.y;
        contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
        [self.textView setContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];

    } else {
        
        CGPoint updatedTouchPoint = [sender locationInView:self.view];
        self.latestTouchPoint = updatedTouchPoint;
        
        [self scaleTextWithScale:sender.scale
                      touchPoint:updatedTouchPoint
                 minimumFontSize:1
                 maximumFontSize:kSuperMaximumStandardTextSize];
    }
}

- (CGFloat)yCoordinateInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGRect fragmentRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    CGPoint glyphLocation = [self.textView.layoutManager locationForGlyphAtIndex:glyphIndex];
    
    glyphLocation.x += CGRectGetMinX(fragmentRect);
    glyphLocation.y += CGRectGetMinY(fragmentRect);
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textView.textContainerInset.left;
    glyphLocation.y += self.textView.textContainerInset.top;
    
    // Convert to the main view's coordinate space.
    CGPoint glyphLocationInMainView = [self.view convertPoint:glyphLocation fromView:self.textView];
    
    return glyphLocationInMainView.y;
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
    
    // Only update the text scale if the change is significant enough.
    NSNumber *currentTextSize = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    if (fabsf([currentTextSize floatValue] - scaledAndLimitedSize) > kTextScaleThreshold) {
        
        CGFloat touchPointVerticalShift = touchPoint.y - self.touchStartPoint.y;
        self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;
        
        [[NSUserDefaults standardUserDefaults] setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
        
        CGFloat currentYCoordinateOfGlyphInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];
        CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
        CGFloat contentOffsetY = self.textView.contentOffset.y - glyphVerticalError;
        
        [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
    }
    
}

- (void)scrollToCharacterAtIndex:(NSUInteger)characterIndex
{
    CGFloat viewHeight = self.view.bounds.size.height;
    CGFloat targetYCoordinate = viewHeight - (viewHeight / M_PHI);
    
    NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:characterIndex];
    CGFloat currentYCoordinateOfGlyphInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:glyphIndex];
    CGFloat glyphVerticalError = targetYCoordinate - currentYCoordinateOfGlyphInMainView;
    CGFloat currentContentOffsetY = self.textView.contentOffset.y;
    CGFloat contentOffsetY = currentContentOffsetY - glyphVerticalError;

    [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
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
    NSArray *activityItems = @[[self.textView.text substringWithRange:self.textView.selectedRange]];
    UIActivityViewController *activityViewController = [[NoStatusActivityViewController alloc] initWithActivityItems:activityItems
                                                                                               applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)reportError:(id)sender
{
    NSLog(@"Report error");
    // Could not open the file.
    UIAlertView *reportAlertView = [[UIAlertView alloc] initWithTitle:@"Report Problem"
                                                              message:@"Would you like to report an error in this song?"
                                                             delegate:self
                                                    cancelButtonTitle:@"No"
                                                    otherButtonTitles:@"Report", nil];
    [reportAlertView show];
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
    
    [mailController setMessageBody:[NSString stringWithFormat:@"…%@…", [self.textView.text substringWithRange:self.textView.selectedRange]] isHTML:NO];
    
    NSURL *fileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
    [BookCodec exportBookFromContext:self.coreDataStack.managedObjectContext intoURL:fileURL];
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

@end
