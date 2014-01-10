//
//  BookCodec.m
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookCodec.h"
#import "Section+Helpers.h"
#import "Song+Helpers.h"
#import "Verse+Helpers.h"
#import "OrderedDictionary.h"

// Book keys
NSString * const kBookTitleKey = @"bookTitle";
NSString * const kSectionsKey = @"sections";

// Section keys
NSString * const kSectionTitleKey = @"sectionTitle";
NSString * const kSongsKey = @"songs";

// Song keys
NSString * const kSongNumberKey = @"songNumber";
NSString * const kSongTitleKey = @"songTitle";
NSString * const kSongSubtitleKey = @"songSubtitle";
NSString * const kVersesKey = @"verses";
NSString * const kSongAuthorKey = @"songAuthor";
NSString * const kSongYearKey = @"songYear";
NSString * const kRelatedSongsKey = @"relatedSongs";

// Verse keys
NSString * const kVerseTitleKey = @"verseTitle";
NSString * const kVerseNumberKey = @"verseNumber";
NSString * const kVerseIsChorusKey = @"verseIsChorus";
NSString * const kVerseTextKey = @"verseText";
NSString * const kVerseRepeatTextKey = @"verseRepeatText";
NSString * const kVerseChorusIndexKey = @"verseChorusIndex";

// Related song keys
NSString * const kRelatedSongSectionIndexKey = @"relatedSongSectionIndex";
NSString * const kRelatedSongIndexKey = @"relatedSongIndex";
NSString * const kRelatedSongSongKey = @"relatedSongSong";

NSString * const kBookFileName = @"book.json";


@implementation BookCodec

+ (void)exportBookFromContext:(NSManagedObjectContext *)context intoURL:(NSURL *)url;
{
    Book *book = [Book bookFromContext:context];
    if (!book) {
        return;
    }
    
    NSData *bookData = [self encodeBook:book];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // Write data to a temporary book file.
    // Create the path to the temporary file.
    NSURL *bookFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kBookFileName]];
    // Delete the old file if it exists.
    if ([fileManager fileExistsAtPath:bookFile.path]) {
        NSError *error;
        [fileManager removeItemAtURL:bookFile error:&error];
    }
    // Create the temporary file.
    [fileManager createFileAtPath:bookFile.path contents:nil attributes:nil];
    // Get the handle to the file.
    NSError *handleError;
    NSFileHandle *bookFileHandle = [NSFileHandle fileHandleForUpdatingURL:bookFile error:&handleError];
    // Write the data.
    [bookFileHandle writeData:bookData];
    // Close the book.
    [bookFileHandle closeFile];

    // Delete the old file if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
        NSError *error;
        if (![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
            NSLog(@"Failed to delete the old zip file: %@", error);
            return;
        }
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    BOOL createResult = [zipArchive createZipFile:url.path];
    if (!createResult) {
        NSLog(@"Create zip file failed");
        return;
    }
    BOOL addResult = [zipArchive addFileToZip:bookFile.path newname:kBookFileName];
    if (!addResult) {
        NSLog(@"Add file to zip file failed");
        return;
    }
    BOOL closeResult = [zipArchive closeZipFile];
    if (!closeResult) {
        NSLog(@"Close zip file failed");
        return;
    }
}

+ (NSURL *)fileURLForExportingFromContext:(NSManagedObjectContext *)context
{
    Book *book = [Book bookFromContext:context];
    if (!book) {
        return nil;
    }
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    NSString *safeFileName = [[book.title componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    // Protect against an empty title.
    if ([safeFileName length] == 0) {
        safeFileName = @"songbook";
    }
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@.songbook", safeFileName];
    
    // Create the path to the temporary file.
    NSURL *fileURLForExporting = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fullFileName]];
    
    return fileURLForExporting;
}

+ (NSData *)encodeBook:(Book *)book
{
    NSDictionary *bookDictionary = [BookCodec bookDictionaryFromBook:book];
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bookDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"JSON Encode Error: %@", error);
    }
    
    return jsonData;
}

+ (NSMutableDictionary *)bookDictionaryFromBook:(Book *)book
{
    OrderedDictionary *bookDictionary = [[OrderedDictionary alloc] init];
    bookDictionary[kBookTitleKey] = book.title;
    
    NSMutableArray *sectionArray = [@[] mutableCopy];
    [bookDictionary setObject:sectionArray forKey:kSectionsKey];
    
    for (Section *section in book.sections) {
        OrderedDictionary *sectionDictionary = [[OrderedDictionary alloc] init];
        [sectionArray addObject:sectionDictionary];
        [sectionDictionary setObject:section.title forKey:kSectionTitleKey];
        
        NSMutableArray *songArray = [@[] mutableCopy];
        [sectionDictionary setObject:songArray forKey:kSongsKey];
        
        for (Song *song in section.songs) {
            OrderedDictionary *songDictionary = [[OrderedDictionary alloc] init];
            [songArray addObject:songDictionary];
            if (song.number) {
                [songDictionary setObject:song.number forKey:kSongNumberKey];
            }
            [songDictionary setObject:song.title forKey:kSongTitleKey];
            if ([song.subtitle length] > 0) {
                [songDictionary setObject:song.subtitle forKey:kSongSubtitleKey];
            }
            
            NSMutableArray *verseArray = [@[] mutableCopy];
            [songDictionary setObject:verseArray forKey:kVersesKey];
            
            for (Verse *verse in song.verses) {
                OrderedDictionary *verseDictionary = [[OrderedDictionary alloc] init];
                [verseArray addObject:verseDictionary];
                if ([verse.title length] > 0) {
                    [verseDictionary setObject:verse.title forKey:kVerseTitleKey];
                }
                if (verse.number) {
                    [verseDictionary setObject:verse.number forKey:kVerseNumberKey];
                }
                if (verse.isChorus) {
                    [verseDictionary setObject:verse.isChorus forKey:kVerseIsChorusKey];
                }
                [verseDictionary setObject:verse.text forKey:kVerseTextKey];
                if ([verse.repeatText length] > 0) {
                    [verseDictionary setObject:verse.repeatText forKey:kVerseRepeatTextKey];
                }
                if (verse.chorus) {
                    [verseDictionary setObject:@([song.verses indexOfObject:verse.chorus]) forKey:kVerseChorusIndexKey];
                }
            }
            
            if ([song.author length] > 0) {
                [songDictionary setObject:song.author forKey:kSongAuthorKey];
            }
            if ([song.year length] > 0) {
                [songDictionary setObject:song.year forKey:kSongYearKey];
            }
            if ([song.relatedSongs count] > 0) {
                NSMutableArray *relatedSongArray = [@[] mutableCopy];
                [songDictionary setObject:relatedSongArray forKey:kRelatedSongsKey];
                
                for (Song *relatedSong in song.relatedSongs) {
                    OrderedDictionary *relatedSongDictionary = [[OrderedDictionary alloc] init];
                    [relatedSongArray addObject:relatedSongDictionary];
                    [relatedSongDictionary setObject:@([book.sections indexOfObject:relatedSong.section]) forKey:kRelatedSongSectionIndexKey];
                    [relatedSongDictionary setObject:@([relatedSong.section.songs indexOfObject:relatedSong]) forKey:kRelatedSongIndexKey];
                }
            }
        }
    }
    
    return bookDictionary;
}

+ (NSString *)temporaryFilePathForBook:(Book *)book
{
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    NSString *safeFileName = [[book.title componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    // Protect against an empty title.
    if ([safeFileName length] == 0) {
        safeFileName = @"songbook";
    }
    
    // Create the path to the temporary file.
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.songbook", safeFileName]];
    
    return filePath;
}

+ (NSFileHandle *)openFileHandleOfTemporaryFileAtPath:(NSString *)filePath
{
    // Delete the old file if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    }
    // Create the temporary file.
    [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    
    // Get the handle to the file.
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
    
    return fileHandle;
}

+ (void)importBookFromURL:(NSURL *)file
              intoContext:(NSManagedObjectContext *)context
{
    [context performBlockAndWait:^{
        NSLog(@"About to import book.");
        
        // Build the new book.
        NSDictionary *bookDictionary = [BookCodec bookDictionaryFromFileURL:file];
        Book *book = [BookCodec bookFromBookDictionary:bookDictionary inContext:context];
        NSLog(@"Built the new book");
        
        // Save the new book.
        if (book) {
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
            NSLog(@"Saved the new book");
        }
    }];
}

+ (NSDictionary *)bookDictionaryFromFileURL:(NSURL *)file
{
    // Create a directory to unzip to.
    NSURL *unzippedDirectory = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"unzipped"]];
    NSError *createDirectoryError;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:unzippedDirectory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&createDirectoryError]) {
        NSLog(@"Failed to create unzipped directory: %@", createDirectoryError);
        return nil;
    }
    
    // Unzip the file into the directory.
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL openResult = [zipArchive unzipOpenFile:file.path];
    if (!openResult) {
        NSLog(@"Failed to open zip at: %@", file);
        return nil;
    }
    BOOL unzipResult = [zipArchive unzipFileTo:unzippedDirectory.path overwrite:YES];
    if (!unzipResult) {
        NSLog(@"Failed to unzip: %@", file);
        return nil;
    }
    BOOL closeResult = [zipArchive unzipCloseFile];
    if (!closeResult) {
        NSLog(@"Failed to close: %@", file);
        return nil;
    }
    
    // Read the contents of the book file.
    NSURL *bookFile = [unzippedDirectory URLByAppendingPathComponent:kBookFileName];
    NSData *bookData = [NSData dataWithContentsOfURL:bookFile];
    
    // Parse the book data.
    NSError *parseError;
    id JSONObject = [NSJSONSerialization JSONObjectWithData:bookData options:0 error:&parseError];
    if (parseError) {
        NSLog(@"Parse Error: %@", parseError);
        return nil;
    }
    
    // Make sure the JSON data was a dictionary.
    NSDictionary *bookDictionary;
    if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        bookDictionary = (NSDictionary *)JSONObject;
    } else {
        NSLog(@"JSON object was not a dictionary");
        return nil;
    }
    
    // Delete the temporary unzip directory.
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtURL:unzippedDirectory error:&deleteError];
    if (deleteError) {
        NSLog(@"Delete Error: %@", deleteError);
    }
    
    return bookDictionary;
}

+ (Book *)bookFromBookDictionary:(NSDictionary *)bookDictionary inContext:(NSManagedObjectContext *)context
{
    Book *book = [Book bookInContext:context];
    
    NSString *bookTitle = bookDictionary[kBookTitleKey];
    if ([bookTitle length] == 0) {
        bookTitle = @"Untitled";
    }
    book.title = bookTitle;
    
    NSMutableArray *relatedSongRelationshipArray = [@[] mutableCopy];
    
    NSArray *sectionArray = bookDictionary[kSectionsKey];
    for (NSDictionary *sectionDictionary in sectionArray) {
        
        Section *section = [Section sectionInContext:context];
        
        NSString *sectionTitle = sectionDictionary[kSectionTitleKey];
        if ([sectionTitle length] == 0) {
            sectionTitle = @"Untitled";
        }
        section.title = sectionTitle;
        
        NSArray *songArray = sectionDictionary[kSongsKey];
        for (NSDictionary *songDictionary in songArray) {
            
            Song *song = [Song songInContext:context];
            
            song.number = songDictionary[kSongNumberKey];
            song.title = songDictionary[kSongTitleKey];
            song.subtitle = songDictionary[kSongSubtitleKey];
            song.author = songDictionary[kSongAuthorKey];
            song.year = songDictionary[kSongYearKey];
            
            NSArray *verseArray = songDictionary[kVersesKey];
            for (NSDictionary *verseDictionary in verseArray) {
                
                Verse *verse = [Verse verseInContext:context];
                
                verse.title = verseDictionary[kVerseTitleKey];
                verse.isChorus = verseDictionary[kVerseIsChorusKey];
                verse.number = verseDictionary[kVerseNumberKey];
                verse.text = verseDictionary[kVerseTextKey];
                verse.repeatText = verseDictionary[kVerseRepeatTextKey];
                
                NSNumber *verseChorusIndex = verseDictionary[kVerseChorusIndexKey];
                if (verseChorusIndex) {
                    NSUInteger verseChorusIndexInteger = [verseChorusIndex unsignedIntegerValue];
                    if (verseChorusIndexInteger < [song.verses count]) {
                        verse.chorus = song.verses[verseChorusIndexInteger];
                    }
                }
                
                verse.song = song;
            }
            
            NSArray *relatedSongArray = songDictionary[kRelatedSongsKey];
            for (NSDictionary *relatedSongDictionary in relatedSongArray) {
                
                NSNumber *relatedSongSectionIndex = relatedSongDictionary[kRelatedSongSectionIndexKey];
                NSNumber *relatedSongIndex = relatedSongDictionary[kRelatedSongIndexKey];
                
                if (relatedSongSectionIndex && relatedSongIndex) {
                    [relatedSongRelationshipArray addObject:@{kRelatedSongSongKey: song,
                                                              kRelatedSongSectionIndexKey: relatedSongSectionIndex,
                                                              kRelatedSongIndexKey: relatedSongIndex}];
                }
            }
            
            song.section = section;
        }
        
        section.book = book;
    }
    
    // Attach the related songs.
    for (NSDictionary *relatedSongRelationship in relatedSongRelationshipArray) {
        
        Song *song = relatedSongRelationship[kRelatedSongSongKey];
        NSUInteger relatedSongSectionIndex = [relatedSongRelationship[kRelatedSongSectionIndexKey] unsignedIntegerValue];
        NSUInteger relatedSongIndex = [relatedSongRelationship[kRelatedSongIndexKey] unsignedIntegerValue];
        
        if (relatedSongSectionIndex < [book.sections count]) {
            Section *section = book.sections[relatedSongSectionIndex];
            if (relatedSongIndex < [section.songs count]) {
                Song *relatedSong = section.songs[relatedSongIndex];
                [song addRelatedSongsObject:relatedSong];
            }
        }
    }
    
    return book;
}

@end
