//
//  SuperScrollIndicator.m
//  songbook
//
//  Created by Paul Himes on 2/16/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "SuperScrollIndicator.h"
#import "songbook-Swift.h"

static const NSUInteger kMinimumIndicatorHeight = 88;
static const NSUInteger kIndicatorMinimumMargin = 4;


@interface SuperScrollIndicator()

@property (nonatomic, strong) UIColor *normalBackgroudColor;
@property (nonatomic, strong) UIColor *normalScrollIndicatorColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedScrollIndicatorColor;

@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL enabled;

@property (nonatomic) CGFloat scrolledPercent;
@property (nonatomic) NSUInteger scrollIndicatorHeight;

@property (nonatomic) CGFloat indicatorTopMargin;
@property (nonatomic) CGFloat indicatorBottomMargin;

@end

@implementation SuperScrollIndicator

- (CGFloat)indicatorTopMargin
{
    return MAX(kIndicatorMinimumMargin, self.layoutMargins.top);
}

- (CGFloat)indicatorBottomMargin
{
    return MAX(kIndicatorMinimumMargin, self.layoutMargins.bottom);
}

- (UIColor *)normalBackgroudColor
{
    if (!_normalBackgroudColor) {
        _normalBackgroudColor = [UIColor clearColor];
    }
    return _normalBackgroudColor;
}

- (UIColor *)normalScrollIndicatorColor
{
    if (!_normalScrollIndicatorColor) {
        _normalScrollIndicatorColor = [[Theme fadedTextColor] colorWithAlphaComponent:0.25];
    }
    return _normalScrollIndicatorColor;
}

- (UIColor *)highlightedBackgroundColor
{
    if (!_highlightedBackgroundColor) {
        _highlightedBackgroundColor = [Theme grayTrimColor];
    }
    return _highlightedBackgroundColor;
}

- (UIColor *)highlightedScrollIndicatorColor
{
    if (!_highlightedScrollIndicatorColor) {
        _highlightedScrollIndicatorColor = self.tintColor;
    }
    return _highlightedScrollIndicatorColor;
}

- (NSUInteger)scrollIndicatorHeight
{
    if (_scrollIndicatorHeight < kMinimumIndicatorHeight && _scrollIndicatorHeight > 0) {
        _scrollIndicatorHeight = kMinimumIndicatorHeight;
    }
    return _scrollIndicatorHeight;
}

- (void)scrollToPercent:(CGFloat)percent
{
    percent = MAX(0.0, MIN(1.0, percent));
    self.scrolledPercent = percent;
    [self setNeedsDisplay];
}

- (void)setScrollViewContentHeight:(CGFloat)scrollViewContentHeight andFrameHeight:(CGFloat)scrollViewFrameHeight
{
    CGFloat percent = scrollViewFrameHeight / scrollViewContentHeight;
    percent = MAX(0, MIN(1, percent));
    CGFloat scrollIndicatorHeight = rintf((self.bounds.size.height - (self.indicatorTopMargin + self.indicatorBottomMargin)) * percent);
    self.scrollIndicatorHeight = scrollIndicatorHeight;
    self.enabled = self.scrollIndicatorHeight < self.bounds.size.height * 0.75;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // Draw the background.
    UIColor *backgroundColor = self.highlighted && self.enabled ? self.highlightedBackgroundColor : self.normalBackgroudColor;
    [backgroundColor setFill];
    [[UIBezierPath bezierPathWithRect:self.bounds] fill];
    
    if (self.enabled) {
        // Draw the scroll indicator.
        UIColor *scrollIndicatorColor = self.highlighted ? self.highlightedScrollIndicatorColor : self.normalScrollIndicatorColor;
        CGFloat scrollIndicatorTopY = (self.bounds.size.height - self.scrollIndicatorHeight - (self.indicatorTopMargin + self.indicatorBottomMargin)) * self.scrolledPercent + self.indicatorTopMargin;
        UIBezierPath *scrollIndicatorPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(kIndicatorMinimumMargin, scrollIndicatorTopY, self.bounds.size.width - (2 * kIndicatorMinimumMargin), self.scrollIndicatorHeight) cornerRadius:3];
        [scrollIndicatorColor setFill];
        [scrollIndicatorPath fill];
    }
}

#pragma mark - Handle Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.enabled) {
        UITouch *touch = [touches anyObject];
        CGFloat yLocation = [touch locationInView:self].y;
        CGFloat percentScrolled = [self percentAcrossTouchRange:yLocation];
        [self.delegate superScrollIndicator:self didScrollToPercent:percentScrolled];
        self.highlighted = YES;
        [self setNeedsDisplay];
    } else {
        self.highlighted = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.enabled) {
        UITouch *touch = [touches anyObject];
        CGFloat yLocation = [touch locationInView:self].y;
        CGFloat percentScrolled = [self percentAcrossTouchRange:yLocation];
        [self.delegate superScrollIndicator:self didScrollToPercent:percentScrolled];
    } else {
        self.highlighted = NO;
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    [self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    [self setNeedsDisplay];
}

#pragma mark - Helper Methods

- (CGFloat)percentAcrossTouchRange:(CGFloat)yCoordinate
{
    CGFloat minYCoordinate = (self.scrollIndicatorHeight / 2) + self.indicatorTopMargin;
    CGFloat maxYCoordinate = self.bounds.size.height - (self.scrollIndicatorHeight / 2) - self.indicatorBottomMargin;
    
    CGFloat totalRange = self.bounds.size.height - self.scrollIndicatorHeight - (self.indicatorTopMargin + self.indicatorBottomMargin);
    
    // Pin the y location to the active range.
    if (yCoordinate < minYCoordinate) {
        yCoordinate = minYCoordinate;
    }
    if (yCoordinate > maxYCoordinate) {
        yCoordinate = maxYCoordinate;
    }
    
    // Calculate the percent across the active range.
    CGFloat percent = (yCoordinate - minYCoordinate) / totalRange;
    percent = MIN(1, MAX(0, percent));
    return percent;
}


@end
