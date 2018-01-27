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
} ThemeStyle;

extern NSString * const kThemeStyleKey;

@interface Theme : NSObject

+ (ThemeStyle)currentThemeStyle;
+ (void)setCurrentThemeStyle:(ThemeStyle)themeStyle;

+ (UIColor *)redColor;
+ (UIColor *)coverColorOne;
+ (UIColor *)coverColorTwo;
+ (UIColor *)grayTrimColor;
+ (UIColor *)fadedTextColor;
+ (UIColor *)paperColor;
+ (UIColor *)textColor;

@end
