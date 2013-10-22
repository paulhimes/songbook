//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "PageController+Private.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

const float kSuperMaximumStandardTextSize = 60;
const float kMaximumStandardTextSize = 40;
const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation PageController

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGesture:)];
    }
    return _pinchGestureRecognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.attributedText = self.text;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.textView.clipsToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNotification:) name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNotification:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSUserDefaultsDidChangeNotification]) {
        [self textContentChanged];
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

#pragma mark - Action Methods
- (IBAction)searchAction:(UIButton *)sender
{
    [self.delegate search];
}

@end
