//
//  Theme.m
//  songbook
//
//  Created by Paul Himes on 10/15/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Theme.h"

NSString * const kThemeStyleKey = @"ThemeStyle";

@implementation Theme

+ (ThemeStyle)currentThemeStyle
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kThemeStyleKey];
}

+ (void)setCurrentThemeStyle:(ThemeStyle)themeStyle
{
    [[NSUserDefaults standardUserDefaults] setInteger:themeStyle forKey:kThemeStyleKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

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
    switch ([self currentThemeStyle]) {
        case Light:
            return [UIColor colorWithR:199 G:199 B:199 A:255];
        case Dark:
            return [UIColor colorWithR:70 G:70 B:70 A:255];
    }
}

+ (UIColor *)fadedTextColor
{
    switch ([self currentThemeStyle]) {
        case Light:
            return [[Theme textColor] colorWithAlphaComponent:0.5];
        case Dark:
            return [[Theme textColor] colorWithAlphaComponent:0.7];
    }
}

+ (UIColor *)paperColor
{
    switch ([self currentThemeStyle]) {
        case Light:
            return [UIColor whiteColor];
        case Dark:
            return [UIColor blackColor];
    }
}

+ (UIColor *)textColor
{
    switch ([self currentThemeStyle]) {
        case Light:
            return [UIColor blackColor];
        case Dark:
            return [UIColor whiteColor];
    }
}

@end
