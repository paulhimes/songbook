//
//  Theme.m
//  songbook
//
//  Created by Paul Himes on 10/15/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Theme.h"

NSString * const kThemeColorKey = @"ThemeColor";
NSString * const kThemeFontKey = @"ThemeFont";

@implementation Theme

+ (ThemeColor)currentThemeColor
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kThemeColorKey];
}

+ (void)setCurrentThemeColor:(ThemeColor)themeColor
{
    [[NSUserDefaults standardUserDefaults] setInteger:themeColor forKey:kThemeColorKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (ThemeFont)currentThemeFont
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:kThemeFontKey];
}

+ (void)setCurrentThemeFont:(ThemeFont)themeFont
{
    [[NSUserDefaults standardUserDefaults] setInteger:themeFont forKey:kThemeFontKey];
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
    switch ([self currentThemeColor]) {
        case Light:
            return [UIColor colorWithR:199 G:199 B:199 A:255];
        case Dark:
            return [UIColor colorWithR:70 G:70 B:70 A:255];
    }
}

+ (UIColor *)fadedTextColor
{
    switch ([self currentThemeColor]) {
        case Light:
            return [[Theme textColor] colorWithAlphaComponent:0.5];
        case Dark:
            return [[Theme textColor] colorWithAlphaComponent:0.7];
    }
}

+ (UIColor *)paperColor
{
    switch ([self currentThemeColor]) {
        case Light:
            return [UIColor whiteColor];
        case Dark:
            return [UIColor blackColor];
    }
}

+ (UIColor *)textColor
{
    switch ([self currentThemeColor]) {
        case Light:
            return [UIColor blackColor];
        case Dark:
            return [UIColor whiteColor];
    }
}

+ (NSString *)normalFontFamily
{
    switch ([self currentThemeFont]) {
        case Marion:
            return @"Marion";
        case Bookman:
            return @"BookmanStd-Light";
    }
}

+ (NSString *)boldFontFamily
{
    switch ([self currentThemeFont]) {
        case Marion:
            return @"Marion-Bold";
        case Bookman:
            return @"BookmanStd-Medium";
    }
}

@end
