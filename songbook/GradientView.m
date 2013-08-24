//
//  GradientView.m
//  songbook
//
//  Created by Paul Himes on 8/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [(CAGradientLayer*)[self layer] setColors:[self colors]];
        [(CAGradientLayer*)[self layer] setLocations:[self locations]];
    }
    return self;
}

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (NSArray *)colors
{
    UIColor *colorFour = [UIColor colorWithRed:0.89 green:0.15 blue:0.26 alpha:1.0]; // 4
    UIColor *colorThree = [UIColor colorWithRed:0.93 green:0.29 blue:0.36 alpha:1.0]; // 3
    UIColor *colorTwo = [UIColor colorWithRed:0.93 green:0.08 blue:0.19 alpha:1.0]; // 2
    UIColor *colorOne = [UIColor colorWithRed:0.84 green:0.06 blue:0.16 alpha:1.0]; // 1
    
    return @[(id)colorThree.CGColor, (id)colorFour.CGColor, (id)colorTwo.CGColor, (id)colorOne.CGColor];
}

- (NSArray *)locations
{
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.01];
    NSNumber *stopThree = [NSNumber numberWithFloat:0.2];
    NSNumber *stopFour = [NSNumber numberWithFloat:0.5];
    
    return @[stopOne, stopTwo, stopThree, stopFour];
}

@end
