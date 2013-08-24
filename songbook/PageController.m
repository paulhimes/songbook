//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "AppDelegate.h"

static const NSInteger kGutterWidth = 16;

const CGFloat kToolbarHeight = 44;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIToolbar *foregroundToolbar;

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
//        [_scrollView setDebugColor:[UIColor magentaColor]];
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
    NSLog(@"contentwidth = %f", contentWidth);
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
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];
    
    if (self.titleView) {
        [self.view addSubview:self.foregroundToolbar];
        [self.foregroundToolbar addSubview:self.titleView];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update any frames and view properties that the normal layout system (autolayout or autoresize) can't handle.

    NSLog(@"Laid out view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
    NSLog(@"contentwidth = %f", contentWidth);
    
    [self.titleView setHeight:[self.titleView sizeForWidth:self.titleView.frame.size.width].height];
    [self.foregroundToolbar setHeight:self.titleView.frame.size.height];
    
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.foregroundToolbar.frame.size.height, 0, kToolbarHeight, -kGutterWidth);
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    [self.textView setHeight:textSize.height];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom), CGRectGetMaxY(self.textView.frame)));
    
    CGFloat titleContentOriginY = self.titleView.contentOriginY;
    NSLog(@"titleContentOriginY %f", titleContentOriginY);
    self.textView.textContainerInset = UIEdgeInsetsMake(titleContentOriginY, 0, 0, 0);
    
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

@end
