//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "AppDelegate.h"

static const NSInteger kGutterWidth = 8;

const CGFloat kToolbarHeight = 44;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIToolbar *backgroundToolbar;

@end

@implementation PageController
@synthesize titleView = _titleView;

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

- (UIToolbar *)backgroundToolbar
{
    if (!_backgroundToolbar) {
        _backgroundToolbar = [[UIToolbar alloc] init];
        _backgroundToolbar.delegate = self;
        _backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _backgroundToolbar.barTintColor = [UIColor whiteColor];
        _backgroundToolbar.alpha = 0;
    }
    return _backgroundToolbar;
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
    }
    return _textView;
}

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (TitleView *)buildTitleView
{
    return [[TitleView alloc] init];
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
    
    self.backgroundToolbar.frame = CGRectMake(0,
                                              0,
                                              self.view.bounds.size.width,
                                              self.titleView.frame.size.height);
    
    self.textView.attributedText = self.text;
    self.textView.frame = CGRectMake(0, 0, contentWidth, 0);
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];
    [self.view addSubview:self.backgroundToolbar];
    [self.backgroundToolbar addSubview:self.titleView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update any frames and view properties that the normal layout system (autolayout or autoresize) can't handle.

    NSLog(@"Laid out view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
    NSLog(@"contentwidth = %f", contentWidth);
    
    [self.titleView setHeight:[self.titleView sizeForWidth:self.titleView.frame.size.width].height];
    [self.backgroundToolbar setHeight:self.titleView.frame.size.height];
    
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.backgroundToolbar.frame.size.height, 0, kToolbarHeight, -kGutterWidth);
    
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(self.textView.frame.size.width, CGFLOAT_MAX)];
    [self.textView setHeight:textSize.height];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, MAX(self.scrollView.frame.size.height - (self.scrollView.contentInset.top + self.scrollView.contentInset.bottom), textSize.height));
    
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
        self.backgroundToolbar.alpha = 0;
        self.scrollView.showsVerticalScrollIndicator = NO;
    } else {
        self.backgroundToolbar.alpha = 1;
        self.scrollView.showsVerticalScrollIndicator = YES;
    }

//    NSLog(@"scrollview offset y = %f [%@]", offsetY, [self textFragment]);
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
