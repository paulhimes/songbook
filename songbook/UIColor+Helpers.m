//
//  UIColor+Helpers.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import "UIColor+Helpers.h"

@implementation UIColor (Helpers)

+ (UIColor *)colorWithR:(NSUInteger)red G:(NSUInteger)green B:(NSUInteger)blue A:(NSUInteger)alpha
{
    red = MIN(255, MAX(0, red));
    green = MIN(255, MAX(0, green));
    blue = MIN(255, MAX(0, blue));
    alpha = MIN(255, MAX(0, alpha));
    
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha/255.0];
}

@end
