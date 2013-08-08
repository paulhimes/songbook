//
//  SectionPageView.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SectionPageView.h"

@implementation SectionPageView

- (UIFont *)font
{
    return [UIFont fontWithName:@"Marion" size:35];
}

- (instancetype)initWithSection:(Section *)section
{
    self = [super init];
    if (self) {
        self.text = [self stringFromSection:section];
    }
    return self;
}

- (NSString *)stringFromSection:(Section *)section
{
    NSMutableString *string = [@"" mutableCopy];
    
    [string appendFormat:@"%@", section.title];
    
    return [string copy];
}

@end
