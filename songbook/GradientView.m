//
//  GradientView.m
//  songbook
//
//  Created by Paul Himes on 8/24/13.
//

#import "GradientView.h"
#import "songbook-Swift.h"

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
    UIColor *colorOne = [Theme coverColorOne];
    UIColor *colorTwo = [Theme coverColorTwo];
    
    return @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
}

- (NSArray *)locations
{
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    return @[stopOne, stopTwo];
}

@end
