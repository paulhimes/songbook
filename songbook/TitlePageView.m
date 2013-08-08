//
//  TitlePageView.m
//  songbook
//
//  Created by Paul Himes on 8/5/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageView.h"

@implementation TitlePageView

- (CGSize)intrinsicContentSize
{
    CGSize superSize = [super intrinsicContentSize];
    
    if (superSize.height > self.containerSize.height) {
        return superSize;
    } else {
        return self.containerSize;
    }
}

- (void)drawRect:(CGRect)rect
{
    if ([self intrinsicContentSize].height > self.containerSize.height) {
        return [super drawRect:rect];
    }
    
    // Drawing code
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];
    
    // Vertically center the title at the golden ratio. Shift up if the title overflows the container.
    CGFloat desiredVerticalCenter = self.containerSize.height / M_PHI;
    
    CGRect stringRect = [self.text boundingRectWithSize:CGSizeMake(self.containerSize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    CGFloat halfStringHeight = stringRect.size.height / 2.0;
    
    CGRect drawingRect;
    if (desiredVerticalCenter + halfStringHeight > self.containerSize.height) {
        // Just draw bottom aligned.
        drawingRect = CGRectMake(0, self.containerSize.height - stringRect.size.height, self.containerSize.width, stringRect.size.height);
    } else {
        // Draw centered at the golden ratio.
        drawingRect = CGRectMake(0, desiredVerticalCenter - halfStringHeight, self.containerSize.width, stringRect.size.height);
    }
    
    [self.text drawWithRect:drawingRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
}

@end
