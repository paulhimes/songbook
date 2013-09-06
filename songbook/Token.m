//
//  Token.m
//  songbook
//
//  Created by Paul Himes on 9/5/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Token.h"

@interface Token()

@property (nonatomic, strong) NSString *string;
@property (nonatomic) NSRange range;

@end

@implementation Token

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
                
                Token *token = tokens[tokenIndex + searchTokenIndex];
                Token *searchToken = searchTokens[searchTokenIndex];
                
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
