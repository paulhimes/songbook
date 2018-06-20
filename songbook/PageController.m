//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "songbook-Swift.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

static NSString * const kBookmarkedGlyphIndexKey = @"BookmarkedGlyphIndexKey";
static NSString * const kBookmarkedGlyphYOffsetKey = @"BookmarkedGlyphYOffsetKey";

const float kSuperMaximumStandardTextSize = 100;
const float kMaximumStandardTextSize = 100;
const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

@end

@implementation PageController

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (void)setHighlightRange:(NSRange)highlightRange
{
    _highlightRange = highlightRange;
    [self textContentChanged];
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
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.textView.clipsToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];

    [self updateThemedElements];
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSUserDefaultsDidChangeNotification]) {
        [Theme loadFontNamed:Theme.normalFontName completion:^{
            [self textContentChanged];
        }];
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)updateThemedElements
{
    
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

- (UIColor *)pageControlColor
{
    return [Theme redColor];
}

@end
