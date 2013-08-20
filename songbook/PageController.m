//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "SongbookTextView.h"
#import "AppDelegate.h"

static const NSInteger kGutterWidth = 8;

const CGFloat kToolbarHeight = 44;

@interface PageController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic) BOOL viewDidDisappear;
@property (nonatomic, strong) UIView *headerView;

@property (nonatomic) BOOL firstWillAppearHappened;

@end

@implementation PageController
@synthesize titleView = _titleView;

- (TitleView *)titleView
{
    if (!_titleView) {
        _titleView = [self buildTitleView];
        _titleView.userInteractionEnabled = NO;
        _titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _titleView;
}

- (UIView *)headerView
{
    if (!_headerView) {
        _headerView = [[UIView alloc] init];
        _headerView.userInteractionEnabled = NO;
        _headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    }
    return _headerView;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[SongbookTextView alloc] init];
        _textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -kGutterWidth);
        _textView.clipsToBounds = NO;
        _textView.alwaysBounceVertical = YES;
        _textView.delegate = self;
        _textView.editable = NO;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _textView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.viewDidDisappear || !self.firstWillAppearHappened) {
        self.viewDidDisappear = NO;
//        NSLog(@"%@", self.textView.text);
        self.textView.contentOffset = CGPointMake(0, kToolbarHeight);
    }
    
    NSLog(@"%@ %@", @"ViewWillAppear", [self textFragment]);

    self.firstWillAppearHappened = YES;
}

- (void)viewWillLayoutSubviews
{
    NSLog(@"%@ %@", @"ViewWillLayoutSubviews", [self textFragment]);
}

- (void)viewDidLayoutSubviews
{
    NSLog(@"%@ %@", @"ViewDidLayoutSubviews", [self textFragment]);
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"%@ %@", @"ViewDidAppear A", [self textFragment]);
    [super viewDidAppear:animated];
    NSLog(@"%@ %@", @"ViewDidAppear B", [self textFragment]);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.viewDidDisappear = YES;
}

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (TitleView *)buildTitleView
{
    TitleView *titleView = [[TitleView alloc] init];
    titleView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.9];
    return titleView;
}

- (void)loadView
{    
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:applicationFrame];
    NSLog(@"Load view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.headerView];
    [self.headerView addSubview:self.titleView];
    
    [self.headerView setDebugColor:[UIColor brownColor]];
    [self.textView setDebugColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.titleView setDebugColor:[UIColor orangeColor]];
    
    
    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
    
    self.textView.frame = CGRectMake(kGutterWidth,
                                     0,
                                     contentWidth,
                                     self.view.bounds.size.height);
    
    self.headerView.frame = CGRectMake(kGutterWidth,
                                       -kToolbarHeight,
                                       contentWidth,
                                       [self.titleView sizeForWidth:contentWidth].height + kToolbarHeight);
    if (self.textView.contentOffset.y < kToolbarHeight) {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                           -self.textView.contentOffset.y,
                                           self.headerView.frame.size.width,
                                           self.headerView.frame.size.height);
    } else {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                           -kToolbarHeight,
                                           self.headerView.frame.size.width,
                                           self.headerView.frame.size.height);
    }
    NSLog(@"Header view initialized to %@ %@", NSStringFromCGRect(self.headerView.frame), [self textFragment]);
    
    self.titleView.frame = CGRectMake(0,
                                      kToolbarHeight,
                                      contentWidth,
                                      [self.titleView sizeForWidth:contentWidth].height);
    
    self.textView.textContainerInset = UIEdgeInsetsMake(self.headerView.frame.size.height, 0, 0, 0);
    self.textView.attributedText = self.text;
//    self.textView.contentOffset = CGPointMake(0, kToolbarHeight);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Add code to clean up any of your own resources that are no longer necessary.
    if ([self.view window] == nil)
    {
        // Add code to preserve data stored in the views that might be
        // needed later.
        
        // Add code to clean up other strong references to the view in
        // the view hierarchy.
        self.view = nil;
    }
}

//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    self.textView.contentOffset = CGPointMake(0, kToolbarHeight);
//
//
//    [self.titleView setNeedsDisplay];
//}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%@ %@", @"WillRotateToInterfaceOrientation", [self textFragment]);
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"%@ %@", @"DidRotateFromInterfaceOrientation", [self textFragment]);
}

- (void)showToolbar
{
    [UIView animateWithDuration:0.5 animations:^{
        self.headerView.frame = CGRectMake(kGutterWidth,
                                           0,
                                           self.view.bounds.size.width - 2 * kGutterWidth,
                                           [self.titleView sizeForWidth:self.view.bounds.size.width - 2 * kGutterWidth].height + kToolbarHeight);
    }];
}

- (void)hideToolbar
{
    [UIView animateWithDuration:0.5 animations:^{
        self.headerView.frame = CGRectMake(kGutterWidth,
                                           -kToolbarHeight,
                                           self.view.bounds.size.width - 2 * kGutterWidth,
                                           [self.titleView sizeForWidth:self.view.bounds.size.width - 2 * kGutterWidth].height + kToolbarHeight);
    }];
}

- (NSString *)textFragment
{
    NSString *string = self.text.string;
    
    if ([string length] > 15) {
        string = [string substringToIndex:15];
    }
    
    return string;
}

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
////    NSLog(@"%f", scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < kToolbarHeight) {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                           -scrollView.contentOffset.y,
                                           self.headerView.frame.size.width,
                                           self.headerView.frame.size.height);
    } else {
        self.headerView.frame = CGRectMake(self.headerView.frame.origin.x,
                                           -kToolbarHeight,
                                           self.headerView.frame.size.width,
                                           self.headerView.frame.size.height);
    }
    
    NSLog(@" Offset = %@ %@", NSStringFromCGPoint(scrollView.contentOffset), [self textFragment]);
    
    if (scrollView.contentOffset.y < -150) {
        int stop = 1;
    }
}

@end
