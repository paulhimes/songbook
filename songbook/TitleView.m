//
//  TitleView.m
//  songbook
//
//  Created by Paul Himes on 8/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitleView.h"

@implementation TitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)setContainerWidth:(CGFloat)containerWidth
{
    _containerWidth = containerWidth;
    [self resetRectangleCalculations];
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)resetRectangleCalculations
{
    
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(self.containerWidth, 50);
}

@end
