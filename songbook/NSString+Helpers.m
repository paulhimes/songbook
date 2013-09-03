//
//  NSString+Helpers.m
//  songbook
//
//  Created by Paul Himes on 9/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "NSString+Helpers.h"

@implementation NSString (Helpers)

- (NSArray *)rangesOfSubstring:(NSString *)substring
{
    NSMutableArray *ranges = [@[] mutableCopy];
    
    NSRange searchRange = NSMakeRange(0, [self length]);
    
    while (searchRange.location != NSNotFound) {
        //        NSLog(@"Searching %@ of %@ for %@", NSStringFromRange(searchRange), [string substringToIndex:5], substring);
        
        NSRange matchingRange = [self rangeOfString:substring
                                            options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch
                                              range:searchRange];
        
        if (matchingRange.location != NSNotFound) {
            //            NSLog(@"Found %@ at %@", substring, NSStringFromRange(matchingRange));
            
            [ranges addObject:[NSValue valueWithRange:matchingRange]];
        }
        
        NSUInteger searchStartLocation = matchingRange.location + matchingRange.length;
        searchRange = NSMakeRange(searchStartLocation,
                                  [self length] - searchStartLocation);
    }
    
    return [ranges copy];
}

- (NSArray *)wordRangesOfSubstring:(NSString *)substring
{
    NSMutableArray *wordRanges = [@[] mutableCopy];
    
    NSArray *matchingRanges = [self rangesOfSubstring:substring];
    
    for (NSValue *rangeValue in matchingRanges) {
        NSRange range = [rangeValue rangeValue];
        if (range.location == 0 ||
            [[NSCharacterSet whitespaceAndNewlineCharacterSet] characterIsMember:[self characterAtIndex:range.location - 1]]) {
            
            [wordRanges addObject:rangeValue];
        }
    }
    
    return [wordRanges copy];
}

@end
