//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"

const NSInteger kGutterWidth = 8;

@interface PageController () <UIScrollViewDelegate>

@property (nonatomic, strong) PageView *pageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic) BOOL viewDidDisappear;
@property (nonatomic) BOOL headerVisible;

@end

@implementation PageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, -kGutterWidth);
    self.scrollView.clipsToBounds = NO;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    
    self.pageView = [self buildPageView];
    self.pageView.containerSize = CGSizeMake(self.view.bounds.size.width - 2 * kGutterWidth, self.view.bounds.size.height);
    [self.scrollView addSubview:self.pageView];
    
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIScrollView *scrollView = self.scrollView;
    PageView *pageView = self.pageView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, pageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[scrollView]-%d-|", kGutterWidth, kGutterWidth]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    [self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    
    [self.scrollView setDebugColor:[UIColor colorWithWhite:0 alpha:0.05]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewConstraints];
    if (self.viewDidDisappear) {
        self.viewDidDisappear = NO;
        self.scrollView.contentOffset = CGPointZero;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    self.viewDidDisappear = YES;
}

- (PageView *)buildPageView
{
    return [[PageView alloc] init];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    self.pageView.containerSize = CGSizeMake(self.view.bounds.size.width - 2 * kGutterWidth, self.view.bounds.size.height);
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > self.pageView.headerHeight) {
        if (self.headerVisible) {
            self.headerVisible = NO;
            NSLog(@"%@", @"Show title");
            [self setTitleVisible:YES];
        }
    } else {
        if (!self.headerVisible) {
            self.headerVisible = YES;
            NSLog(@"%@", @"Hide title");
            [self setTitleVisible:NO];
        }
    }
}

- (void)setTitleVisible:(BOOL)visible
{
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@""];
    
    [self.delegate pageController:self contentTitleChangedTo:[attributedTitle copy]];
}

@end
