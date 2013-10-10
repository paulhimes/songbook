//
//  Token.m
//  songbook
//
//  Created by Paul Himes on 9/5/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Token.h"

@implementation Token (Helpers)

+ (Token *)tokenInContext:(NSManagedObjectContext *)context
{
    return [[Token alloc] initWithEntity:[NSEntityDescription entityForName:@"Token"
                                                     inManagedObjectContext:context]
          insertIntoManagedObjectContext:context];
}

+ (Token *)newOrExistingTokenWithText:(NSString *)text
                            inContext:(NSManagedObjectContext *)context;
{
    NSError *fetchError;
    
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Token"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"text == %@", text];
    fetchRequest.fetchLimit = 1;
    
    // Fetch the results.
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    Token *token;
    if ([results count] > 0) {
        // Return an existing object.
        token = results[0];
    } else {
        // Return a new object.
        token = [Token tokenInContext:context];
        token.text = text;
    }
    
    return token;
}

+ (NSArray *)existingTokensStartingWithText:(NSString *)text inContext:(NSManagedObjectContext *)context
{
    NSError *fetchError;
    
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Token"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"text BEGINSWITH %@", text];
    
    // Fetch the results.
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    return results;
}

@end