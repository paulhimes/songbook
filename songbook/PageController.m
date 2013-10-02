//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "PinchAnchor.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

static const NSInteger kGutterWidth = 16;
static const CGFloat kToolbarHeight = 44;
static const float kMaximumStandardTextSize = 30;
static const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *foregroundToolbar;
@property (nonatomic, strong) UITableView *relatedItemsView;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) NSNumber *gestureStartTextSize;

// NEW WAY
@property (nonatomic) BOOL shouldLockScrolling;
@property (nonatomic) NSUInteger glyphIndex;
@property (nonatomic) CGFloat glyphOriginalYCoordinateInMainView;
@property (nonatomic) CGFloat glyphYCoordinateInMainView;
@property (nonatomic) CGPoint touchStartPoint;

// OLD WAY
@property (nonatomic, strong) PinchAnchor *pinchAnchor;


@end

@implementation PageController
@synthesize titleView = _titleView;
@synthesize scrollView = _scrollView;
@synthesize textView = _textView;

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.clipsToBounds = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0, kToolbarHeight, 0);
        _scrollView.alwaysBounceVertical = YES;
        [_scrollView setDebugColor:[UIColor magentaColor]];
    }
    return _scrollView;
}

- (UIToolbar *)foregroundToolbar
{
    if (!_foregroundToolbar) {
        _foregroundToolbar = [[UIToolbar alloc] init];
        _foregroundToolbar.delegate = self;
        _foregroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _foregroundToolbar.hidden = YES;
        _foregroundToolbar.userInteractionEnabled = NO;
        _foregroundToolbar.barTintColor = [UIColor clearColor];
    }
    return _foregroundToolbar;
}

- (TitleView *)titleView
{
    if (!_titleView) {
        _titleView = [self buildTitleView];
        _titleView.userInteractionEnabled = NO;
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _titleView.backgroundColor = [UIColor clearColor];
//        [_titleView setDebugColor:[UIColor orangeColor]];
    }
    return _titleView;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.clipsToBounds = NO;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_textView setDebugColor:[UIColor greenColor]];
        _textView.opaque = NO;
        _textView.backgroundColor = [UIColor clearColor];
//        _textView.backgroundColor = [UIColor blueColor];
    }
    return _textView;
}

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (UITableView *)relatedItemsView
{
    if (!_relatedItemsView) {
        _relatedItemsView = [[UITableView alloc] init];
        _relatedItemsView.dataSource = self;
        _relatedItemsView.delegate = self;
        _relatedItemsView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _relatedItemsView.scrollEnabled = NO;
        _relatedItemsView.separatorInset = UIEdgeInsetsZero;
        _relatedItemsView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_relatedItemsView setDebugColor:[UIColor purpleColor]];
    }
    return _relatedItemsView;
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGesture:)];
    }
    return _pinchGestureRecognizer;
}

- (TitleView *)buildTitleView
{
    return nil;
}

- (void)loadView
{
    self.view = [[UIView alloc] init];
    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.view.frame = applicationFrame;
    self.view.clipsToBounds = YES;
    
    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
//    NSLog(@"contentwidth = %f", contentWidth);
    self.scrollView.frame = CGRectMake(kGutterWidth,
                                       0,
                                       contentWidth,
                                       self.view.bounds.size.height);
    
    self.titleView.frame = CGRectMake(kGutterWidth,
                                      0,
                                      contentWidth,
                                      [self.titleView sizeForWidth:contentWidth].height);
    
    self.foregroundToolbar.frame = CGRectMake(0,
                                              0,
                                              self.view.bounds.size.width,
                                              self.titleView.frame.size.height);
    
    self.textView.attributedText = self.text;
    self.textView.frame = CGRectMake(0, 0, contentWidth, 0);
    
    self.relatedItemsView.frame = CGRectMake(0, 0, contentWidth, 0);
    [self.relatedItemsView setHeight:self.relatedItemsView.contentHeight];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];
    [self.scrollView addSubview:self.relatedItemsView];
    
    if (self.titleView) {
        [self.view addSubview:self.foregroundToolbar];
        [self.foregroundToolbar addSubview:self.titleView];
    }
    
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.foregroundToolbar.frame.size.height, 0, kToolbarHeight, -kGutterWidth);
    
    CGFloat titleContentOriginY = self.titleView.contentOriginY;
    //    NSLog(@"titleContentOriginY %f", titleContentOriginY);
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 0, 0);
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update any frames and view properties that the normal layout system (autolayout or autoresize) can't handle.

//    NSLog(@"Laid out view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
//    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
//    NSLog(@"contentwidth = %f", contentWidth);
    
//    [self.titleView resetMetrics];
//    [self.titleView setHeight:[self.titleView sizeForWidth:self.titleView.frame.size.width].height];
//    [self.foregroundToolbar setHeight:self.titleView.frame.size.height];
    
//    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.foregroundToolbar.frame.size.height, 0, kToolbarHeight, -kGutterWidth);
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    [self.textView setHeight:textSize.height];
    
    [self.relatedItemsView setOriginY:CGRectGetMaxY(self.textView.frame) + 3 * kGutterWidth];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom),
                                                 CGRectGetMaxY(self.relatedItemsView.frame)));
    

    
    if (self.shouldLockScrolling) {
        
//        self.pinchAnchor = [[PinchAnchor alloc] initWithScrollViewYCoordinate:50 percentDownSubview:0.5];
        
        
        CGFloat currentYCoordinateOfGlyphInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];

        CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
        
//        NSLog(@"Glyph vertical error %f", glyphVerticalError);
        
        CGFloat contentOffsetY = self.scrollView.contentOffset.y - glyphVerticalError;
        
        // Limit the content offset to the actual content size.
        CGFloat minimumContentOffset = 0;
        CGFloat maximumContentOffset = MAX(self.scrollView.contentSize.height - self.scrollView.frame.size.height, 0);
        
        contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
        
//        NSLog(@"contentOffsetY %f", contentOffsetY);
        
        self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, contentOffsetY);
    }
    
    [self.titleView setNeedsDisplay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.scrollView.contentOffset = CGPointZero;
}

- (NSString *)textFragment
{
    NSString *string = self.text.string;
    
    if ([string length] > 15) {
        string = [string substringToIndex:15];
    }
    
    return string;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY <= 0) {
        self.foregroundToolbar.hidden = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
    } else {
        self.foregroundToolbar.hidden = NO;
        self.scrollView.showsVerticalScrollIndicator = YES;
    }

//    NSLog(@"scrollview offset y = %f [%@]", offsetY, [self textFragment]);
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
    return UIBarPositionAny;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
        CGPoint gesturePoint = [sender locationInView:self.textView];
        
        NSLog(@"TextView Point = %@", NSStringFromCGPoint(gesturePoint));
        
        // Convert to the text container's coordinate space.
        gesturePoint.x -= self.textView.textContainerInset.left;
        gesturePoint.y -= self.textView.textContainerInset.top;
        
        self.glyphIndex = [self.textView.layoutManager glyphIndexForPoint:gesturePoint inTextContainer:self.textView.textContainer fractionOfDistanceThroughGlyph:NULL];
        
//        NSString *touchedString = [self.textView.text substringWithRange:NSMakeRange([self.textView.layoutManager characterIndexForGlyphAtIndex:self.glyphIndex], 5)];
//        NSLog(@"glyph index %d [%@]", self.glyphIndex, touchedString);
        
        self.glyphOriginalYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];

        self.touchStartPoint = [sender locationInView:self.view];
        
        
        self.shouldLockScrolling = YES;
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        [userDefaults synchronize];
        self.shouldLockScrolling = NO;
        self.glyphIndex = 0;
        self.glyphOriginalYCoordinateInMainView = 0;
        self.glyphYCoordinateInMainView = 0;
        self.touchStartPoint = CGPointZero;
    } else {
        
        // Scale the existing text size by the gesture recognizer's scale.
        float scaledSize = [self.gestureStartTextSize floatValue] * sender.scale;
        
        // Limit the scaled size to sane bounds.
        float scaledAndLimitedSize = MIN(kMaximumStandardTextSize, MAX(kMinimumStandardTextSize, scaledSize));
        
        
        if (![@(scaledAndLimitedSize) isEqualToNumber:[userDefaults objectForKey:kStandardTextSizeKey]]) {
            
            
            //        self.glyphYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];
            
            CGPoint updatedTouchPoint = [sender locationInView:self.view];
            
            CGFloat touchPointVerticalShift = updatedTouchPoint.y - self.touchStartPoint.y;
            
            self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;
            
            [userDefaults setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
            NSAttributedString *text = self.text;
            self.textView.attributedText = text;
            [self.view setNeedsLayout];
        }
    }
    
    
    
}

- (CGFloat)yCoordinateInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGRect fragmentRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    CGPoint glyphLocation = [self.textView.layoutManager locationForGlyphAtIndex:glyphIndex];
    glyphLocation.x += CGRectGetMinX(fragmentRect);
    glyphLocation.y += CGRectGetMinY(fragmentRect);
    
//    NSLog(@"Glyph Point (container) = %@", NSStringFromCGPoint(glyphLocation));
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textView.textContainerInset.left;
    glyphLocation.y += self.textView.textContainerInset.top;
    
//    NSLog(@"Glyph Point (view) = %@", NSStringFromCGPoint(glyphLocation));
    
    
    //        CGFloat percentDownTextView = glyphLocation.y / self.textView.frame.size.height;
    
    CGPoint glyphLocationInMainView = [self.view convertPoint:glyphLocation fromView:self.textView];
    
//    NSLog(@"Glyph Point (main view) = %@", NSStringFromCGPoint(glyphLocationInMainView));
    
    return glyphLocationInMainView.y;
}

@end
