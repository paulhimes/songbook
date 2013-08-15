//
//  NSMutableAttributedString+Helpers.m
//  songbook
//
//  Created by Paul Himes on 8/14/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "NSMutableAttributedString+Helpers.h"

@implementation NSMutableAttributedString (Helpers)

- (void)appendString:(NSString *)str attributes:(NSDictionary *)attrs
{
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:str attributes:attrs]];
}

@end
