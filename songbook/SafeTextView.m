//
//  SafeTextView.m
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SafeTextView.h"

@implementation SafeTextView

- (void)setContentOffset:(CGPoint)contentOffset animated:(BOOL)animated
{
    if (!self.contentOffsetCallsAllowed) {
        return;
    }
    
    [super setContentOffset:contentOffset animated:animated];
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    if (!self.contentOffsetCallsAllowed) {
        return;
    }
    
    [super setContentOffset:contentOffset];
}

- (void)forceContentOffset:(CGPoint)contentOffset
{
    [super setContentOffset:contentOffset];
}

- (CGPoint)locationForGlyphAtIndex:(NSUInteger)glyphIndex
{
    // Glyph bounds in text container coordinate space.
    CGRect glyphRect = [self.layoutManager boundingRectForGlyphRange:NSMakeRange(glyphIndex, 1) inTextContainer:self.textContainer];
    
    CGPoint glyphLocation = glyphRect.origin;
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textContainerInset.left;
    glyphLocation.y += self.textContainerInset.top;

    // Compensate for the text view's content offset.
    glyphLocation.x -= self.contentOffset.x;
    glyphLocation.y -= self.contentOffset.y;
    
    return glyphLocation;
}

- (NSUInteger)glyphIndexClosestToPoint:(CGPoint)point
{
    // Convert to the text container's coordinate space.
    point.x -= self.textContainerInset.left;
    point.y -= self.textContainerInset.top;
    
    return [self.layoutManager glyphIndexForPoint:point inTextContainer:self.textContainer fractionOfDistanceThroughGlyph:NULL];
}

@end
