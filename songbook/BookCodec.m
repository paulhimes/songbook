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
#import "Book+Helpers.h"

// Book keys
NSString * const kBookTitleKey = @"bookTitle";
NSString * const kContactEmailKey = @"contactEmail";
NSString * const kVersionKey = @"version";
NSString * const kUpdateURLKey = @"updateURL";
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
NSString * const kBookDatabaseFileName = @"book.sqlite";

@implementation BookCodec

#pragma mark - Exporting

+ (NSURL *)exportBookFromDirectory:(NSURL *)directory includeExtraFiles:(BOOL)includeExtraFiles progress:(void (^)(CGFloat progress, BOOL *stop))progress;
{
    // Protect against a nil block.
    if (!progress) {
        progress = ^(CGFloat progress, BOOL *stop){};
    }
    
    __block BOOL shouldStop = NO;
    
    progress(0, &shouldStop);
    
    CoreDataStack *coreDataStack = [BookCodec coreDataStackFromBookDirectory:directory
                                                             concurrencyType:NSMainQueueConcurrencyType];
    
    NSURL *exportURL = [BookCodec fileURLForExportingFromContext:coreDataStack.managedObjectContext];
    
    // Delete the export file if it exists.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:exportURL error:nil];
    
    // Get all the file paths and new names for the zip archive.
    NSDictionary *filePathsAndNames = [BookCodec dictionaryOfExportFilePathsWithNamesFromDirectory:directory includeExtraFiles:includeExtraFiles];
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL createResult = [zipArchive createZipFile:exportURL.path];
    if (!createResult) {
        NSLog(@"Create zip file failed");
        return nil;
    }

    if (!shouldStop) {
        NSUInteger totalFileCount = [filePathsAndNames count];
        __block  NSUInteger currentFileIndex = 1;
        [filePathsAndNames enumerateKeysAndObjectsUsingBlock:^(NSString *path, NSString *name, BOOL *stop) {
            
            BOOL addResult = [zipArchive addFileToZip:path newname:name];
            if (!addResult) {
                NSLog(@"Add file to zip file failed: %@", path);
            }
            
            progress((CGFloat)currentFileIndex / (CGFloat)totalFileCount, stop);
            shouldStop = *stop;
            
            currentFileIndex++;
        }];
    }

    BOOL closeResult = [zipArchive closeZipFile];
    if (!closeResult) {
        NSLog(@"Close zip file failed");
        return nil;
    }
        
    if (shouldStop) {
        // Delete the failed export file.
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtURL:exportURL error:nil];
    }
    
    return exportURL;
}

+ (NSDictionary *)dictionaryOfExportFilePathsWithNamesFromDirectory:(NSURL *)directory includeExtraFiles:(BOOL)includeExtraFiles
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:directory
                                                   includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                      options:0
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"Error enumerating url: %@", url);
                                                                     return YES;
                                                                 }];
    
    NSString *basePath = [directory.path stringByAppendingString:@"/"];
    
    NSMutableDictionary *dictionary = [@{} mutableCopy];
    
    for (NSURL *url in directoryEnumerator) {
        // Skip directories. They will be automatically added if they contain any files.
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue]) {
            continue;
        }
        
        // Get the new file path and attempt to remove the base directory portion of the path.
        NSString *newFilePath = url.path;
        NSRange baseRange = [newFilePath rangeOfString:basePath];
        if (baseRange.location != NSNotFound) {
            newFilePath = [newFilePath substringFromIndex:NSMaxRange(baseRange)];
        }
        
        // Possibly skip all files except the main book json file.
        if (!includeExtraFiles && ![newFilePath isEqualToString:kBookFileName]) {
            continue;
        }
        
        // Only process files unrelated to the core data database.
        if ([newFilePath rangeOfString:kBookDatabaseFileName].location != NSNotFound) {
            continue;
        }
        
        // Add the file to the zip
        dictionary[url.path] = newFilePath;
    }
    
    return [dictionary copy];
}

+ (NSURL *)fileURLForExportingFromContext:(NSManagedObjectContext *)context
{
    __block NSURL *fileURLForExporting;
    [context performBlockAndWait:^{
        Book *book = [Book bookFromContext:context];
        if (!book) {
            return;
        }
        
        NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
        NSString *safeFileName = [[book.title componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
        
        // Protect against an empty title.
        if ([safeFileName length] == 0) {
            safeFileName = @"songbook";
        }
        
        NSString *fullFileName = [NSString stringWithFormat:@"%@.songbook", safeFileName];
        
        // Create the path to the temporary file.
        fileURLForExporting = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:fullFileName]];
    }];
    
    return fileURLForExporting;
}

+ (NSData *)encodeBook:(Book *)book
{
    NSDictionary *bookDictionary = [BookCodec bookDictionaryFromBook:book];
    
    NSError *error;
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
    if ([book.contactEmail length]) {
        bookDictionary[kContactEmailKey] = book.contactEmail;
    }
    bookDictionary[kVersionKey] = book.version;
    if ([book.updateURL length]) {
        bookDictionary[kUpdateURLKey] = book.updateURL;
    }
    
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
                if ([verse.isChorus boolValue]) {
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

#pragma mark - Importing

+ (void)importBookFromURL:(NSURL *)file intoDirectory:(NSURL *)directory
{
    // Unzip the file.
    [BookCodec unzipFile:file intoDirectory:directory];
    
    // Create the database stack.
    NSURL *databaseFile = [directory URLByAppendingPathComponent:kBookDatabaseFileName];
    CoreDataStack *databaseStack = [[CoreDataStack alloc] initWithFileURL:databaseFile concurrencyType:NSPrivateQueueConcurrencyType];
    
    // Load the book into the database.
    NSManagedObjectContext *context = databaseStack.managedObjectContext;
    [context performBlockAndWait:^{
        
        // Build a book dictionary.
        NSDictionary *bookDictionary = [BookCodec bookDictionaryFromBookDirectory:directory];
        
        // Build the new book.
        Book *book = [BookCodec bookFromBookDictionary:bookDictionary inContext:context];
        
        // Save the new book.
        if (book) {
            NSError *error;
            if (![context save:&error]) {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            }
        }
    }];
}

+ (void)unzipFile:(NSURL *)file intoDirectory:(NSURL *)directory
{
    // Delete the unzip directory if it already exists.
    NSError *deleteError;
    if ([[NSFileManager defaultManager] fileExistsAtPath:directory.path]) {
        [[NSFileManager defaultManager] removeItemAtURL:directory error:&deleteError];
        if (deleteError) {
            NSLog(@"Delete Error: %@", deleteError);
            return;
        }
    }
    
    NSError *createDirectoryError;
    if (![[NSFileManager defaultManager] createDirectoryAtURL:directory
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&createDirectoryError]) {
        NSLog(@"Failed to create unzipped directory: %@", createDirectoryError);
        return;
    }
    
    // Unzip the file into the directory.
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL openResult = [zipArchive unzipOpenFile:file.path];
    if (!openResult) {
        NSLog(@"Failed to open zip at: %@", file);
        return;
    }
    BOOL unzipResult = [zipArchive unzipFileTo:directory.path overwrite:YES];
    if (!unzipResult) {
        NSLog(@"Failed to unzip: %@", file);
    }
    BOOL closeResult = [zipArchive unzipCloseFile];
    if (!closeResult) {
        NSLog(@"Failed to close: %@", file);
        return;
    }
}

+ (NSDictionary *)bookDictionaryFromBookDirectory:(NSURL *)bookDirectory
{
    // Read the contents of the book file.
    NSURL *bookFile = [bookDirectory URLByAppendingPathComponent:kBookFileName];
    NSData *bookData = [NSData dataWithContentsOfURL:bookFile];
    
    // Make sure the book data is not nil.
    if (!bookData) {
        NSLog(@"Book json file did not exist in the zip file.");
        return nil;
    }
    
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
    
    return bookDictionary;
}

+ (Book *)bookFromBookDictionary:(NSDictionary *)bookDictionary inContext:(NSManagedObjectContext *)context
{
    Book *book;
    
    if (bookDictionary && context) {
        book = [Book bookInContext:context];
        
        NSString *bookTitle = bookDictionary[kBookTitleKey];
        if ([bookTitle length] == 0) {
            bookTitle = @"Untitled";
        }
        book.title = bookTitle;
        book.contactEmail = bookDictionary[kContactEmailKey];
        book.version = bookDictionary[kVersionKey];
        book.updateURL = bookDictionary[kUpdateURLKey];
        
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
                    if (verseDictionary[kVerseIsChorusKey]) {
                        verse.isChorus = verseDictionary[kVerseIsChorusKey];
                    }
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
    }
    
    return book;
}

#pragma mark - Helper Methods

+ (CoreDataStack *)coreDataStackFromBookDirectory:(NSURL *)directory concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType
{
    // Create the database stack.
    NSURL *databaseFile = [directory URLByAppendingPathComponent:kBookDatabaseFileName];
    return [[CoreDataStack alloc] initWithFileURL:databaseFile concurrencyType:concurrencyType];
}

@end
