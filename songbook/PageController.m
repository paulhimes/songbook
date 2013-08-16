//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"

static const NSInteger kGutterWidth = 8;

@interface PageController () <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic) BOOL viewDidDisappear;

@end

@implementation PageController
@synthesize titleView = _titleView;

- (TitleView *)titleView
{
    if (!_titleView) {
        _titleView = [self buildTitleView];
    }
    return _titleView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    
    self.titleView.containerWidth = self.view.bounds.size.width - 2 * kGutterWidth;
    
    self.textView = [[UITextView alloc] init];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -kGutterWidth);
    self.textView.clipsToBounds = NO;
    self.textView.delegate = self;
    self.textView.editable = NO;
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsMake(self.titleView.intrinsicContentSize.height, 0, 0, 0);
    self.textView.attributedText = self.text;
    
    [self.view addSubview:self.textView];
    [self.view addSubview:self.titleView];
    
    
    UITextView *textView = self.textView;
    TitleView *titleView = self.titleView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(textView, titleView);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[textView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[textView]-%d-|", kGutterWidth, kGutterWidth]
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[titleView]"
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[titleView]-%d-|", kGutterWidth, kGutterWidth]
                                                                       options:0
                                                                       metrics:nil
                                                                         views:viewsDictionary]];
    
    [self.textView setDebugColor:[UIColor colorWithWhite:0 alpha:0.5]];
    [self.titleView setDebugColor:[UIColor orangeColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewConstraints];
    if (self.viewDidDisappear) {
        self.viewDidDisappear = NO;
        self.textView.contentOffset = CGPointZero;
    }
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateViewConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    self.titleView.containerWidth = self.view.bounds.size.width - 2 * kGutterWidth;
}

@end
