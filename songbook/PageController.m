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

static const float kMaximumStandardTextSize = 40;
static const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) NSNumber *gestureStartTextSize;
@property (nonatomic) NSUInteger glyphIndex;
@property (nonatomic) CGFloat glyphOriginalYCoordinateInMainView;
@property (nonatomic) CGFloat glyphYCoordinateInMainView;
@property (nonatomic) CGPoint touchStartPoint;

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
    [self textContentChanged];
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
        CGPoint gesturePoint = [sender locationInView:self.textView];

        // Convert to the text container's coordinate space.
        gesturePoint.x -= self.textView.textContainerInset.left;
        gesturePoint.y -= self.textView.textContainerInset.top;
        
        self.glyphIndex = [self.textView.layoutManager glyphIndexForPoint:gesturePoint inTextContainer:self.textView.textContainer fractionOfDistanceThroughGlyph:NULL];

        self.glyphOriginalYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];

        self.touchStartPoint = [sender locationInView:self.view];

    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        [userDefaults synchronize];
        self.glyphIndex = 0;
        self.glyphOriginalYCoordinateInMainView = 0;
        self.glyphYCoordinateInMainView = 0;
        self.touchStartPoint = CGPointZero;
        
        [UIView animateWithDuration:1 animations:^{
            // Limit the content offset to the actual content size.
            CGFloat minimumContentOffset = 0;
            CGFloat maximumContentOffset = MAX(self.textView.contentSize.height - self.textView.frame.size.height, 0);
            CGFloat contentOffsetY = self.textView.contentOffset.y;
            contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
            self.textView.contentOffset = CGPointMake(self.textView.contentOffset.x, contentOffsetY);
        }];
    } else {
        
        // Scale the existing text size by the gesture recognizer's scale.
        float scaledSize = [self.gestureStartTextSize floatValue] * sender.scale;
        
        // Limit the scaled size to sane bounds.
        float scaledAndLimitedSize = MIN(kMaximumStandardTextSize, MAX(kMinimumStandardTextSize, scaledSize));
        
        CGPoint updatedTouchPoint = [sender locationInView:self.view];
        CGFloat touchPointVerticalShift = updatedTouchPoint.y - self.touchStartPoint.y;
        self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;

        if (![@(scaledAndLimitedSize) isEqualToNumber:[userDefaults objectForKey:kStandardTextSizeKey]]) {
            
            [userDefaults setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
            NSAttributedString *text = self.text;
            self.textView.attributedText = text;
            [self textContentChanged];

        }
        
        CGFloat currentYCoordinateOfGlyphInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];
        CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
        CGFloat contentOffsetY = self.textView.contentOffset.y - glyphVerticalError;

        NSLog(@"contentOffsetY %f", contentOffsetY);
        
        self.textView.contentOffset = CGPointMake(self.textView.contentOffset.x, contentOffsetY);
        
    }
}

- (CGFloat)yCoordinateInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGRect fragmentRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];

    CGPoint glyphLocation = [self.textView.layoutManager locationForGlyphAtIndex:glyphIndex];
    glyphLocation.x += CGRectGetMinX(fragmentRect);
    glyphLocation.y += CGRectGetMinY(fragmentRect);
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textView.textContainerInset.left;
    glyphLocation.y += self.textView.textContainerInset.top;

    CGPoint glyphLocationInMainView = [self.view convertPoint:glyphLocation fromView:self.textView];

    return glyphLocationInMainView.y;
}

#pragma mark - Action Methods
- (IBAction)searchAction:(UIButton *)sender
{
    [self.delegate search];
}

@end
