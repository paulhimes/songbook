//
//  TokenInstance+Helpers.m
//  songbook
//
//  Created by Paul Himes on 9/16/13.
//

#import "TokenInstance+Helpers.h"
#import "Token.h"
#import "Song.h"

@implementation TokenInstance (Helpers)

+ (TokenInstance *)instanceOfToken:(Token *)token
                           atRange:(NSRange)range
                            inSong:(Song *)song
{
    NSManagedObjectContext *context = token.managedObjectContext == song.managedObjectContext ? token.managedObjectContext : nil;
    
    TokenInstance *tokenInstance;
    
    if (context) {
        tokenInstance = [[TokenInstance alloc] initWithEntity:[NSEntityDescription entityForName:@"TokenInstance"
                                                                          inManagedObjectContext:context]
                               insertIntoManagedObjectContext:context];
        
        tokenInstance.token = token;
        
        if ([song.tokenInstances count] > 0) {
            TokenInstance *previousTokenInstance = [song.tokenInstances lastObject];
            previousTokenInstance.nextInstance = tokenInstance;
            tokenInstance.previousInstance = previousTokenInstance;
        }
        
        tokenInstance.song = song;
        tokenInstance.location = @(range.location);
        tokenInstance.length = @(range.length);
    }
    
    return tokenInstance;
}

@end
