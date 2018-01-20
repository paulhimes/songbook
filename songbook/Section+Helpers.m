//
//  Section+Helpers.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Section+Helpers.h"
#import "Book+Helpers.h"

@implementation Section (Helpers)

+ (Section *)newOrExistingSectionTitled:(NSString *)title inBook:(Book *)book
{
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Section"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title == %@ AND book == %@", title, book];
    
    // Fetch the results.
    NSArray *results = [book.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    Section *section;
    if ([results count] > 0) {
        // Return an existing section.
        section = results[0];
    } else {
        // Return a new section.
        section = [Section sectionInContext:book.managedObjectContext];
        section.title = title;
        section.book = book;
    }
    
    return section;
}

+ (Section *)sectionInContext:(NSManagedObjectContext *)context
{
    return (Section *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Section"
                                                                          inManagedObjectContext:context]
                               insertIntoManagedObjectContext:context];
}

- (id<SongbookModel>)nextObject
{
    // Return the first song in this section.
    if ([self.songs count] > 0) {
        return [self.songs firstObject];
    }
    
    // Return the next section.
    NSUInteger sectionIndex = [self.book.sections indexOfObject:self];
    if (sectionIndex < [self.book.sections count] - 1) {
        return [self.book.sections objectAtIndex:sectionIndex + 1];
    }
    
    // Return the book.
    return self.book;
}

- (id<SongbookModel>)previousObject
{
    // Return the last song in the previous section.
    NSUInteger sectionIndex = [self.book.sections indexOfObject:self];
    if (sectionIndex > 0) {
        Section *previousSection = [self.book.sections objectAtIndex:sectionIndex - 1];
        if ([previousSection.songs count] > 0) {
            return [previousSection.songs lastObject];
        } else {
            return previousSection;
        }
    } else {
        return self.book;
    }
}

- (Song *)closestSong
{
    return [self closestSubsequentSong];
}

- (Song *)closestSubsequentSong {
    if ([self.songs count] > 0) {
        // Return the first song in this section.
        return [self.songs firstObject];
    }
    
    NSUInteger sectionIndex = [self.book.sections indexOfObject:self];
    if (sectionIndex < [self.book.sections count] - 1) {
        // Return the first song in a subsequent section.
        return [((Section *)self.book.sections[sectionIndex + 1]) closestSubsequentSong];
    } else if (sectionIndex > 0) {
        // Return the first song in a previous section.
        return [((Section *)self.book.sections[sectionIndex - 1]) closestPreviousSong];
    }

    // There are no songs in this book.
    return nil;
}

- (Song *)closestPreviousSong {
    if ([self.songs count] > 0) {
        // Return the first song in this section.
        return [self.songs firstObject];
    }
    
    NSUInteger sectionIndex = [self.book.sections indexOfObject:self];
    if (sectionIndex > 0) {
        // Return the first song in a previous section.
        return [((Section *)self.book.sections[sectionIndex - 1]) closestPreviousSong];
    }
    
    // There are no songs in this book.
    return nil;
}

@end
