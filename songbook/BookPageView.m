//
//  BookPageView.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageView.h"

@implementation BookPageView

- (UIFont *)font
{
    return [UIFont fontWithName:@"Marion" size:40];
}

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.text = [self stringFromBook:book];
    }
    return self;
}

- (NSString *)stringFromBook:(Book *)book
{
    NSMutableString *string = [@"" mutableCopy];
    
    [string appendFormat:@"%@", book.title];
    
    return [string copy];
}

@end
