//
//  Theme.m
//  songbook
//
//  Created by Paul Himes on 10/15/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Theme.h"

@implementation Theme

+ (UIColor *)redColor
{
    // Red Bright
    return [UIColor colorWithRed:190/255.0 green:25/255.0 blue:49/255.0 alpha:1.0];
}

+ (UIColor *)coverColorOne
{
    // Red Duller
    return [UIColor colorWithRed:126/255.0 green:25/255.0 blue:40/255.0 alpha:1.0];
}

+ (UIColor *)coverColorTwo
{
    // Red Dullish
    return [UIColor colorWithRed:124/255.0 green:16/255.0 blue:32/255.0 alpha:1.0];
}

+ (UIColor *)grayTrimColor
{
    return [UIColor colorWithRed:0.78 green:0.78 blue:0.8 alpha:1.0];
}

+ (UIColor *)darkerGrayColor
{
    return [UIColor colorWithRed:0.72 green:0.72 blue:0.72 alpha:1.0];
}

+ (UIColor *)searchFieldBackgroundColor
{
    return [UIColor colorWithRed:0 green:0 blue:0.3 alpha:0.1];
}

@end
