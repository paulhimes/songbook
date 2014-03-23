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
    return [UIColor colorWithR:190 G:25 B:49 A:255];
}

+ (UIColor *)coverColorOne
{
    // Red Duller
    return [UIColor colorWithR:126 G:25 B:40 A:255];
}

+ (UIColor *)coverColorTwo
{
    // Red Dullish
    return [UIColor colorWithR:124 G:16 B:32 A:255];
}

+ (UIColor *)grayTrimColor
{
    return [UIColor colorWithR:199 G:191 B:182 A:255];
}

+ (UIColor *)darkerGrayColor
{
    return [UIColor colorWithR:127 G:122 B:116 A:255];
}

+ (UIColor *)searchFieldBackgroundColor
{
    return [UIColor colorWithR:0 G:0 B:0 A:25];
}

+ (UIColor *)paperColor
{
//    return [UIColor colorWithR:255 G:241 B:224 A:255]; // Halogen
//    return [UIColor colorWithR:255 G:245 B:234 A:255]; // Compromise
//    return [UIColor colorWithR:255 G:250 B:244 A:255]; // Carbon Arc
    return [UIColor colorWithR:255 G:244 B:242 A:255]; // Full Spectrum Fluorescent
}

+ (UIColor *)textColor
{
    return [UIColor colorWithR:0 G:0 B:0 A:255];
}

@end
