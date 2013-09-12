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
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];
    [self.scrollView addSubview:self.relatedItemsView];
    
    if (self.titleView) {
        [self.view addSubview:self.foregroundToolbar];
        [self.foregroundToolbar addSubview:self.titleView];
    }
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update any frames and view properties that the normal layout system (autolayout or autoresize) can't handle.

//    NSLog(@"Laid out view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
//    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
//    NSLog(@"contentwidth = %f", contentWidth);
    
    [self.titleView resetMetrics];
    [self.titleView setHeight:[self.titleView sizeForWidth:self.titleView.frame.size.width].height];
    [self.foregroundToolbar setHeight:self.titleView.frame.size.height];
    
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.foregroundToolbar.frame.size.height, 0, kToolbarHeight, -kGutterWidth);
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    [self.textView setHeight:textSize.height];
    
    [self.relatedItemsView setOriginY:CGRectGetMaxY(self.textView.frame) + 3 * kGutterWidth];
    [self.relatedItemsView setHeight:self.relatedItemsView.contentHeight];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width,
                                             MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom),
                                                 CGRectGetMaxY(self.relatedItemsView.frame)));
    
    CGFloat titleContentOriginY = self.titleView.contentOriginY;
//    NSLog(@"titleContentOriginY %f", titleContentOriginY);
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 0, 0);
    
    
    if (self.pinchAnchor) {
        
//        self.pinchAnchor = [[PinchAnchor alloc] initWithScrollViewYCoordinate:50 percentDownSubview:0.5];
        
        CGFloat contentYCoordinate = self.textView.frame.origin.y + (self.pinchAnchor.percentDownSubview * self.textView.frame.size.height);
        
        NSLog(@"contentYCoordinate %f", contentYCoordinate);
        
        CGFloat contentOffsetY = (contentYCoordinate - self.pinchAnchor.yCoordinateInScrollView);
        
        // Limit the content offset to the actual content size.
        CGFloat minimumContentOffset = 0;
        CGFloat maximumContentOffset = MAX(self.scrollView.contentSize.height - self.scrollView.frame.size.height, 0);
        
        contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
        
        NSLog(@"contentOffsetY %f", contentOffsetY);
        
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
    }
    
    // Scale the existing text size by the gesture recognizer's scale.
    float scaledSize = (int)round([self.gestureStartTextSize floatValue] * sender.scale);
    
    // Limit the scaled size to sane bounds.
    float scaledAndLimitedSize = MIN(kMaximumStandardTextSize, MAX(kMinimumStandardTextSize, scaledSize));
    
    
    if (![@(scaledAndLimitedSize) isEqualToNumber:[userDefaults objectForKey:kStandardTextSizeKey]]) {
        NSLog(@"Pinching %f %fpt", sender.scale, scaledAndLimitedSize);
        
        CGFloat percentDownTextView = [sender locationInView:self.textView].y / self.textView.frame.size.height;
        CGFloat yCoordinateInScrollView = [sender locationInView:self.view].y - self.scrollView.frame.origin.y;
        
        self.pinchAnchor = [[PinchAnchor alloc] initWithScrollViewYCoordinate:yCoordinateInScrollView
                                                           percentDownSubview:percentDownTextView];
        
        NSLog(@"%@", self.pinchAnchor);
        
        [userDefaults setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
        [userDefaults synchronize];
        self.textView.attributedText = self.text;
        [self.view setNeedsLayout];
    }
    
    
}

@end
