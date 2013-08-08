//
//  Book+Helpers.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Book+Helpers.h"
#import "Section+Helpers.h"
#import "Song.h"

@implementation Book (Helpers)

+ (Book *)newOrExistingBookTitled:(NSString *)title inContext:(NSManagedObjectContext *)context
{
    NSError *fetchError;
    
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title == %@", title];
    
    // Fetch the results.
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    Book *book;
    if ([results count] > 0) {
        // Return an existing book.
        book = results[0];
    } else {
        // Return a new book.
        book = [Book bookInContext:context];
        book.title = title;
    }
    
    return book;
}

+ (Book *)bookInContext:(NSManagedObjectContext *)context
{
    return (Book *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Book"
                                                                       inManagedObjectContext:context]
                            insertIntoManagedObjectContext:context];
}

+ (NSArray *)allBooksInContext:(NSManagedObjectContext *)context
{
    NSError *fetchError;
    
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Book"];
    
    // Fetch the results.
    NSArray *results = [context executeFetchRequest:fetchRequest error:&fetchError];
    
    return results;
}

- (NSManagedObject *)nextObject
{
    // Return the first section in this book.
    if ([self.sections count] > 0) {
        return [self.sections firstObject];
    }
    
    // This is the end of the book.
    return nil;
}

- (NSManagedObject *)previousObject
{
    // This is the start of the book.
    return nil;
}

- (Song *)closestSong
{
    if ([self.sections count] > 0) {
        Section *section = [self.sections firstObject];
        return section.closestSong;
    }
    
    // There are no songs in this book.
    return nil;
}


@end
