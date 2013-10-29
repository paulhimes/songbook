//
//  BookCodec.m
//  songbook
//
//  Created by Paul Himes on 10/21/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookCodec.h"
#import "Section.h"
#import "Song.h"
#import "Verse.h"
#import "AppDelegate.h"

NSString * const kBookTitleKey = @"bookTitle";
NSString * const kSectionsKey = @"sections";
NSString * const kSectionTitleKey = @"sectionTitle";
NSString * const kSongsKey = @"songs";
NSString * const kSongNumberKey = @"songNumber";
NSString * const kSongTitleKey = @"songTitle";
NSString * const kSongSubtitleKey = @"songSubtitle";
NSString * const kVersesKey = @"verses";
NSString * const kSongAuthorKey = @"songAuthor";
NSString * const kSongYearKey = @"songYear";
NSString * const kVerseTitleKey = @"verseTitle";
NSString * const kVerseNumberKey = @"verseNumber";
NSString * const kVerseIsChorusKey = @"verseIsChorus";
NSString * const kVerseTextKey = @"verseText";
NSString * const kVerseRepeatTextKey = @"verseRepeatText";
NSString * const kVerseChorusIndexKey = @"verseChorusIndex";
NSString * const kRelatedSongsKey = @"relatedSongs";
NSString * const kRelatedSongSectionIndexKey = @"relatedSongSectionIndex";
NSString * const kRelatedSongIndexKey = @"relatedSongIndex";

NSString * const kBookFileName = @"book.json";


@implementation BookCodec

+ (NSString *)exportBook
{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *allBooks = [Book allBooksInContext:appDelegate.managedObjectContext];
    Book *book;
    if ([allBooks count] > 0) {
        book = [allBooks firstObject];
    } else {
        return nil;
    }
    
    NSData *bookData = [self encodeBook:book];
    
    // Write data to a temporary book file.
    // Create the path to the temporary file.
    NSString *bookPath = [NSTemporaryDirectory() stringByAppendingPathComponent:kBookFileName];
    // Delete the old file if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:bookPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:bookPath error:&error];
    }
    // Create the temporary file.
    [[NSFileManager defaultManager] createFileAtPath:bookPath contents:nil attributes:nil];
    // Get the handle to the file.
    NSFileHandle *bookFileHandle = [NSFileHandle fileHandleForUpdatingAtPath:bookPath];
    // Write the data.
    [bookFileHandle writeData:bookData];
    // Close the book.
    [bookFileHandle closeFile];
    
    
    
    
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    NSString *safeFileName = [[book.title componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
    
    // Protect against an empty title.
    if ([safeFileName length] == 0) {
        safeFileName = @"songbook";
    }
    
    NSString *fullFileName = [NSString stringWithFormat:@"%@.songbook", safeFileName];
    
    // Create the path to the temporary file.
    NSString *zipPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fullFileName];
    
    // Delete the old file if it exists.
    if ([[NSFileManager defaultManager] fileExistsAtPath:zipPath]) {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:zipPath error:&error];
    }
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    BOOL createResult = [zipArchive createZipFile:zipPath];
    if (!createResult) {
        NSLog(@"Create zip file failed");
    }
    BOOL addResult = [zipArchive addFileToZip:bookPath newname:kBookFileName];
    if (!addResult) {
        NSLog(@"Add file to zip file failed");
    }
    BOOL closeResult = [zipArchive closeZipFile];
    if (!closeResult) {
        NSLog(@"Close zip file failed");
    }

    return zipPath;
}

+ (NSData *)encodeBook:(Book *)book
{
    NSMutableDictionary *bookDictionary = [@{} mutableCopy];
    [bookDictionary setObject:book.title forKey:kBookTitleKey];
    
    NSMutableArray *sectionArray = [@[] mutableCopy];
    [bookDictionary setObject:sectionArray forKey:kSectionsKey];

    for (Section *section in book.sections) {
        NSMutableDictionary *sectionDictionary = [@{} mutableCopy];
        [sectionArray addObject:sectionDictionary];
        [sectionDictionary setObject:section.title forKey:kSectionTitleKey];
        
        NSMutableArray *songArray = [@[] mutableCopy];
        [sectionDictionary setObject:songArray forKey:kSongsKey];
        
        for (Song *song in section.songs) {
            NSMutableDictionary *songDictionary = [@{} mutableCopy];
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
                NSMutableDictionary *verseDictionary = [@{} mutableCopy];
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
                    NSMutableDictionary *relatedSongDictionary = [@{} mutableCopy];
                    [relatedSongArray addObject:relatedSongDictionary];
                    [relatedSongDictionary setObject:@([book.sections indexOfObject:relatedSong.section]) forKey:kRelatedSongSectionIndexKey];
                    [relatedSongDictionary setObject:@([relatedSong.section.songs indexOfObject:relatedSong]) forKey:kRelatedSongIndexKey];
                }
            }
        }
    }
    
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:bookDictionary options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        NSLog(@"JSON Encode Error: %@", error);
    }
    
    
    return jsonData;
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

+ (void)importBook:(NSString *)filePath
{
    NSString *unzippedDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"unzipped"];
    NSError *createDirectoryError;
    [[NSFileManager defaultManager] createDirectoryAtPath:unzippedDirectoryPath withIntermediateDirectories:NO attributes:nil error:&createDirectoryError];
    
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    BOOL openResult = [zipArchive unzipOpenFile:filePath];
    if (!openResult) {
        NSLog(@"Failed to open zip at: %@", filePath);
    }
    BOOL unzipResult = [zipArchive unzipFileTo:unzippedDirectoryPath overwrite:YES];
    if (!unzipResult) {
        NSLog(@"Failed to unzip: %@", filePath);
    }
    BOOL closeResult = [zipArchive unzipCloseFile];
    if (!closeResult) {
        NSLog(@"Failed to close: %@", filePath);
    }
    
    if (openResult && unzipResult && closeResult) {
        NSString *bookPath = [unzippedDirectoryPath stringByAppendingPathComponent:kBookFileName];
        NSData *bookData = [NSData dataWithContentsOfFile:bookPath];
        
        NSError *parseError;
        id JSONObject = [NSJSONSerialization JSONObjectWithData:bookData options:0 error:&parseError];
        if (parseError) {
            NSLog(@"Parse Error: %@", parseError);
        }
        
        NSDictionary *bookDictionary = (NSDictionary *)JSONObject;
        NSArray *sectionsArray = bookDictionary[@"sections"];
        NSDictionary *finnSectionDictionary = sectionsArray[1];
        NSArray *songsArray = finnSectionDictionary[@"songs"];
        NSDictionary *lastSong = [songsArray lastObject];
        NSString *songTitle = lastSong[@"songTitle"];
        NSLog(@"%@", songTitle);
        NSLog(@"%@", lastSong);
    }
    
    NSError *deleteError;
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&deleteError];
    if (deleteError) {
        NSLog(@"Delete Error: %@", deleteError);
    }
    [[NSFileManager defaultManager] removeItemAtPath:unzippedDirectoryPath error:&deleteError];
    if (deleteError) {
        NSLog(@"Delete Error: %@", deleteError);
    }
}

@end
