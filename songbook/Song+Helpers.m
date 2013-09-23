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
#import "Token+Helpers.h"
#import "TokenInstance+Helpers.h"

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
        // Return an existing object.
        song = results[0];
    } else {
        // Return a new object.
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

- (void)generateSearchTokensWithCache:(NSCache *)cache
{
    NSString *stringForSearching = [self stringForSearching];
    NSArray *stringTokens = [stringForSearching tokens];
    
    for (StringToken *stringToken in stringTokens) {
        NSString *normalizedString = [stringToken.string stringByFoldingWithOptions:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch locale:nil];
        
        Token *token = [cache objectForKey:normalizedString];
        
        if (!token) {
            token = [Token newOrExistingTokenWithText:normalizedString inContext:self.managedObjectContext];
            [cache setObject:token forKey:normalizedString];
        }
        
        [TokenInstance instanceOfToken:token atRange:stringToken.range inSong:self];
    }
}

- (NSString *)stringForSearching
{
    if (!self.cachedStringForSearching) {

        NSMutableString *string = [@"" mutableCopy];
        
        [string appendString:[self headerString]];
        [string appendString:@" "];
        
        if ([self.subtitle length] > 0) {
            [string appendString:self.subtitle];
            [string appendString:@" "];
        }
        
        for (NSUInteger index = 0; index < [self.verses count]; index++) {
            if (index != 0) {
                [string appendString:@" "];
            }
            
            Verse *verse = self.verses[index];
            
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
        }
        
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
        
        self.cachedStringForSearching = [string copy];
    }
    
    return self.cachedStringForSearching;
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

- (NSString *)description
{
    NSMutableString *string = [@"" mutableCopy];
    
    if (self.number) {
        [string appendFormat:@"%@ ", self.number];
    }
    [string appendString:self.title];
    if (self.subtitle) {
        [string appendFormat:@"\n%@", self.subtitle];
    }
    
    for (Verse *verse in self.verses) {
        [string appendString:@"\n\n"];
        if (verse.title) {
            [string appendFormat:@"\t\t\t%@\n", verse.title];
        }
        if ([verse.isChorus boolValue]) {
            [string appendFormat:@"Chorus: %@", verse.text];
        } else {
            if (verse.number) {
                [string appendFormat:@"%@. ", verse.number];
            }
            [string appendString:verse.text];
        }
        
        if (verse.chorus) {
            [string appendString:@"\n\n"];
            [string appendFormat:@"(Chorus: %@)", verse.chorus.text];
        }
    }
    
    return [string copy];
}

- (void)clearCachedSong
{
//    NSMutableArray *uniqueTokens = [@[] mutableCopy];

    for (TokenInstance *tokenInstance in self.tokenInstances) {
//        if (![uniqueTokens containsObject:tokenInstance.token]) {
//            [uniqueTokens addObject:tokenInstance.token];
//        }
        [self.managedObjectContext refreshObject:tokenInstance mergeChanges:NO];
    }
    
//    for (Token *token in uniqueTokens) {
//        [self.managedObjectContext refreshObject:token mergeChanges:NO];
//    }
    
    [self.managedObjectContext refreshObject:self mergeChanges:NO];
}

@end
