//
//  DataModelTests.m
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "DataModelTests.h"
#import "Book+Helpers.h"
#import "Song+Helpers.h"
#import "Section+Helpers.h"
#import "Verse+Helpers.h"
#import "BookParser.h"

@implementation DataModelTests

+ (void)populateSampleDataInContext:(NSManagedObjectContext *)context
{
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    // First check if data has already been populated.
    NSArray *books = [Book allBooksInContext:context];
    if ([books count] > 0) {
        return;
    }
    
    // Create the book.
    Book *book = [Book newOrExistingBookTitled:@"Songs & Hymns of Believers" inContext:context];
    
    // Create the sections.
    Section *songsSection = [Section newOrExistingSectionTitled:@"Songs of Believers" inBook:book];
    Section *finnSection = [Section newOrExistingSectionTitled:@"Uskovaisten Lauluja" inBook:book];
    Section *hymnSection = [Section newOrExistingSectionTitled:@"Hymns of Believers" inBook:book];

    // Create the songs.
    NSArray *songs = [BookParser songsFromFilePath:[[NSBundle mainBundle] pathForResource:@"songs" ofType:@"txt"]];
    Song *song41;
    for (Song *song in songs) {
        song.section = songsSection;
        
        if ([song.number isEqualToNumber:@41]) {
            song41 = song;
        }
    }
    
    // Create the Finn Songs
    NSArray *finnSongs = [BookParser songsFromFilePath:[[NSBundle mainBundle] pathForResource:@"afewfinnsongs" ofType:@"txt"]];
    for (Song *song in finnSongs) {
        song.section = finnSection;
        
        if ([song.number isEqualToNumber:@40] && song41) {
            [song addRelatedSongsObject:song41];
            [song41 addRelatedSongsObject:song];
        }
    }
    
    // Create the Hymns
    NSArray *hymns = [BookParser songsFromFilePath:[[NSBundle mainBundle] pathForResource:@"hymns" ofType:@"txt"]];
    for (Song *hymn in hymns) {
        hymn.section = hymnSection;
    }
    
    // Save it all.
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"%@", error);
    };
    
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"loading data took %f seconds", endTime - startTime);
}

+ (void)tokenizeSong:(Song *)song
{
    [song generateSearchTokensWithCache:nil];
    NSLog(@"Tokenized: %@", [song headerString]);
}

+ (void)printBook:(Book *)book
{
    NSMutableString *string = [@"\n" mutableCopy];
    
    [string appendFormat:@"\n%@", book.title];
    for (Section *section in book.sections) {
        [string appendFormat:@"\n\n%@", section.title];
        
        for (Song *song in section.songs) {
            [string appendString:@"\n\n"];
            if (song.number) {
                [string appendFormat:@"%@ ", song.number];
            }
            [string appendString:song.title];
            if (song.subtitle) {
                [string appendFormat:@"\n%@", song.subtitle];
            }
            
            for (Verse *verse in song.verses) {
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
            }
        }
    }
         
    NSLog(@"%@", string);
}

@end
