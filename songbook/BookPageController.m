//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"

@interface BookPageController ()

@property (strong, nonatomic) Book *book;

@end

@implementation BookPageController

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
        CAGradientLayer *bgLayer = [BookPageController gradientLayerA];
        bgLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:bgLayer atIndex:0];
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.book;
}

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:self.book.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:40],
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSTextEffectAttributeName: NSTextEffectLetterpressStyle}];
}

+ (CAGradientLayer*)gradientLayerA
{
    UIColor *colorFour = [UIColor colorWithRed:0.89 green:0.15 blue:0.26 alpha:1.0]; // 4
    UIColor *colorThree = [UIColor colorWithRed:0.93 green:0.29 blue:0.36 alpha:1.0]; // 3
    UIColor *colorTwo = [UIColor colorWithRed:0.93 green:0.08 blue:0.19 alpha:1.0]; // 2
    UIColor *colorOne = [UIColor colorWithRed:0.84 green:0.06 blue:0.16 alpha:1.0]; // 1
    
    NSArray *colors = @[(id)colorThree.CGColor, (id)colorFour.CGColor, (id)colorTwo.CGColor, (id)colorOne.CGColor];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:0.01];
    NSNumber *stopThree = [NSNumber numberWithFloat:0.2];
    NSNumber *stopFour = [NSNumber numberWithFloat:0.5];
    
    NSArray *locations = @[stopOne, stopTwo, stopThree, stopFour];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    
    return gradientLayer;
}

+ (CAGradientLayer*)gradientLayerB
{
    UIColor *colorTwo = [UIColor colorWithRed:0.93 green:0.08 blue:0.19 alpha:1.0]; // 2
    UIColor *colorOne = [UIColor colorWithRed:0.84 green:0.06 blue:0.16 alpha:1.0]; // 1
    
    NSArray *colors = @[(id)colorTwo.CGColor, (id)colorOne.CGColor];
    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];
    
    NSArray *locations = @[stopOne, stopTwo];
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = colors;
    gradientLayer.locations = locations;
    
    return gradientLayer;
}

@end
