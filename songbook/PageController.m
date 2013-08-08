//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"

const NSUInteger kGutterWidth = 10;

@interface PageController ()

@property (nonatomic, strong) PageView *pageView;

@end

@implementation PageController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
    [self.view addSubview:scrollView];
    
    PageView *pageView = [self buildPageView];
    pageView.containerSize = CGSizeMake(self.view.bounds.size.width - 2 * kGutterWidth, self.view.bounds.size.height);
    [scrollView addSubview:pageView];
    self.pageView = pageView;
        
    scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scrollView, pageView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[scrollView]-%d-|", kGutterWidth, kGutterWidth]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[pageView]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    [scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[pageView]|"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    
    [scrollView setDebugColor:[UIColor colorWithWhite:0 alpha:0.1]];
}

- (PageView *)buildPageView
{
    return [[PageView alloc] init];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.pageView.containerSize = CGSizeMake(self.view.bounds.size.width - 2 * kGutterWidth, self.view.bounds.size.height);
    
}

@end
