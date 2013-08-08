//
//  UIView+Debug.m
//  songbook
//
//  Created by Paul Himes on 8/3/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "UIView+Debug.h"

@implementation UIView (Debug)

- (void)setDebugColor:(UIColor *)color
{
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
}

@end
