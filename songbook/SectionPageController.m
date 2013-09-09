//
//  SectionPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SectionPageController.h"

@interface SectionPageController ()

@property (strong, nonatomic) Section *section;

@end

@implementation SectionPageController

- (instancetype)initWithSection:(Section *)section
{
    self = [super init];
    if (self) {
        self.section = section;
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.section;
}

- (NSAttributedString *)text
{
    NSNumber *standardTextSizeNumber = [[NSUserDefaults standardUserDefaults] objectForKey:kStandardTextSizeKey];
    CGFloat standardTextSize = [standardTextSizeNumber floatValue];
    
    return [[NSAttributedString alloc] initWithString:self.section.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:standardTextSize * 1.75]}];
}

@end
