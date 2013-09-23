//
//  FilteredSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "FilteredSearchDataSource.h"
#import "Song+Helpers.h"
#import "Section.h"
#import "Token+Helpers.h"
#import "TokenInstance.h"

static const NSUInteger kFragmentPrefixMaxLength = 5;
static const NSUInteger kFragmentSuffixMaxLength = 20;
static const NSString * const kSongKey = @"SongKey";
static const NSString * const kFragmentKey = @"FragmentKey";
static const NSString * const kLocationKey = @"LocationKey";

@interface FilteredSearchDataSource()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSDictionary *matchingSongFragmentsBySongID;
@property (nonatomic, strong) NSArray *matchingSections;
@property (nonatomic, strong) NSArray *matchingSongsBySection;
@property (nonatomic, strong) NSArray *fragmentDictionariesBySection;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic) CGFloat basicHeight;
@property (nonatomic) CGFloat contextHeight;

@property (nonatomic, strong) NSDictionary *defaultAttributes;
@property (nonatomic, strong) NSDictionary *normalTitleAttributes;
@property (nonatomic, strong) NSDictionary *matchingTitleAttributes;
@property (nonatomic, strong) NSDictionary *normalFragmentAttributes;
@property (nonatomic, strong) NSDictionary *matchingFragmentAttributes;

@end

@implementation FilteredSearchDataSource

- (NSDictionary *)defaultAttributes
{
    if (!_defaultAttributes) {
        UITableViewCell *cellSpecimen = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cellSpecimen.textLabel.text = @" ";
        _defaultAttributes = [cellSpecimen.textLabel.attributedText attributesAtIndex:0 effectiveRange:NULL];
    }
    return _defaultAttributes;
}

- (NSDictionary *)normalTitleAttributes
{
    if (!_normalTitleAttributes) {
        NSMutableDictionary *normalTitleAttributes = [self.defaultAttributes mutableCopy];
        normalTitleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
        _normalTitleAttributes = [normalTitleAttributes copy];
    }
    return _normalTitleAttributes;
}

- (NSDictionary *)matchingTitleAttributes
{
    if (!_matchingTitleAttributes) {
        NSMutableDictionary *boldTitleAttributes = [self.normalTitleAttributes mutableCopy];
        boldTitleAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
        _matchingTitleAttributes = [boldTitleAttributes copy];
    }
    return _matchingTitleAttributes;
}

- (NSDictionary *)normalFragmentAttributes
{
    if (!_normalFragmentAttributes) {
        NSMutableDictionary *normalFragmentAttributes = [self.defaultAttributes mutableCopy];
        normalFragmentAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:16];
        normalFragmentAttributes[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
        _normalFragmentAttributes = [normalFragmentAttributes copy];
    }
    return _normalFragmentAttributes;
}

- (NSDictionary *)matchingFragmentAttributes
{
    if (!_matchingFragmentAttributes) {
        NSMutableDictionary *matchingFragmentAttributes = [self.defaultAttributes mutableCopy];
        matchingFragmentAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
        matchingFragmentAttributes[NSForegroundColorAttributeName] = [UIColor blackColor];
        _matchingFragmentAttributes = [matchingFragmentAttributes copy];
    }
    return _matchingFragmentAttributes;
}

- (NSDictionary *)matchingSongFragmentsBySongID
{
    if (!_matchingSongFragmentsBySongID) {
        
        NSDictionary *matchingSongFragmentsBySongID;
        
        NSString *searchString = self.searchString;
        NSString *letterOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
        NSString *decimalDigitOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
        
        if ([letterOnlyString length] > 0) {
            matchingSongFragmentsBySongID = [self tokenSearchForString:searchString];
        } else if ([decimalDigitOnlyString length] > 0) {
            matchingSongFragmentsBySongID = [self numberSearchForString:decimalDigitOnlyString];
        }
        
        _matchingSongFragmentsBySongID = matchingSongFragmentsBySongID;
    }
    return _matchingSongFragmentsBySongID;
}

- (NSArray *)matchingSections
{
    if (!_matchingSections) {
        
        NSMutableArray *sections = [NSMutableArray array];
        
        for (NSManagedObjectID *songID in [self.matchingSongFragmentsBySongID allKeys]) {
            Song *song = (Song *)[self.book.managedObjectContext objectWithID:songID];
            
            if (![sections containsObject:song.section]) {
                [sections addObject:song.section];
            }
        }
        
        // Sort the sections using book order.
        [sections sortedArrayUsingComparator:^NSComparisonResult(Section *section1, Section *section2) {
            return [@([self.book.sections indexOfObject:section1]) compare:@([self.book.sections indexOfObject:section1])];
        }];
        
        _matchingSections = [sections copy];
    }
    return _matchingSections;
}

- (NSArray *)matchingSongsBySection
{
    if (!_matchingSongsBySection) {
        NSMutableArray *sortedMatchingSongsBySection = [@[] mutableCopy];
        NSArray *sections = self.matchingSections;
        
        for (Section *section in sections) {
            
            NSMutableArray *sortedMatchingSongs = [@[] mutableCopy];
            
            for (NSManagedObjectID *songID in [self.matchingSongFragmentsBySongID allKeys]) {
                Song *song = (Song *)[self.book.managedObjectContext objectWithID:songID];
                
                if (song.section == section) {
                    [sortedMatchingSongs addObject:song];
                }
            }
            
            [sortedMatchingSongs sortUsingComparator:^NSComparisonResult(Song *song1, Song *song2) {
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
            
            [sortedMatchingSongsBySection addObject:[sortedMatchingSongs copy]];
        }
        
        _matchingSongsBySection = [sortedMatchingSongsBySection copy];
    }
    return _matchingSongsBySection;
}

- (NSArray *)fragmentDictionariesBySection
{
    if (!_fragmentDictionariesBySection) {
        
        NSMutableArray *fragmentDictionariesBySection = [@[] mutableCopy];
        
        for (NSUInteger sectionIndex = 0; sectionIndex < [self.matchingSections count]; sectionIndex++) {
            
            NSMutableArray *fragmentDictionaries = [@[] mutableCopy];
            
            NSArray *songsInSection = self.matchingSongsBySection[sectionIndex];
            for (Song *song in songsInSection) {
                NSArray *matchingSongFragments = self.matchingSongFragmentsBySongID[song.objectID];
                
                // Add the song's title as a matching fragment.
                NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
                if (song.number) {
                    [titleString appendString:[song.number stringValue] attributes:self.matchingTitleAttributes];
                    [titleString appendString:@" " attributes:self.matchingTitleAttributes];
                }
                if ([song.title length] > 0) {
                    [titleString appendString:song.title attributes:self.normalTitleAttributes];
                }
                //            NSArray *titleTokens = [titleString.string tokens];
                //
                //            // Make the matching text bold.
                //            NSArray *titleRangeLists = [StringToken rangeListsMatchingTokens:searchStringTokens inTokens:titleTokens];
                //            for (NSArray *rangeList in titleRangeLists) {
                //                for (NSValue *rangeValue in rangeList) {
                //                    NSRange range = [rangeValue rangeValue];
                //
                //                    // Make matching text black and bold.
                //                    [titleString setAttributes:self.matchingTitleAttributes range:NSMakeRange(range.location, range.length)];
                //                }
                //}
                
                [fragmentDictionaries addObject:@{kSongKey: song,
                                                  kFragmentKey: titleString}];
                [fragmentDictionaries addObjectsFromArray:matchingSongFragments];
            }
            
            [fragmentDictionariesBySection addObject:[fragmentDictionaries copy]];
        }
        
        _fragmentDictionariesBySection = fragmentDictionariesBySection;
    }
    
    return _fragmentDictionariesBySection;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    self.matchingSongFragmentsBySongID = nil;
    self.matchingSections = nil;
    self.matchingSongsBySection = nil;
    self.fragmentDictionariesBySection = nil;
}

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.matchingSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sectionAtIndex = self.matchingSections[section];
    return sectionAtIndex.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.fragmentDictionariesBySection[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *fragmentDictionaryAtIndexPath = self.fragmentDictionariesBySection[indexPath.section][indexPath.row];
    
    Song *songForRow = fragmentDictionaryAtIndexPath[kSongKey];
    NSAttributedString *fragment = fragmentDictionaryAtIndexPath[kFragmentKey];
    
    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion-Bold" size:30];
    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont fontWithName:@"Marion" size:22];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                         attributes:nil];
    if (songForRow.number) {
        [attributedString appendString:[NSString stringWithFormat:@"%d", [songForRow.number integerValue]]attributes:numberAttributes];
        [attributedString appendString:@" " attributes:titleAttributes];
    }
    
    [attributedString appendString:songForRow.title attributes:titleAttributes];
    
    
    
    UITableViewCell *cell;
    if ([fragment.string isEqualToString:[songForRow headerString]]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell" forIndexPath:indexPath];
    }

    cell.textLabel.attributedText = fragment;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.basicHeight == 0) {
        UITableViewCell *basicCell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
        self.basicHeight = basicCell.frame.size.height;
    }
    if (self.contextHeight == 0) {
        UITableViewCell *contextCell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell"];
        self.contextHeight = contextCell.frame.size.height;
    }
    
    NSDictionary *fragmentDictionaryAtIndexPath = self.fragmentDictionariesBySection[indexPath.section][indexPath.row];

    Song *songForRow = fragmentDictionaryAtIndexPath[kSongKey];
    NSAttributedString *fragment = fragmentDictionaryAtIndexPath[kFragmentKey];

    CGFloat cellHeight;
    if ([fragment.string isEqualToString:[songForRow headerString]]) {
        cellHeight = self.basicHeight;
    } else {
        cellHeight = self.contextHeight;
    }
    
    return cellHeight;
}

#pragma mark - SearchDataSource

- (Song *)songAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *fragmentDictionaryAtIndexPath = self.fragmentDictionariesBySection[indexPath.section][indexPath.row];
    return fragmentDictionaryAtIndexPath[kSongKey];
}

- (NSIndexPath *)indexPathForSong:(Song *)song
{
    return nil;
}

#pragma mark - Helper Methods

- (NSDictionary *)tokenSearchForString:(NSString *)searchString
{
    NSMutableDictionary *matchingSongFragmentsBySongID = [@{} mutableCopy];
    
    NSArray *searchStringTokens = [searchString tokens];
    
    NSMutableArray *searchTokens = [@[] mutableCopy];
    for (StringToken *searchStringToken in searchStringTokens) {
        NSString *normalizedString = [searchStringToken.string stringByFoldingWithOptions:NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch | NSWidthInsensitiveSearch locale:nil];
        
        NSArray *tokens = [Token existingTokensStartingWithText:normalizedString
                                                      inContext:self.book.managedObjectContext];
        
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
                            NSMutableAttributedString *fragment = [[NSMutableAttributedString alloc] initWithString:fragmentString attributes:self.normalFragmentAttributes];
                            
                            for (TokenInstance *songTokenInstance in songTokenInstances) {
                                // Make matching text black and bold.
                                [fragment setAttributes:self.matchingFragmentAttributes range:NSMakeRange([songTokenInstance.location unsignedIntegerValue] - [firstSongTokenInstance.location unsignedIntegerValue], [songTokenInstance.length unsignedIntegerValue])];
                            }
                            
                            // Prepend the "..."
                            NSAttributedString *ellipsis = [[NSAttributedString alloc] initWithString:@"…" attributes:self.normalFragmentAttributes];
                            [fragment insertAttributedString:ellipsis atIndex:0];
                            
                            // Add this fragment entry to the matching songs array.
                            [matchingSongFragments addObject:@{kSongKey: song,
                                                               kFragmentKey: fragment,
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

- (BOOL)tokenArray:(NSArray *)tokenArray matchesTokenOptionsArrays:(NSArray *)tokenOptionsArrays
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

- (NSDictionary *)numberSearchForString:(NSString *)searchString
{
    NSMutableDictionary *matchingSongFragmentsBySongID = [@{} mutableCopy];
    
    NSString *decimalDigitSearchString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([decimalDigitSearchString length] > 0) {
        
        for (Section *section in self.book.sections) {
            for (Song *song in section.songs) {
                
                if (song.number) {
                    
                    NSString *songNumberDecimalOnly = [[song.number stringValue] stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
                    
                    if ([songNumberDecimalOnly hasPrefix:decimalDigitSearchString]) {
                        
//                        // Add the song's title as a matching fragment.
//                        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
//                        if (song.number) {
//                            [titleString appendString:[song.number stringValue] attributes:self.matchingTitleAttributes];
//                            [titleString appendString:@" " attributes:self.matchingTitleAttributes];
//                        }
//                        if ([song.title length] > 0) {
//                            [titleString appendString:song.title attributes:self.normalTitleAttributes];
//                        }
//                        
//                        // Add the title to the matching songs array.
//                        [matchingSongs addObject:@{kSongKey: song,
//                                                   kFragmentKey: titleString}];
                        
                        matchingSongFragmentsBySongID[song.objectID] = @[];
                    }
                    
                }
                
            }
        }
        
    }
    
    return [matchingSongFragmentsBySongID copy];
}

@end
