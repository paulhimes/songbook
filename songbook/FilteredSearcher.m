//
//  FilteredSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/27/13.
//

#import "FilteredSearcher.h"
#import "Song+Helpers.h"
#import "Section.h"
#import "Token+Helpers.h"
#import "TokenInstance.h"
#import "songbook-Swift.h"

static const NSString * const kFragmentKey = @"FragmentKey";
static const NSString * const kRangeKey = @"RangeKey";

@implementation FilteredSearcher

+ (NSDictionary *)normalFragmentAttributes
{
    NSMutableDictionary *normalFragmentAttributes = [@{} mutableCopy];
    normalFragmentAttributes[NSFontAttributeName] = [Theme fontForTextStyle:UIFontTextStyleBody];
    normalFragmentAttributes[NSForegroundColorAttributeName] = [Theme fadedTextColor];
    return [normalFragmentAttributes copy];
}

+ (NSDictionary *)matchingFragmentAttributes
{
    NSMutableDictionary *matchingFragmentAttributes = [@{} mutableCopy];
    matchingFragmentAttributes[NSFontAttributeName] = [Theme fontForTextStyle:UIFontTextStyleHeadline];
    matchingFragmentAttributes[NSForegroundColorAttributeName] = [Theme redColor];
    return [matchingFragmentAttributes copy];
}

+ (NSDictionary *)matchingSongFragmentsBySongIDForSearchString:(NSString *)searchString
                                                        inBook:(Book *)book
                                                shouldContinue:(BOOL (^)(void))shouldContinue
{
    NSDictionary *matchingSongFragmentsBySongID;
    
    NSString *letterOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([letterOnlyString length] > 0) {
        matchingSongFragmentsBySongID = [FilteredSearcher tokenSearchForString:searchString inBook:book shouldContinue:shouldContinue];
    } else if ([decimalDigitOnlyString length] > 0) {
        matchingSongFragmentsBySongID = [FilteredSearcher numberSearchForString:decimalDigitOnlyString inBook:book];
    }
    
    return matchingSongFragmentsBySongID;
}

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString
                                         inBook:(Book *)book
                                 shouldContinue:(BOOL (^)(void))shouldContinue
{
    NSDictionary *matchingSongFragmentsBySongID = [FilteredSearcher matchingSongFragmentsBySongIDForSearchString:searchString
                                                                                                          inBook:book
                                                                                                  shouldContinue:shouldContinue];

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
            
            Section *section = song1.section;
            
            return [@([section.songs indexOfObject:song1]) compare:@([section.songs indexOfObject:song2])];
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
            Song *song = (Song *)[book.managedObjectContext objectWithID:songID];
            NSString *songHeaderString = [song headerString];
            NSArray *songFragments = matchingSongFragmentsBySongID[songID];

            // Add the song title cell.
            [cellModels addObject:[[SearchTitleCellModel alloc] initWithSongID:songID
                                                                        number:[song.number unsignedIntegerValue]
                                                                         title:song.title]];
            
            for (NSDictionary *songFragment in songFragments) {
                NSAttributedString *fragment = songFragment[kFragmentKey];
                NSRange range = [songFragment[kRangeKey] rangeValue];
                
                if (range.location >= [songHeaderString length]) {
                    SearchContextCellModel *cellModel = [[SearchContextCellModel alloc] initWithSongID:songID
                                                                                               content:fragment
                                                                                                 range:range];
                    [cellModels addObject:cellModel];
                }
            }
        }
        
        // Create the section.
        [sectionModels addObject:[[SearchSectionModel alloc] initWithTitle:section.title cellModels:[cellModels copy]]];
    }
    
    // Add an "Exact Matches" section if appropriate.
    NSString *letterOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    NSMutableArray<SearchExactMatchCellModel *> *exactMatchCellModels = [@[] mutableCopy];
    if (letterOnlyString.length == 0 && decimalDigitOnlyString.length > 0) {
        for (Section *section in book.sections) {
            for (Song *song in section.songs) {
                if (song.number) {
                    NSString *songNumberDecimalOnly = [[song.number stringValue] stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
                    if ([songNumberDecimalOnly isEqualToString:decimalDigitOnlyString]) {
                        [exactMatchCellModels addObject:[[SearchExactMatchCellModel alloc] initWithSongID:song.objectID
                                                                                                   number:[song.number unsignedIntegerValue]
                                                                                                songTitle:song.title
                                                                                             sectionTitle:song.section.title]];
                    }
                }
            }
        }
    }
    // Don't show the exact matches section if it contains nothing but the exact same collection of songs as the other sections.
    BOOL nonExactCellModelFound = NO;
    for (SearchSectionModel *sectionModel in sectionModels) {
        for (id<SearchCellModel> cellModel in sectionModel.cellModels) {
            BOOL matchingSongFound = NO;
            for (id<SearchCellModel> exactMatchCellModel in exactMatchCellModels) {
                if ([cellModel.songID isEqual:exactMatchCellModel.songID]) {
                    matchingSongFound = YES;
                    break;
                }
            }
            if (!matchingSongFound) {
                nonExactCellModelFound = YES;
                break;
            }
        }
        if (nonExactCellModelFound) {
            break;
        }
    }
    if (exactMatchCellModels.count > 0 && nonExactCellModelFound) {
        [sectionModels insertObject:[[SearchSectionModel alloc] initWithTitle:@"Exact Matches" cellModels:[exactMatchCellModels copy]] atIndex:0];
    }
    
    SearchTableModel *table = [[SearchTableModel alloc] initWithSectionModels:[sectionModels copy] persistentStoreCoordinator:book.managedObjectContext.persistentStoreCoordinator];
    
    return table;
}

#pragma mark - Helper Methods

+ (NSDictionary *)tokenSearchForString:(NSString *)searchString inBook:(Book *)book shouldContinue:(BOOL (^)(void))shouldContinue
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
        
        for (NSUInteger optionIndex = 0; optionIndex < [firstTokenOptions count]; optionIndex++) {
            
            if (!shouldContinue()) {
                return nil;
            }
            
            Token *token = firstTokenOptions[optionIndex];
            
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
                            NSString *stringForSearching = [song string];
                            
                            NSRange fragmentRange = NSMakeRange([firstSongTokenInstance.location unsignedIntegerValue], [stringForSearching length] - [firstSongTokenInstance.location unsignedIntegerValue]);
                            NSString *fragmentString = [stringForSearching substringWithRange:fragmentRange];
                            NSMutableAttributedString *fragment = [[NSMutableAttributedString alloc] initWithString:fragmentString attributes:normalFragmentAttributes];
                            
                            // Calculate the range of the matching text within the song.
                            TokenInstance *lastSongTokenInstance = [songTokenInstances lastObject];
                            NSRange matchingRange = NSMakeRange([firstSongTokenInstance.location unsignedIntegerValue], [lastSongTokenInstance.location unsignedIntegerValue] + [lastSongTokenInstance.length unsignedIntegerValue] - [firstSongTokenInstance.location unsignedIntegerValue]);
                            
                            // Highlight the matching text.
                            [fragment setAttributes:matchingFragmentAttributes range:NSMakeRange(0, [lastSongTokenInstance.location unsignedIntegerValue] + [lastSongTokenInstance.length unsignedIntegerValue] - [firstSongTokenInstance.location unsignedIntegerValue])];
                            
                            // Prepend the "..."
                            NSAttributedString *ellipsis = [[NSAttributedString alloc] initWithString:@"…" attributes:normalFragmentAttributes];
                            [fragment insertAttributedString:ellipsis atIndex:0];
                            
                            // Replace all new line characters with spaces.
                            NSMutableString *mutableFragmentString = [fragment mutableString];
                            [mutableFragmentString replaceOccurrencesOfString:@"\n" withString:@" " options:0 range:NSMakeRange(0, [mutableFragmentString length])];
                            
                            // Add this fragment entry to the matching songs array.
                            [matchingSongFragments addObject:@{kFragmentKey: fragment,
                                                               kRangeKey: [NSValue valueWithRange:matchingRange]}];
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
            NSNumber *fragement1StartIndex = @([fragment1[kRangeKey] rangeValue].location);
            NSNumber *fragement2StartIndex = @([fragment2[kRangeKey] rangeValue].location);
            
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
