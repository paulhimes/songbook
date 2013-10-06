//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

static const float kMaximumStandardTextSize = 40;
static const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) NSNumber *gestureStartTextSize;
@property (nonatomic) BOOL shouldLockScrolling;
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
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Update any frames and view properties that the normal layout system (autolayout or autoresize) can't handle.
    
    if (self.shouldLockScrolling) {
        
        CGFloat currentYCoordinateOfGlyphInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];

        CGFloat glyphVerticalError = self.glyphYCoordinateInMainView - currentYCoordinateOfGlyphInMainView;
        
//        NSLog(@"Glyph vertical error %f", glyphVerticalError);
        
        CGFloat contentOffsetY = self.textView.contentOffset.y - glyphVerticalError;
        
        // Limit the content offset to the actual content size.
        CGFloat minimumContentOffset = 0;
        CGFloat maximumContentOffset = MAX(self.textView.contentSize.height - self.textView.frame.size.height, 0);
        
        contentOffsetY = MIN(maximumContentOffset, MAX(minimumContentOffset, contentOffsetY));
        
//        NSLog(@"contentOffsetY %f", contentOffsetY);
        
        self.textView.contentOffset = CGPointMake(self.textView.contentOffset.x, contentOffsetY);
    }
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.textView.contentOffset = CGPointZero;
}

#pragma mark - UIGestureRecognizer target
- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.gestureStartTextSize = [userDefaults objectForKey:kStandardTextSizeKey];
        
        CGPoint gesturePoint = [sender locationInView:self.textView];
        
        NSLog(@"TextView Point = %@", NSStringFromCGPoint(gesturePoint));
        
        // Convert to the text container's coordinate space.
        gesturePoint.x -= self.textView.textContainerInset.left;
        gesturePoint.y -= self.textView.textContainerInset.top;
        
        self.glyphIndex = [self.textView.layoutManager glyphIndexForPoint:gesturePoint inTextContainer:self.textView.textContainer fractionOfDistanceThroughGlyph:NULL];
        
//        NSString *touchedString = [self.textView.text substringWithRange:NSMakeRange([self.textView.layoutManager characterIndexForGlyphAtIndex:self.glyphIndex], 5)];
//        NSLog(@"glyph index %d [%@]", self.glyphIndex, touchedString);
        
        self.glyphOriginalYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];

        self.touchStartPoint = [sender locationInView:self.view];
        
        
        self.shouldLockScrolling = YES;
    } else if (sender.state == UIGestureRecognizerStateEnded ||
               sender.state == UIGestureRecognizerStateCancelled ||
               sender.state == UIGestureRecognizerStateFailed) {
        [userDefaults synchronize];
        self.shouldLockScrolling = NO;
        self.glyphIndex = 0;
        self.glyphOriginalYCoordinateInMainView = 0;
        self.glyphYCoordinateInMainView = 0;
        self.touchStartPoint = CGPointZero;
    } else {
        
        // Scale the existing text size by the gesture recognizer's scale.
        float scaledSize = [self.gestureStartTextSize floatValue] * sender.scale;
        
        // Limit the scaled size to sane bounds.
        float scaledAndLimitedSize = MIN(kMaximumStandardTextSize, MAX(kMinimumStandardTextSize, scaledSize));
        
        //        self.glyphYCoordinateInMainView = [self yCoordinateInMainViewOfGlyphAtIndex:self.glyphIndex];
        
        CGPoint updatedTouchPoint = [sender locationInView:self.view];
        
        CGFloat touchPointVerticalShift = updatedTouchPoint.y - self.touchStartPoint.y;
        
        self.glyphYCoordinateInMainView = self.glyphOriginalYCoordinateInMainView + touchPointVerticalShift;
        
        
        if (![@(scaledAndLimitedSize) isEqualToNumber:[userDefaults objectForKey:kStandardTextSizeKey]]) {
            
            [userDefaults setObject:@(scaledAndLimitedSize) forKey:kStandardTextSizeKey];
            NSAttributedString *text = self.text;
            self.textView.attributedText = text;
        }
        
        [self.view setNeedsLayout];
    }
}

- (CGFloat)yCoordinateInMainViewOfGlyphAtIndex:(NSUInteger)glyphIndex
{
    CGRect fragmentRect = [self.textView.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    CGPoint glyphLocation = [self.textView.layoutManager locationForGlyphAtIndex:glyphIndex];
    glyphLocation.x += CGRectGetMinX(fragmentRect);
    glyphLocation.y += CGRectGetMinY(fragmentRect);
    
//    NSLog(@"Glyph Point (container) = %@", NSStringFromCGPoint(glyphLocation));
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textView.textContainerInset.left;
    glyphLocation.y += self.textView.textContainerInset.top;
    
//    NSLog(@"Glyph Point (view) = %@", NSStringFromCGPoint(glyphLocation));
    
    
    //        CGFloat percentDownTextView = glyphLocation.y / self.textView.frame.size.height;
    
    CGPoint glyphLocationInMainView = [self.view convertPoint:glyphLocation fromView:self.textView];
    
//    NSLog(@"Glyph Point (main view) = %@", NSStringFromCGPoint(glyphLocationInMainView));
    
    return glyphLocationInMainView.y;
}

#pragma mark - Action Methods
- (IBAction)searchAction:(UIButton *)sender
{
    [self.delegate search];
}

@end
