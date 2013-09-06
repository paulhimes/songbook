//
//  Token.h
//  songbook
//
//  Created by Paul Himes on 9/5/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token : NSObject

@property (nonatomic, readonly) NSString *string;
@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithString:(NSString *)string range:(NSRange)range;

+ (NSArray *)rangeListsMatchingTokens:(NSArray *)searchTokens inTokens:(NSArray *)tokens;

@end
