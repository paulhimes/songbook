//
//  Theme.h
//  songbook
//
//  Created by Paul Himes on 10/15/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    Light,
    Dark
} ThemeColor;

extern NSString * const kThemeStyleKey;

@interface Theme : NSObject

+ (ThemeColor)currentThemeColor;
+ (void)setCurrentThemeColor:(ThemeColor)themeColor;

+ (UIColor *)redColor;
+ (UIColor *)coverColorOne;
+ (UIColor *)coverColorTwo;
+ (UIColor *)grayTrimColor;
+ (UIColor *)fadedTextColor;
+ (UIColor *)paperColor;
+ (UIColor *)textColor;

+ (NSString *)normalFontFamily;
+ (NSString *)boldFontFamily;

@end
