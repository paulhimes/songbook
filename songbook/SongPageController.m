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

static const float kTextScaleThreshold = 0.5;

@interface SongPageController () <UITextViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, readonly) Song *song;

@property (nonatomic, strong) NSArray *relatedSongs;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *topBar;
@property (weak, nonatomic) IBOutlet SongTitleView *titleView;

@property (weak, nonatomic) IBOutlet UIVisualEffectView *bottomBarBackground;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;

@property (nonatomic, strong) NSNumber *gestureStartTextSize;
@property (nonatomic) NSUInteger glyphIndex;
@property (nonatomic) CGFloat glyphOriginalYCoordinateInMainView;
@property (nonatomic) CGFloat glyphYCoordinateInMainView;
@property (nonatomic) CGPoint touchStartPoint;
@property (nonatomic) CGPoint latestTouchPoint;

@property (nonatomic, readonly) CGFloat minimumContentOffset;
@property (nonatomic, readonly) CGFloat maximumContentOffset;

// Caching for speed optimization.
@property (nonatomic, strong) NSParagraphStyle *numberAndTitleParagraphStyle;
@property (nonatomic, strong) NSParagraphStyle *subtitleParagraphStyle;
@property (nonatomic, strong) NSDictionary *songComponentRanges;

@end

@implementation SongPageController

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

- (CGFloat)minimumContentOffset
{
    return -(self.view.layoutMargins.top + self.textView.contentInset.top);
}

- (CGFloat)maximumContentOffset
{
    return MAX(self.minimumContentOffset, self.textView.contentSize.height + self.bottomBarBackground.frame.size.height - self.textView.bounds.size.height );
}

- (void)viewDidLoad
{
    self.titleView.number = self.song.number;
    self.titleView.title = self.song.title;
    
    [super viewDidLoad];
    
    self.textView.contentOffsetCallsAllowed = NO;
    
    UIImage *clearImage = [[UIImage alloc] init];
    [self.bottomBar setBackgroundImage:clearImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomBar setShadowImage:clearImage forToolbarPosition:UIBarPositionAny];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add custom menu items (for text views).
    [UIMenuController sharedMenuController].menuItems = @[[[UIMenuItem alloc] initWithTitle:@"Report Problem…"
                                                                                     action:@selector(reportError:)]];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.bottomBar invalidateIntrinsicContentSize];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self.titleView setNeedsDisplay];
    [self updateBarVisibility];

    CGFloat titleContentOriginY = self.titleView.contentOriginY;
    
    [self updateTextViewTextConteinerInset];
    self.textView.contentInset = UIEdgeInsetsMake(titleContentOriginY, 0, self.bottomBarBackground.frame.size.height - self.view.layoutMargins.bottom, 0);
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(self.titleView.frame.size.height, self.textView.scrollIndicatorInsets.left, self.bottomBarBackground.frame.size.height - self.view.layoutMargins.bottom, 0);

    // Auto scroll to the highlight if there is no bookmark.
    if (self.bookmarkedGlyphIndex == 0 && self.bookmarkedGlyphYOffset == 0) {
        NSUInteger glyphIndex = [self.textView.layoutManager glyphIndexForCharacterAtIndex:self.highlightRange.location];
        [self scrollToGlyphAtIndex:glyphIndex];
    } else {
        [self scrollGlyphAtIndex:self.bookmarkedGlyphIndex toYCoordinate:self.bookmarkedGlyphYOffset];
    }
}

- (void)updateThemedElements
{
    self.view.backgroundColor = [Theme paperColor];
    self.textView.backgroundColor = [Theme paperColor];
    [self.titleView setNeedsDisplay];

    switch ([Theme currentThemeColor]) {
        case Light:
            self.topBar.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            self.bottomBarBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            self.textView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
            break;
        case Dark:
            self.topBar.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.bottomBarBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.textView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
            break;
    }
}

- (void)updateTextViewTextConteinerInset
{
    // Calculate the bottom inset such that the last line of the last verse / chorus will be visible when you scroll all the way to the bottom.
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    CGFloat bottomSpace = self.view.bounds.size.height - self.topBar.frame.size.height - self.bottomBarBackground.frame.size.height;
    
    NSValue *lastTextRangeBeforeFooterValue = self.songComponentRanges[kLastTextRangeBeforeFooterKey];
    if (lastTextRangeBeforeFooterValue) {
        NSRange lastTextRangeBeforeFooter = lastTextRangeBeforeFooterValue.rangeValue;
        CGFloat bottomInsetOfLastTextLineBeforeFooter = [self.textView distanceFromLastLineTopToContainerBottomForCharactersInRange:lastTextRangeBeforeFooter];
        bottomSpace -= bottomInsetOfLastTextLineBeforeFooter + [UIFont fontWithName:[Theme normalFontFamily] size:standardTextSize].leading;
    }
    
    self.textView.textContainerInset = UIEdgeInsetsMake(0, self.view.layoutMargins.left, bottomSpace, self.view.layoutMargins.right);
}

- (id<SongbookModel>)modelObject
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

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];

    NSMutableDictionary *normalAttributes = [@{} mutableCopy];
    normalAttributes[NSFontAttributeName] = [UIFont fontWithName:[Theme normalFontFamily] size:standardTextSize];
    normalAttributes[NSForegroundColorAttributeName] = [Theme textColor];
    
    NSMutableDictionary *numberAttributes = [normalAttributes mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:[Theme boldFontFamily] size:kTitleNumberFontSize];
    numberAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *titleAttributes = [normalAttributes mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:[Theme normalFontFamily] size:kTitleFontSize];
    titleAttributes[NSParagraphStyleAttributeName] = self.numberAndTitleParagraphStyle;

    NSMutableDictionary *ghostAttributes = [normalAttributes mutableCopy];
    ghostAttributes[NSForegroundColorAttributeName] = [Theme fadedTextColor];
    
    NSMutableDictionary *subtitleAttributes = [normalAttributes mutableCopy];
    subtitleAttributes[NSParagraphStyleAttributeName] = self.subtitleParagraphStyle;
    subtitleAttributes[NSFontAttributeName] = [UIFont fontWithName:[Theme normalFontFamily] size:kSubtitleFontSize];
    
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
    footerAttributes[NSFontAttributeName] = [UIFont fontWithName:[Theme normalFontFamily] size:kSubtitleFontSize];
    
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

- (NSArray<NSURL *> *)pageSongFiles
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self updateBarVisibility];
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

    if (offsetY <= self.minimumContentOffset) {
        self.topBar.hidden = YES;
        self.titleView.hidden = YES;
        shouldShowScrollIndicator = NO;
    } else {
        self.topBar.hidden = NO;
        self.titleView.hidden = NO;
    }
    
    if (offsetY >= self.maximumContentOffset) {
        shouldShowScrollIndicator = NO;
        self.bottomBarBackground.hidden = YES;
    } else {
        self.bottomBarBackground.hidden = NO;
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

    // Get the glyph index.
    NSUInteger glyphIndex = [self.textView glyphIndexClosestToPoint:topLeftVisibleCornerOfTextView];

    // Convert to character index.
    self.bookmarkedGlyphIndex = glyphIndex;
    
    // Get the glyph's location relative to the frame origin of the text view.
    CGPoint glyphLocationInTextView = [self.textView locationForGlyphAtIndex:glyphIndex];

    // Save the y offset of the glyph relative to the frame origin of the text view.
    self.bookmarkedGlyphYOffset = glyphLocationInTextView.y;
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
        CGPoint gesturePoint = [sender locationInView:self.textView];
        
        self.glyphIndex = [self.textView glyphIndexClosestToPoint:gesturePoint];

        self.glyphOriginalYCoordinateInMainView = [self locationInMainViewOfGlyphAtIndex:self.glyphIndex].y;
        
        self.touchStartPoint = [sender locationInView:self.view];
        self.latestTouchPoint = self.touchStartPoint;
        
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {

        self.glyphIndex = 0;
        self.glyphOriginalYCoordinateInMainView = 0;
        self.glyphYCoordinateInMainView = 0;
        self.touchStartPoint = CGPointZero;
        self.latestTouchPoint = CGPointZero;
        
        // Limit the content offset to the actual content size.
        CGFloat contentOffsetY = self.textView.contentOffset.y;
        contentOffsetY = MIN(self.maximumContentOffset, MAX(self.minimumContentOffset, contentOffsetY));

        [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
        [self updateBookmark];
        
        [self updateTextViewTextConteinerInset];
        
    } else if (sender.state == UIGestureRecognizerStateChanged && sender.numberOfTouches > 1){
        CGPoint updatedTouchPoint = [sender locationInView:self.view];
        self.latestTouchPoint = updatedTouchPoint;
        
        [self scaleTextWithScale:sender.scale
                      touchPoint:updatedTouchPoint
                 minimumFontSize:kMinimumStandardTextSize
                 maximumFontSize:kSuperMaximumStandardTextSize];
    }
}

- (CGPoint)locationInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGPoint glyphLocationInTextView = [self.textView locationForGlyphAtIndex:glyphIndex];
    
    // Convert to the main view's coordinate space.
    CGPoint glyphLocationInMainView = CGPointMake(glyphLocationInTextView.x + self.textView.frame.origin.x, glyphLocationInTextView.y + self.textView.frame.origin.y);
    
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

    // Only update the text scale if the change is significant enough.
    NSNumber *currentTextSize = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    if (fabsf([currentTextSize floatValue] - scaledAndLimitedSize) > kTextScaleThreshold) {
        // Persist the new text size.
        [[NSUserDefaults standardUserDefaults] setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    CGFloat touchPointVerticalShift = touchPoint.y - self.touchStartPoint.y;
    self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;

    CGFloat currentYCoordinateOfGlyphInMainView = [self locationInMainViewOfGlyphAtIndex:self.glyphIndex].y;
    CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
    CGFloat contentOffsetY = self.textView.contentOffset.y - glyphVerticalError;
    
    [self.textView forceContentOffset:CGPointMake(self.textView.contentOffset.x, contentOffsetY)];
}

- (void)scrollToGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGFloat viewHeight = self.textView.frame.size.height;
    CGFloat targetYCoordinate = viewHeight - (viewHeight / M_PHI);
    [self scrollGlyphAtIndex:glyphIndex toYCoordinate:targetYCoordinate];
}

- (void)scrollGlyphAtIndex:(NSUInteger)glyphIndex toYCoordinate:(CGFloat)yCoordinate
{
    CGFloat currentYCoordinateOfGlyphInMainView = [self locationInMainViewOfGlyphAtIndex:glyphIndex].y;
    CGFloat glyphVerticalError = yCoordinate - currentYCoordinateOfGlyphInMainView;
    CGFloat currentContentOffsetY = self.textView.contentOffset.y;
    CGFloat contentOffsetY = currentContentOffsetY - glyphVerticalError;
    
    // Limit the content offset to the actual content size.
    contentOffsetY = MIN(self.maximumContentOffset, MAX(self.minimumContentOffset, contentOffsetY));
    
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

- (void)reportError:(id)sender
{
    UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:@"Report Problem" message:@"Would you like to report an error in this song?" preferredStyle:UIAlertControllerStyleAlert];
    
    __weak SongPageController *welf = self;
    [reportAlert addAction:[UIAlertAction actionWithTitle:@"Report" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [welf sendEmailProblemReport];
    }]];
    
    [reportAlert addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    [self presentViewController:reportAlert animated:YES completion:^{}];
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
@end
