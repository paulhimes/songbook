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
        NSRange matchingRange = [self rangeOfString:substring
                                            options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch
                                              range:searchRange];
        
        if (matchingRange.location != NSNotFound) {
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
                [tokens addObject:[[StringToken alloc] initWithString:[currentToken copy] range:tokenRange]];
            }
            currentToken = [@"" mutableCopy];
            indexOfFirstTokenCharacter = -1;
            indexOfLastTokenCharacter = -1;
        }
    }
    
    if ([currentToken length] > 0) {
        NSRange tokenRange = NSMakeRange(indexOfFirstTokenCharacter, indexOfLastTokenCharacter + 1 - indexOfFirstTokenCharacter);
        [tokens addObject:[[StringToken alloc] initWithString:[currentToken copy] range:tokenRange]];
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
    for (StringToken *token in tokens) {
        [stringComponents addObject:token.string];
    }
    
    return [stringComponents componentsJoinedByString:@" "];
}

- (NSString *)stringByAppendingCharacter:(unichar)character
{
    return [self stringByAppendingString:[NSString stringWithCharacters:&character length:1]];
}

@end

@implementation StringToken

- (instancetype)initWithString:(NSString *)string range:(NSRange)range
{
    self = [super init];
    if (self) {
        self.string = string;
        self.range = range;
    }
    return self;
}

/** Returns an array of range arrays. Each range array has one range for each search token. Each range array corresponds to a location in the tokens array in which the search tokens line up such that each search token begins a token in a contiguous subset of the tokens. **/
+ (NSArray *)rangeListsMatchingTokens:(NSArray *)searchTokens
                             inTokens:(NSArray *)tokens
{
    NSMutableArray *rangeLists = [@[] mutableCopy];
    
    for (int tokenIndex = 0; tokenIndex < [tokens count]; tokenIndex++) {
        
        NSMutableArray *rangeList = [@[] mutableCopy];
        
        if ([tokens count] - tokenIndex >= [searchTokens count]) {
            for (int searchTokenIndex = 0; searchTokenIndex < [searchTokens count]; searchTokenIndex++) {
                
                StringToken *token = tokens[tokenIndex + searchTokenIndex];
                StringToken *searchToken = searchTokens[searchTokenIndex];
                
                NSRange matchingRange = [token.string rangeOfString:searchToken.string
                                                            options:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch];
                
                if (matchingRange.location != 0) {
                    [rangeList removeAllObjects];
                    break;
                } else {
                    [rangeList addObject:[NSValue valueWithRange:token.range]];
                }
            }
        } else {
            break;
        }
        
        if ([rangeList count] > 0) {
            [rangeLists addObject:[rangeList copy]];
        }
    }
    
    return [rangeLists copy];
}

@end
