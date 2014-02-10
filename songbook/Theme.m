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
    return [UIColor colorWithR:199 G:199 B:204 A:255];
}

+ (UIColor *)darkerGrayColor
{
    return [UIColor colorWithR:127 G:127 B:127 A:255];
}

+ (UIColor *)searchFieldBackgroundColor
{
    return [UIColor colorWithR:0 G:0 B:77 A:25];
}

+ (UIColor *)paperColor
{
    return [UIColor colorWithR:255 G:250 B:244 A:255];
}

+ (UIColor *)textColor
{
    return [UIColor colorWithR:26 G:10 B:0 A:255];
}

@end
