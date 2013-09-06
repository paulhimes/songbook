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

/**
 Returns an array of each alphabetic substring (separated by whitespace and newline characters with all other none letter characters removed) and it's NSRange within the receiver.
 **/
- (NSArray *)tokens
{
    NSMutableArray *tokens = [@[] mutableCopy];

    NSCharacterSet *letterCharacterSet = [NSCharacterSet letterCharacterSet];
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSMutableString *currentToken = [@"" mutableCopy];
    NSInteger indexOfFirstTokenCharacter = -1;
    NSInteger indexOfLastTokenCharacter = -1;
    for (NSUInteger i = 0; i < [self length]; i++) {
        unichar character = [self characterAtIndex:i];
        
        if ([letterCharacterSet characterIsMember:character]) {
            // Letter
            [currentToken appendString:[NSString stringWithCharacters:&character length:1]];
            if (indexOfFirstTokenCharacter < 0) {
                indexOfFirstTokenCharacter = i;
            }
            indexOfLastTokenCharacter = i;
        } else if ([whitespaceAndNewlineCharacterSet characterIsMember:character] ||
                   i == [self length] - 1) {
            if ([currentToken length] > 0) {
                NSRange tokenRange = NSMakeRange(indexOfFirstTokenCharacter, indexOfLastTokenCharacter + 1 - indexOfFirstTokenCharacter);
                [tokens addObject:[[Token alloc] initWithString:[currentToken copy] range:tokenRange]];
            }
            currentToken = [@"" mutableCopy];
            indexOfFirstTokenCharacter = -1;
            indexOfLastTokenCharacter = -1;
        }
    }
    
    if ([currentToken length] > 0) {
        NSRange tokenRange = NSMakeRange(indexOfFirstTokenCharacter, indexOfLastTokenCharacter + 1 - indexOfFirstTokenCharacter);
        [tokens addObject:[[Token alloc] initWithString:[currentToken copy] range:tokenRange]];
    }
    
    return [tokens copy];
}

- (NSString *)stringLimitedToCharacterSet:(NSCharacterSet *)characterSet
{
    return [[self componentsSeparatedByCharactersInSet:[characterSet invertedSet]] componentsJoinedByString:@""];
}

+ (NSString *)stringFromTokenArray:(NSArray *)tokens
{
    NSMutableArray *stringComponents = [@[] mutableCopy];
    for (Token *token in tokens) {
        [stringComponents addObject:token.string];
    }
    
    return [stringComponents componentsJoinedByString:@" "];
}

@end
