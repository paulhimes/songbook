//
//  Song+Helpers.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Song+Helpers.h"
#import "Verse+Helpers.h"
#import "Section.h"
#import "Book.h"

@implementation Song (Helpers)

+ (Song *)newOrExistingSongTitled:(NSString *)title inSection:(Section *)section
{
    NSError *fetchError;
    
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title == %@ AND section == %@", title, section];
    
    // Fetch the results.
    NSArray *results = [section.managedObjectContext executeFetchRequest:fetchRequest error:&fetchError];
    
    Song *song;
    if ([results count] > 0) {
        // Return an existing section.
        song = results[0];
    } else {
        // Return a new section.
        song = [Song songInContext:section.managedObjectContext];
        song.title = title;
        song.section = section;
    }
    
    return song;
}

+ (Song *)songInContext:(NSManagedObjectContext *)context
{
    return (Song *)[[NSManagedObject alloc] initWithEntity:[NSEntityDescription entityForName:@"Song"
                                                                       inManagedObjectContext:context]
                            insertIntoManagedObjectContext:context];
}

- (Verse *)addVerse:(NSString *)verseText
{
    Verse *verse = [Verse verseInContext:self.managedObjectContext];
    verse.text = verseText;
    verse.number = @([self.verses count] + 1);
    verse.song = self;
    
    return verse;
}

- (NSManagedObject *)nextObject
{
    // Return the next song in this song's section.
    NSUInteger songIndex = [self.section.songs indexOfObject:self];
    if (songIndex < [self.section.songs count] - 1) {
        return [self.section.songs objectAtIndex:songIndex + 1];
    }

    // Return the next section.
    NSUInteger sectionIndex = [self.section.book.sections indexOfObject:self.section];
    if (sectionIndex < [self.section.book.sections count] - 1) {
        return [self.section.book.sections objectAtIndex:sectionIndex + 1];
    }
    
    // This is the end of the book.
    return nil;
}

- (NSManagedObject *)previousObject
{
    // Return the previous song in this song's section.
    NSUInteger songIndex = [self.section.songs indexOfObject:self];
    if (songIndex > 0) {
        return [self.section.songs objectAtIndex:songIndex - 1];
    }
    
    // Return this song's section.
    return self.section;
}

- (Song *)closestSong
{
    return self;
}

- (NSString *)stringForSearching
{
    NSMutableString *string = [@"" mutableCopy];

    if ([self.subtitle length] > 0) {
        [string appendString:self.subtitle];
        [string appendString:@" "];
    }
    
    [self.verses enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Verse *verse = (Verse *)obj;
        
        if (idx != 0) {
            [string appendString:@" "];
        }
        
        if (verse.title) {
            [string appendString:[NSString stringWithFormat:@" %@", verse.title]];
            [string appendString:@" "];
        }
        
        if ([verse.isChorus boolValue]) {
            [string appendString:@" Chorus: "];
        } else {
            if (verse.number) {
                [string appendString:[NSString stringWithFormat:@" %@. ", verse.number]];
            }
        }
        
        [string appendString:verse.text];
    }];
    
    if ([self.author length] > 0 ||
        [self.year length] > 0) {
        [string appendString:@" "];
    }
    
    if ([self.author length] > 0) {
        [string appendString:@" "];
        [string appendString:self.author];
    }
    
    if ([self.year length] > 0) {
        [string appendString:@" "];
        [string appendString:self.year];
    }
    
    return [string copy];
}

- (NSString *)headerString
{
    NSMutableString *headerString = [[NSMutableString alloc] init];
    if (self.number) {
        [headerString appendString:[self.number stringValue]];
        [headerString appendString:@" "];
    }
    if ([self.title length] > 0) {
        [headerString appendString:self.title];
    }
    
    return [headerString copy];
}

@end
