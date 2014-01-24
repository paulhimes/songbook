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
    CGRect fragmentRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
    CGPoint glyphLocation = [self.layoutManager locationForGlyphAtIndex:glyphIndex];
    
    // Convert to the text container's coordinate space.
    glyphLocation.x += CGRectGetMinX(fragmentRect);
    glyphLocation.y += CGRectGetMinY(fragmentRect);
    
    // Convert to the text view's coordinate space.
    glyphLocation.x += self.textContainerInset.left;
    glyphLocation.y += self.textContainerInset.top;
    
    return glyphLocation;
}

- (CGFloat)contentHeight
{
    CGFloat textViewTopContainerInset = self.textContainerInset.top;
    CGFloat textViewBottomContainerInset = self.textContainerInset.bottom;
    CGRect textViewContentRect = [self.layoutManager usedRectForTextContainer:self.textContainer];
    CGFloat textViewTextKitHeight = textViewContentRect.size.height + textViewTopContainerInset + textViewBottomContainerInset;
    return textViewTextKitHeight;
}

@end
