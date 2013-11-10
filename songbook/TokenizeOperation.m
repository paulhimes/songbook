//
//  TokenizeOperation.m
//  songbook
//
//  Created by Paul Himes on 11/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TokenizeOperation.h"
#import "Book+Helpers.h"
#import "Section.h"
#import "Song+Helpers.h"

NSString * const kTokenizeProgressNotification = @"TokenizeProgressNotification";
NSString * const kBookIDKey = @"BookIDKey";
NSString * const kCompletedSongCountKey = @"CompletedSongCountKey";
NSString * const kTotalSongCountKey = @"TotalSongCountKey";

@interface TokenizeOperation ()

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectID *bookID;

@end

@implementation TokenizeOperation

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        self.context.persistentStoreCoordinator = book.managedObjectContext.persistentStoreCoordinator;
        self.bookID = book.objectID;
    }
    return self;
}

- (void)main
{
    [self.context performBlockAndWait:^
    {
        [self tokenizeBook];
    }];
}

- (void)tokenizeBook
{
    NSError *getBookError;
    Book *book = (Book *)[self.context existingObjectWithID:self.bookID error:&getBookError];
    
    if (book) {
        [self.context performBlockAndWait:^{
            // Tokenize the songs.
            NSCache *tokenCache = [[NSCache alloc] init];
            NSMutableArray *unsavedSongs = [@[] mutableCopy];
            
            NSUInteger completedSongCount = 0;
            NSUInteger totalSongCount = 0;
            for (Section *section in book.sections) {
                totalSongCount += [section.songs count];
            }
            
            for (Section *section in book.sections) {
                if (self.isCancelled) {
                    break;
                }
                for (Song *song in section.songs) {
                    if (self.isCancelled) {
                        break;
                    }
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTokenizeProgressNotification
                                                                        object:self
                                                                      userInfo:@{kBookIDKey: book.objectID,
                                                                                 kCompletedSongCountKey: @(completedSongCount),
                                                                                 kTotalSongCountKey: @(totalSongCount)}];
                    
                    // Check if the song already has tokens and should therefore, not be tokenized.
                    if ([song.tokenInstances count] == 0) {
                        @autoreleasepool {
                            [song generateSearchTokensWithCache:tokenCache];
                            NSLog(@"Tokenized: %@", [song headerString]);
                            
                            [unsavedSongs addObject:song];
                            
                            if ([unsavedSongs count] > 5) {
                                NSError *error;
                                if (![self.context save:&error]) {
                                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                                }
                                
                                for (Song *song in unsavedSongs) {
                                    // Clear the song (along with all it's tokens and token instances)
                                    [song clearCachedSong];
                                }
                                
                                [unsavedSongs removeAllObjects];
                            }
                        }
                    }
                    
                    completedSongCount++;
                }
            }
            
            // One last save.
            NSError *error;
            if (![self.context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            
            if (completedSongCount == totalSongCount) {
                // Notify the observers that the tokenization process has completed.
                [[NSNotificationCenter defaultCenter] postNotificationName:kTokenizeProgressNotification
                                                                    object:self
                                                                  userInfo:@{kBookIDKey: book.objectID,
                                                                             kCompletedSongCountKey: @(completedSongCount),
                                                                             kTotalSongCountKey: @(totalSongCount)}];
            }
        }];
    }
}

@end
