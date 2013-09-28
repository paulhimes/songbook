//
//  FilteredSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "FilteredSearcher.h"
#import "Song+Helpers.h"
#import "Section.h"
#import "Token+Helpers.h"
#import "TokenInstance.h"

static const NSUInteger kFragmentPrefixMaxLength = 5;
static const NSUInteger kFragmentSuffixMaxLength = 20;
static const NSString * const kFragmentKey = @"FragmentKey";
static const NSString * const kLocationKey = @"LocationKey";

@implementation FilteredSearcher

+ (NSDictionary *)defaultAttributes
{
    UITableViewCell *cellSpecimen = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cellSpecimen.textLabel.text = @" ";
    return [cellSpecimen.textLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
}

+ (NSDictionary *)normalFragmentAttributes
{
    NSMutableDictionary *normalFragmentAttributes = [[FilteredSearcher defaultAttributes] mutableCopy];
    normalFragmentAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    normalFragmentAttributes[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    return [normalFragmentAttributes copy];
}

+ (NSDictionary *)matchingFragmentAttributes
{
    NSMutableDictionary *matchingFragmentAttributes = [[FilteredSearcher defaultAttributes] mutableCopy];
    matchingFragmentAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    matchingFragmentAttributes[NSForegroundColorAttributeName] = [UIColor blackColor];
    return [matchingFragmentAttributes copy];
}

+ (NSDictionary *)matchingSongFragmentsBySongIDForSearchString:(NSString *)searchString inBook:(Book *)book
{
    NSDictionary *matchingSongFragmentsBySongID;
    
    NSString *letterOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([letterOnlyString length] > 0) {
        matchingSongFragmentsBySongID = [FilteredSearcher tokenSearchForString:searchString inBook:book];
    } else if ([decimalDigitOnlyString length] > 0) {
        matchingSongFragmentsBySongID = [FilteredSearcher numberSearchForString:decimalDigitOnlyString inBook:book];
    }
    
    return matchingSongFragmentsBySongID;
}

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString inBook:(Book *)book
{
    NSDictionary *matchingSongFragmentsBySongID = [FilteredSearcher matchingSongFragmentsBySongIDForSearchString:searchString inBook:book];

    // Separate the songs into sections.
    NSMutableDictionary *songsIDsBySectionID = [@{} mutableCopy];
    for (NSManagedObjectID *songID in [matchingSongFragmentsBySongID allKeys]) {
        Song *song = (Song *)[book.managedObjectContext objectWithID:songID];
        
        NSMutableArray *songs = songsIDsBySectionID[song.section.objectID];
        if (!songs) {
            songs = [@[] mutableCopy];
            songsIDsBySectionID[song.section.objectID] = songs;
        }
        
        [songs addObject:song.objectID];
    }
    
    // Sort the songs within each section.
    for (NSMutableArray *songIDs in [songsIDsBySectionID allValues]) {
        [songIDs sortUsingComparator:^NSComparisonResult(NSManagedObjectID *songID1, NSManagedObjectID *songID2) {
            Song *song1 = (Song *)[book.managedObjectContext objectWithID:songID1];
            Song *song2 = (Song *)[book.managedObjectContext objectWithID:songID2];
            
            if (!song1.number) {
                if (!song2.number) {
                    return NSOrderedSame;
                } else {
                    return NSOrderedAscending;
                }
            }
            
            if (!song2.number) {
                if (!song1.number) {
                    return NSOrderedSame;
                } else {
                    return NSOrderedDescending;
                }
            }
            
            return [song1.number compare:song2.number];
        }];
    }
    
    // Sort the sections.
    NSArray *sortedSectionIDs = [[songsIDsBySectionID allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSManagedObjectID *sectionID1,
                                                                                                              NSManagedObjectID *sectionID2) {
        Section *section1 = (Section *)[book.managedObjectContext objectWithID:sectionID1];
        Section *section2 = (Section *)[book.managedObjectContext objectWithID:sectionID2];
        
        return [@([book.sections indexOfObject:section1]) compare:@([book.sections indexOfObject:section2])];
    }];
    
    // Build the search section models.
    NSMutableArray *sectionModels = [@[] mutableCopy];
    for (NSManagedObjectID *sectionID in sortedSectionIDs) {
        Section *section = (Section *)[book.managedObjectContext objectWithID:sectionID];
        
        // Build the search cell models.
        NSMutableArray *cellModels = [@[] mutableCopy];
        for (NSManagedObjectID *songID in songsIDsBySectionID[sectionID]) {
            NSString *songHeaderString = [(Song *)[book.managedObjectContext objectWithID:songID] headerString];
            NSArray *songFragments = matchingSongFragmentsBySongID[songID];

            for (NSDictionary *songFragment in songFragments) {
                NSAttributedString *fragment = songFragment[kFragmentKey];
                NSNumber *location = songFragment[kLocationKey];
                BOOL isTitleCell = [fragment.string isEqualToString:songHeaderString];

                SearchCellModel *cellModel = [[SearchCellModel alloc] initWithSongID:songID
                                                                             content:fragment
                                                                            location:[location unsignedIntegerValue]
                                                                         asTitleCell:isTitleCell];
                [cellModels addObject:cellModel];
            }
        }
        
        // Create the section.
        [sectionModels addObject:[[SearchSectionModel alloc] initWithTitle:section.title cellModels:[cellModels copy]]];
    }
    
    SearchTableModel *table = [[SearchTableModel alloc] initWithSectionModels:[sectionModels copy]];
    
    return table;
}

#pragma mark - Helper Methods

+ (NSDictionary *)tokenSearchForString:(NSString *)searchString inBook:(Book *)book
{
    NSDictionary *normalFragmentAttributes = [FilteredSearcher normalFragmentAttributes];
    NSDictionary *matchingFragmentAttributes = [FilteredSearcher matchingFragmentAttributes];
    
    NSMutableDictionary *matchingSongFragmentsBySongID = [@{} mutableCopy];
    
    NSArray *searchStringTokens = [searchString tokens];
    
    NSMutableArray *searchTokens = [@[] mutableCopy];
    for (StringToken *searchStringToken in searchStringTokens) {
        NSString *normalizedString = [searchStringToken.string stringByFoldingWithOptions:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch locale:nil];
        
        NSArray *tokens = [Token existingTokensStartingWithText:normalizedString
                                                      inContext:book.managedObjectContext];
        
        [searchTokens addObject:tokens];
    }
    
    if ([searchTokens count] > 0) {
        NSArray *firstTokenOptions = searchTokens[0];
        
        for (NSUInteger positionOption = 0; positionOption < [firstTokenOptions count]; positionOption++) {
            
            Token *token = firstTokenOptions[positionOption];
            
            for (__strong TokenInstance *tokenInstance in token.instances) {

                NSMutableArray *songTokenInstances = [@[] mutableCopy];
                [songTokenInstances addObject:tokenInstance];
                while (tokenInstance.nextInstance && [songTokenInstances count] < [searchTokens count]) {
                    tokenInstance = tokenInstance.nextInstance;
                    [songTokenInstances addObject:tokenInstance];
                }
                
                if ([songTokenInstances count] == [searchTokens count]) {
                    
                    NSMutableArray *songTokens = [@[] mutableCopy];
                    for (TokenInstance *songTokenInstance in songTokenInstances) {
                        [songTokens addObject:songTokenInstance.token];
                    }
                    
                    if ([self tokenArray:songTokens matchesTokenOptionsArrays:searchTokens]) {
                        
                        
                        Song *song = tokenInstance.song;
                        
                        NSMutableArray *matchingSongFragments = matchingSongFragmentsBySongID[song.objectID];
                        if (!matchingSongFragments) {
                            matchingSongFragments = [@[] mutableCopy];
                            matchingSongFragmentsBySongID[song.objectID] = matchingSongFragments;
                        }

                        // Song body.
                        if ([songTokenInstances count] > 0) {
                            TokenInstance *firstSongTokenInstance = songTokenInstances[0];
                            
                            // Create an attributed string fragment around the matching ranges.
                            NSString *stringForSearching = [song stringForSearching];
                            
                            NSRange fragmentRange = NSMakeRange([firstSongTokenInstance.location unsignedIntegerValue], [stringForSearching length] - [firstSongTokenInstance.location unsignedIntegerValue]);
                            NSString *fragmentString = [stringForSearching substringWithRange:fragmentRange];
                            NSMutableAttributedString *fragment = [[NSMutableAttributedString alloc] initWithString:fragmentString attributes:normalFragmentAttributes];
                            
                            for (TokenInstance *songTokenInstance in songTokenInstances) {
                                // Make matching text black and bold.
                                [fragment setAttributes:matchingFragmentAttributes range:NSMakeRange([songTokenInstance.location unsignedIntegerValue] - [firstSongTokenInstance.location unsignedIntegerValue], [songTokenInstance.length unsignedIntegerValue])];
                            }
                            
                            // Prepend the "..."
                            NSAttributedString *ellipsis = [[NSAttributedString alloc] initWithString:@"…" attributes:normalFragmentAttributes];
                            [fragment insertAttributedString:ellipsis atIndex:0];
                            
                            // Add this fragment entry to the matching songs array.
                            [matchingSongFragments addObject:@{kFragmentKey: fragment,
                                                               kLocationKey: firstSongTokenInstance.location}];
                        }
                        
                        
                    }
                }
            }
        }
    }
    
    // Sort the song fragments
    for (NSManagedObjectID *songId in [matchingSongFragmentsBySongID allKeys]) {
        NSMutableArray *matchingSongFragments = matchingSongFragmentsBySongID[songId];
        
        [matchingSongFragments sortUsingComparator:^NSComparisonResult(NSDictionary *fragment1, NSDictionary *fragment2) {
            NSNumber *fragement1StartIndex = fragment1[kLocationKey];
            NSNumber *fragement2StartIndex = fragment2[kLocationKey];
            
            return [fragement1StartIndex compare:fragement2StartIndex];
        }];
        
        matchingSongFragmentsBySongID[songId] = [matchingSongFragments copy];
    }

    return [matchingSongFragmentsBySongID copy];
}

+ (BOOL)tokenArray:(NSArray *)tokenArray matchesTokenOptionsArrays:(NSArray *)tokenOptionsArrays
{
    BOOL matches = NO;

    if ([tokenArray count] > 0 && [tokenArray count] == [tokenOptionsArrays count]) {
        
        matches = YES;
        
        for (NSUInteger tokenIndex = 0; tokenIndex < [tokenArray count]; tokenIndex++) {
            
            BOOL foundMatchingTokenAtIndex = NO;
            
            Token *token = tokenArray[tokenIndex];
            NSArray *tokenOptionsArray = tokenOptionsArrays[tokenIndex];
            
            for (Token *tokenOption in tokenOptionsArray) {
                if ([token.text isEqualToString:tokenOption.text]) {
                    foundMatchingTokenAtIndex = YES;
                    break;
                }
            }
            
            if (!foundMatchingTokenAtIndex) {
                matches = NO;
                break;
            }
        }
    }
    
    return matches;
}

+ (NSDictionary *)numberSearchForString:(NSString *)searchString inBook:(Book *)book
{
    NSMutableDictionary *matchingSongFragmentsBySongID = [@{} mutableCopy];
    
    NSString *decimalDigitSearchString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([decimalDigitSearchString length] > 0) {
        
        for (Section *section in book.sections) {
            for (Song *song in section.songs) {
                
                if (song.number) {
                    
                    NSString *songNumberDecimalOnly = [[song.number stringValue] stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
                    
                    if ([songNumberDecimalOnly hasPrefix:decimalDigitSearchString]) {
                        matchingSongFragmentsBySongID[song.objectID] = @[];
                    }
                    
                }
                
            }
        }
        
    }
    
    return [matchingSongFragmentsBySongID copy];
}

@end
