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

@interface PageController () <UITextViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UIToolbar *backgroundToolbar;

@end

@implementation PageController
@synthesize titleView = _titleView;

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -kGutterWidth);
        _scrollView.clipsToBounds = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_scrollView setDebugColor:[UIColor magentaColor]];
    }
    return _scrollView;
}

- (UIToolbar *)toolbar
{
    if (!_toolbar) {
        _toolbar = [[UIToolbar alloc] init];
        _toolbar.delegate = self;
        
        UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(search)];
        UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(search)];
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"New" style:UIBarButtonItemStyleBordered target:self action:@selector(newSong)];

        _toolbar.items = @[
                           editButton,
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           searchButton,
                           [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           addButton
                           ];
        _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _toolbar.barTintColor = [UIColor whiteColor];
    }
    return _toolbar;
}

- (UIToolbar *)backgroundToolbar
{
    if (!_backgroundToolbar) {
        _backgroundToolbar = [[UIToolbar alloc] init];
        _backgroundToolbar.delegate = self;
        _backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _backgroundToolbar.barTintColor = [UIColor whiteColor];
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
        [_titleView setDebugColor:[UIColor orangeColor]];
    }
    return _titleView;
}

- (UITextView *)textView
{
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.scrollEnabled = NO;
        _textView.editable = NO;
        _textView.textContainer.lineFragmentPadding = 0;
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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
    CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:applicationFrame];
    self.view.clipsToBounds = YES;
    NSLog(@"Load view with bounds %@ %@", NSStringFromCGRect(self.view.bounds), [self textFragment]);
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.textView];
    [self.view addSubview:self.backgroundToolbar];
    [self.backgroundToolbar addSubview:self.toolbar];
    [self.backgroundToolbar addSubview:self.titleView];
    
    CGFloat contentWidth = self.view.bounds.size.width - 2 * kGutterWidth;
    
    self.scrollView.frame = CGRectMake(kGutterWidth,
                                      0,
                                      contentWidth,
                                      self.view.bounds.size.height);
    
    self.titleView.frame = CGRectMake(kGutterWidth,
                                      kToolbarHeight,
                                      contentWidth,
                                      [self.titleView sizeForWidth:contentWidth].height);
    
    self.backgroundToolbar.frame = CGRectMake(0,
                                              0,
                                              self.view.bounds.size.width,
                                              kToolbarHeight + self.titleView.frame.size.height);
    
    self.toolbar.frame = CGRectMake(0,
                                    0,
                                    self.view.bounds.size.width,
                                    kToolbarHeight);

    self.textView.attributedText = self.text;
    CGSize textSize = [self.textView sizeThatFits:CGSizeMake(contentWidth,
                                                             self.scrollView.frame.size.height - self.backgroundToolbar.frame.size.height)];
    
    self.textView.frame = CGRectMake(0, self.backgroundToolbar.frame.size.height, textSize.width, textSize.height);
    self.scrollView.contentSize = CGSizeMake(contentWidth, MAX(self.view.bounds.size.height + kToolbarHeight, textSize.height + self.backgroundToolbar.frame.size.height));
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.backgroundToolbar.frame.size.height, 0, 0, -kGutterWidth);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"%@ %@", @"WillRotateToInterfaceOrientation", [self textFragment]);
    [self.titleView setNeedsDisplay];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"%@ %@", @"DidRotateFromInterfaceOrientation", [self textFragment]);
}

//- (void)showToolbar
//{
//    [UIView animateWithDuration:0.5 animations:^{
//        self.headerView.frame = CGRectMake(kGutterWidth,
//                                           0,
//                                           self.view.bounds.size.width - 2 * kGutterWidth,
//                                           [self.titleView sizeForWidth:self.view.bounds.size.width - 2 * kGutterWidth].height + kToolbarHeight);
//    }];
//}
//
//- (void)hideToolbar
//{
//    [UIView animateWithDuration:0.5 animations:^{
//        self.headerView.frame = CGRectMake(kGutterWidth,
//                                           -kToolbarHeight,
//                                           self.view.bounds.size.width - 2 * kGutterWidth,
//                                           [self.titleView sizeForWidth:self.view.bounds.size.width - 2 * kGutterWidth].height + kToolbarHeight);
//    }];
//}

- (NSString *)textFragment
{
    NSString *string = self.text.string;
    
    if ([string length] > 15) {
        string = [string substringToIndex:15];
    }
    
    return string;
}

- (void)search
{
    NSLog(@"%@", @"Search");
    
    [self.delegate search];
}

- (void)newSong
{
    NSLog(@"%@", @"newSong");
}

#pragma mark - UITextViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    
    // Calculate each y location and height based on the offsetY.
    CGFloat toolbarOriginY = MIN(-offsetY, 0);
    
    CGRect toolbarFrame = self.toolbar.frame;
    toolbarFrame.origin.y = toolbarOriginY;
    self.toolbar.frame = toolbarFrame;
    
    CGFloat titleViewOriginY = MAX(kToolbarHeight - offsetY, 0);
    
    CGRect titleViewFrame = self.titleView.frame;
    titleViewFrame.origin.y = titleViewOriginY;
    self.titleView.frame = titleViewFrame;
    
    CGFloat backgroundToolbarHeight = CGRectGetMaxY(self.titleView.frame);
    
    CGRect backgroundToolbarFrame = self.backgroundToolbar.frame;
    backgroundToolbarFrame.size.height = backgroundToolbarHeight;
    self.backgroundToolbar.frame = backgroundToolbarFrame;
    
    
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(backgroundToolbarHeight, 0, 0, -kGutterWidth);

    NSLog(@"scrollview offset y = %f [%@]", offsetY, [self textFragment]);
}

#pragma mark - UIBarPositioningDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionAny;
}

@end
