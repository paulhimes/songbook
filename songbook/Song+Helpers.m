//
//  Song+Helpers.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "Song+Helpers.h"
#import "Verse+Helpers.h"
#import "Section+Helpers.h"
#import "Book+Helpers.h"
#import "Token+Helpers.h"
#import "TokenInstance+Helpers.h"

NSString * const kSongNumberRangesKey = @"songNumberRanges";
NSString * const kTitleRangesKey = @"titleRanges";
NSString * const kNormalRangesKey = @"normalRanges";
NSString * const kSubtitleRangesKey = @"subtitleRanges";
NSString * const kVerseTitleRangesKey = @"verseTitleRanges";
NSString * const kChorusRangesKey = @"chorusRanges";
NSString * const kGhostRangesKey = @"GhostRanges";
NSString * const kFooterRangesKey = @"FooterRanges";

@implementation Song (Helpers)

+ (Song *)newOrExistingSongTitled:(NSString *)title inSection:(Section *)section
{
    // Build the fetch request.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Song"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title == %@ AND section == %@", title, section];
    
    // Fetch the results.
    NSArray *results = [section.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
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

- (id<SongbookModel>)nextObject
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
    
    // Return the book.
    return self.section.book;
}

- (id<SongbookModel>)previousObject
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
    NSString *stringForSearching = [self string];
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

- (NSString *)string
{
    if (!self.cachedString) {
        self.cachedString = [self stringWithRanges:nil];
    }
    return self.cachedString;
}

- (NSDictionary *)stringComponentRanges
{
    NSMutableDictionary *ranges = [@{} mutableCopy];
    [self stringWithRanges:ranges];
    return [ranges copy];
}

- (NSString *)stringWithRanges:(NSMutableDictionary *)dictionary
{
    NSMutableArray *songNumberRanges = [@[] mutableCopy];
    NSMutableArray *titleRanges = [@[] mutableCopy];
    NSMutableArray *normalRanges = [@[] mutableCopy];
    NSMutableArray *subtitleRanges = [@[] mutableCopy];
    NSMutableArray *verseTitleRanges = [@[] mutableCopy];
    NSMutableArray *chorusRanges = [@[] mutableCopy];
    NSMutableArray *ghostRanges = [@[] mutableCopy];
    NSMutableArray *footerRanges = [@[] mutableCopy];
    
    NSMutableString *string = [@"" mutableCopy];
    
    // Look at me! I can use a crazy local block to cut down on the amount of duplicate code.
    void (^addString)(NSMutableArray *, NSString *) = ^(NSMutableArray *rangeArray, NSString *additionalString) {
        [rangeArray addObject:[NSValue valueWithRange:NSMakeRange([string length], [additionalString length])]];
        [string appendString:additionalString];
    };
    
    
    if (self.number) {
        addString(songNumberRanges, [self.number stringValue]);
        addString(titleRanges, @" ");
    }
    
    if ([self.title length] > 0) {
        addString(titleRanges, self.title);
        addString(normalRanges, @"\n");
    }
    
    if ([self.subtitle length] > 0) {
        addString(subtitleRanges, self.subtitle);
        addString(normalRanges, @"\n\n");
    } else {
        addString(normalRanges, @"\n");
    }
    
    for (NSUInteger verseIndex = 0; verseIndex < [self.verses count]; verseIndex++) {
        Verse *verse = self.verses[verseIndex];
        
        if (verseIndex != 0) {
            addString(normalRanges, @"\n\n");
        }
        
        if (verse.title) {
            addString(verseTitleRanges, [NSString stringWithFormat:@"%@\n", verse.title]);
        }
        if ([verse.isChorus boolValue]) {
            addString(chorusRanges, [NSString stringWithFormat:@"Chorus: %@", verse.text]);
        } else {
            if (verse.number) {
                addString(normalRanges, [NSString stringWithFormat:@"%@. ", verse.number]);
            }
            
            addString(normalRanges, verse.text);
            
            if (verse.repeatText) {
                addString(ghostRanges, [NSString stringWithFormat:@" %@", verse.repeatText]);
            }
            
            if (verse.chorus) {
                addString(normalRanges, @"\n\n");
                
                NSString *ghostString = [NSString stringWithFormat:@"Chorus: %@", verse.chorus.text];
                
                [chorusRanges addObject:[NSValue valueWithRange:NSMakeRange([string length], [ghostString length])]];
                [ghostRanges addObject:[NSValue valueWithRange:NSMakeRange([string length], [ghostString length])]];
                [string appendString:ghostString];
            }
        }
    }
    
    if ([self.author length] > 0 ||
        [self.year length] > 0) {
        addString(normalRanges, @"\n\n");
    }
    
    if ([self.author length] > 0) {
        addString(footerRanges, self.author);
    }
    
    if ([self.year length] > 0) {
        if ([self.author length] > 0) {
            addString(footerRanges, @" ");
        }
        addString(footerRanges, self.year);
    }
    
    // Add all the ranges to the dictionary.
    [dictionary addEntriesFromDictionary:@{kSongNumberRangesKey:[songNumberRanges copy],
                                           kTitleRangesKey:[titleRanges copy],
                                           kNormalRangesKey:[normalRanges copy],
                                           kSubtitleRangesKey:[subtitleRanges copy],
                                           kVerseTitleRangesKey:[verseTitleRanges copy],
                                           kChorusRangesKey:[chorusRanges copy],
                                           kGhostRangesKey:[ghostRanges copy],
                                           kFooterRangesKey:[footerRanges copy]}];
    
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
    for (TokenInstance *tokenInstance in self.tokenInstances) {
        [self.managedObjectContext refreshObject:tokenInstance mergeChanges:NO];
    }
    [self.managedObjectContext refreshObject:self mergeChanges:NO];
}

@end
