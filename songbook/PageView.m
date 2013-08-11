//
//  PageView.m
//  songbook
//
//  Created by Paul Himes on 7/31/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageView.h"
#import "Verse.h"

@interface PageView()

@end

@implementation PageView

- (UIFont *)font
{
    return [UIFont fontWithName:@"Marion" size:20];
}

- (CGFloat)headerHeight
{
    return self.intrinsicContentSize.height;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.opaque = NO;
        [self setDebugColor:[UIColor colorWithRed:0 green:1 blue:0 alpha:0.1]];
    }
    return self;
}

- (void)setContainerSize:(CGSize)containerSize
{
    _containerSize = containerSize;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (CGSize)intrinsicContentSize
{
    CGRect stringRect = [self.text boundingRectWithSize:CGSizeMake(self.containerSize.width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
    return CGSizeMake(self.containerSize.width, stringRect.size.height);
}

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [[UIColor blackColor] setFill];
    [[UIColor blackColor] setStroke];
    
    [self.text drawWithRect:CGRectMake(0, 0, self.intrinsicContentSize.width, self.intrinsicContentSize.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.font} context:nil];
}

@end
