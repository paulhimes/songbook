//
//  BookParser.m
//  songbook
//
//  Created by Paul Himes on 9/9/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookParser.h"
#import "Book.h"
#import "Song+Helpers.h"
#import "Section+Helpers.h"
#import "Verse+Helpers.h"
#import "AppDelegate.h"
#import "TokenInstance.h"

static NSString * const kTitleKey = @"title";
static NSString * const kVerseTextKey = @"text";
static NSString * const kNumberKey = @"number";
static NSString * const kHasChorusKey = @"hasChorus";


@implementation BookParser

- (NSArray *)songsFromFilePath:(NSString *)path;
{
    NSMutableArray *songs = [@[] mutableCopy];
    
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSStringEncoding encoding;
    NSError *error;
    NSString *fileString = [NSString stringWithContentsOfFile:path usedEncoding:&encoding error:&error];
    
    fileString = [self isolateSubtitleLines:fileString];
    
    NSArray *lines = [fileString componentsSeparatedByString:@"\n"];
    
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;

    __block Song *currentSong;
    __block Verse *currentChorus;
    
    __block NSUInteger titleCounter = 0;
    __block NSUInteger lastErrorIndex = 0;
    [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *line = [obj stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet];
        if ([self isSongTitleLine:line]) {
            titleCounter++;
            NSDictionary *titleComponents = [self titleComponentsFromLine:line];
            
            if (titleCounter != [titleComponents[kNumberKey] integerValue]) {
                NSLog(@"ERROR %d - [%@] [%@]", titleCounter, titleComponents[kNumberKey], titleComponents[kTitleKey]);
                *stop = YES;
            } else {
                // Save the old song.
                if (currentSong) {
                    [songs addObject:currentSong];
                }
                
//                NSLog(@"%d - [%@] [%@]", titleCounter, titleComponents[@"number"], titleComponents[@"title"]);

                // Start building a new song.
                currentSong = [Song songInContext:context];
                currentChorus = nil;
                currentSong.title = titleComponents[kTitleKey];
                currentSong.number = @([titleComponents[kNumberKey] integerValue]);
            }
            
        } else if ([self isSubtitleLine:line]) {
            if (currentSong && [currentSong.subtitle length] == 0) {
                currentSong.subtitle = line;
//                NSLog(@"[%@]", currentSong.subtitle);
            } else {
                NSLog(@"ERROR [%@]", line);
                *stop = YES;
            }
        } else if ([self isChorusLine:line]) {
//            NSLog(@"%@", @" ");
//            NSLog(@"c[%@]", line);
//            NSLog(@"c[%@]", [self chorusTextFromLine:line]);
            
            Verse *chorus = [Verse verseInContext:context];
            chorus.text = [self chorusTextFromLine:line];
            chorus.isChorus = @(YES);
            
//            if ([[chorus.text rangesOfSubstring:@"chorus"] count] > 0) {
//                NSLog(@"ERROR [%@]", line);
//                *stop = YES;
//            }
            
            if (currentSong) {
                chorus.song = currentSong;
                currentChorus = chorus;
            }  else {
                NSLog(@"ERROR [%@]", line);
                *stop = YES;
            }

        } else if ([self isVerseLine:line]) {
//            NSLog(@"vs[%@]", line);
            NSDictionary *verseComponents = [self verseComponentsFromLine:line];
            
            Verse *verse = [Verse verseInContext:context];
            verse.text = verseComponents[kVerseTextKey];
            verse.number = verseComponents[kNumberKey];
            
            if (currentSong) {
                verse.song = currentSong;
            } else {
                NSLog(@"ERROR [%@]", line);
                *stop = YES;
            }
            
//            if ([[verse.text rangesOfSubstring:@"chorus"] count] > 0) {
//                NSLog(@"ERROR [%@]", line);
//                *stop = YES;
//            }
            
            if ([verseComponents[kHasChorusKey] boolValue]) {
                if (currentChorus) {
                    verse.chorus = currentChorus;
                } else {
                    NSLog(@"ERROR [%@]", line);
                    *stop = YES;
                }
            }
        } else if ([self isUnNumberedVerseLine:line]) {
//            NSLog(@"unvs[%@]", line);
            
            NSDictionary *verseComponents = [self unNumberedVerseComponentsFromLine:line];
            
            Verse *verse = [Verse verseInContext:context];
            verse.text = verseComponents[kVerseTextKey];
            
            if (currentSong) {
                verse.song = currentSong;
            }
            
//            if ([[verse.text rangesOfSubstring:@"chorus"] count] > 0) {
//                NSLog(@"ERROR [%@]", line);
//                *stop = YES;
//            }
            
            if ([verseComponents[kHasChorusKey] boolValue] && currentChorus) {
                verse.chorus = currentChorus;
            }
        } else if ([line length] > 0) {
            
            if (lastErrorIndex != idx - 1) {
                NSLog(@"%@", @" ");
                if (idx > 0) {
                    NSLog(@"%@ (%@)", currentSong.number, lines[idx - 1]);
                }
            }
            NSLog(@"%@ [%@]", currentSong.number, line);
            lastErrorIndex = idx;
        }
    }];
    
    if (currentSong) {
        [songs addObject:currentSong];
    }
    
    [context save:NULL];
    
    // Collect the Song object IDs and clear all the songs.
    NSMutableArray *songIDs = [@[] mutableCopy];
    for (Song *song in songs) {
        [songIDs addObject:song.objectID];
        [song clearCachedSong];
    }
    [songs removeAllObjects];
    
    NSCache *tokenCache = [[NSCache alloc] init];
    
    // Generate the search tokens.
    NSMutableArray *unsavedSongs = [@[] mutableCopy];
    
    for (NSManagedObjectID *songID in songIDs) {
        @autoreleasepool {
            Song *song = (Song *)[context objectWithID:songID];
            
            [song generateSearchTokensWithCache:tokenCache];
            NSLog(@"Tokenized: %@", [song headerString]);
            
            [unsavedSongs addObject:song];

            if ([unsavedSongs count] > 5) {
                [context save:NULL];
                
                for (Song *song in unsavedSongs) {
                    // Clear the song (along with all it's tokens and token instances)
                    [song clearCachedSong];
                }
                
                [unsavedSongs removeAllObjects];
            }
        }
    }
    
    [context save:NULL];
    for (Song *song in unsavedSongs) {
        [song clearCachedSong];
    }

    // Reload all the song objects.
    for (NSManagedObjectID *songID in songIDs) {
        Song *song = (Song *)[context objectWithID:songID];
        [songs addObject:song];
    }
    
    return songs;
}


- (NSString *)isolateSubtitleLines:(NSString *)string
{
    string = [[string componentsSeparatedByString:@"("] componentsJoinedByString:@"\n("];
    
    return string;
}


- (BOOL)isSongTitleLine:(NSString *)line
{
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    
    BOOL isTitle = YES;
    BOOL hasSeenDigit = NO;
    if ([line length] > 0) {
        for (NSUInteger i = 0; i < [line length]; i++) {
            unichar character = [line characterAtIndex:i];
            
            if ([decimalDigitCharacterSet characterIsMember:character]) {
                hasSeenDigit = YES;
            } else if ([whitespaceAndNewlineCharacterSet characterIsMember:character]) {
                if (!hasSeenDigit) {
                    isTitle = NO;
                }
                break;
            } else {
                isTitle = NO;
                break;
            }
        }
    } else {
        isTitle = NO;
    }
    
    return isTitle;
}

- (NSDictionary *)titleComponentsFromLine:(NSString *)line
{
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    
    NSString *numberString = @"";
    NSString *titleString = @"";
    
    if ([line length] > 0) {
        NSUInteger index = 0;
        
        while (index < [line length] &&
               [decimalDigitCharacterSet characterIsMember:[line characterAtIndex:index]]) {
            numberString = [numberString stringByAppendingCharacter:[line characterAtIndex:index]];
            index++;
        }
        
        while (index < [line length]) {
            titleString = [titleString stringByAppendingCharacter:[line characterAtIndex:index]];
            index++;
        }
    }
    
    titleString = [titleString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return @{kNumberKey: numberString, kTitleKey: titleString};
}

- (BOOL)isSubtitleLine:(NSString *)line
{
    if ([line length] > 0) {
        unichar character = [line characterAtIndex:0];
        
        if (character == [@"(" characterAtIndex:0]) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)isChorusLine:(NSString *)line
{
    line = [line lowercaseString];

    if ([line hasPrefix:@"chorus"]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)chorusTextFromLine:(NSString *)line
{
    NSString *lowerCase = [line lowercaseString];
    NSRange range = [lowerCase rangeOfString:@"chorus"];
    
    NSString *stripped = [line substringFromIndex:range.length];
    
    NSMutableCharacterSet *trimmedCharacters = [[NSMutableCharacterSet alloc] init];
    [trimmedCharacters formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [trimmedCharacters formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:@":."]];
    
    NSInteger index = 0;
    while (index < [stripped length]) {
        
        if (![trimmedCharacters characterIsMember:[stripped characterAtIndex:index]]) {
            break;
        }
        
        index++;
    }
    
    return [stripped substringFromIndex:index];
}

- (BOOL)isVerseLine:(NSString *)line
{
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    NSArray *components = [line componentsSeparatedByString:@"."];
    if ([components count] > 1 &&
        [components[0] length] > 0 &&
        [[components[0] stringLimitedToCharacterSet:decimalDigitCharacterSet] length] > 0) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)verseComponentsFromLine:(NSString *)line
{
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet *decimalDigitCharacterSet = [NSCharacterSet decimalDigitCharacterSet];
    NSArray *components = [line componentsSeparatedByString:@"."];

    NSNumber *number = @([[components[0] stringLimitedToCharacterSet:decimalDigitCharacterSet] integerValue]);
    
    // Recombine all but the first component
    components = [components subarrayWithRange:NSMakeRange(1, [components count] - 1)];
    line = [[components componentsJoinedByString:@"."] stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet];
    
    NSArray *ranges = [line rangesOfSubstring:@"chorus"];
    
    BOOL hasChorus = NO;
    if ([ranges count] > 0) {
        NSRange lastRange = [[ranges lastObject] rangeValue];
        
        if (([line length] - (lastRange.location + lastRange.length)) < 2) {
            hasChorus = YES;
            line = [line substringToIndex:[[ranges lastObject] rangeValue].location];
        }
    }
    
    line = [line stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet];
    
    return @{kNumberKey: number, kVerseTextKey: line, kHasChorusKey: @(hasChorus)};
}

- (BOOL)isUnNumberedVerseLine:(NSString *)line
{
    NSMutableCharacterSet *firstCharacterSet = [[NSMutableCharacterSet alloc] init];
    [firstCharacterSet formUnionWithCharacterSet:[NSCharacterSet uppercaseLetterCharacterSet]];
    [firstCharacterSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];

    if ([line length] > 0 &&
        [firstCharacterSet characterIsMember:[line characterAtIndex:0]]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSDictionary *)unNumberedVerseComponentsFromLine:(NSString *)line
{
    NSCharacterSet *whitespaceAndNewlineCharacterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];

    NSArray *ranges = [line rangesOfSubstring:@"chorus"];
    
    if ([ranges count] > 0) {
        line = [line substringToIndex:[[ranges lastObject] rangeValue].location];
    }
    
    line = [line stringByTrimmingCharactersInSet:whitespaceAndNewlineCharacterSet];
    
    BOOL hasChorus = [ranges count] > 0;
    
    return @{kVerseTextKey: line, kHasChorusKey: @(hasChorus)};
}

@end
