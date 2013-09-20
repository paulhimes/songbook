//
//  Token.h
//  songbook
//
//  Created by Paul Himes on 9/5/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Token (Helpers)

+ (Token *)tokenInContext:(NSManagedObjectContext *)context;
+ (Token *)newOrExistingTokenWithText:(NSString *)text inContext:(NSManagedObjectContext *)context;
+ (NSArray *)existingTokensStartingWithText:(NSString *)text inContext:(NSManagedObjectContext *)context;

@end
