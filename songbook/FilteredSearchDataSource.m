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

@interface FilteredSearchDataSource()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSArray *matchingSongs;
@property (nonatomic, readonly) NSArray *matchingSections;
@property (nonatomic, strong) NSArray *matchingSongsBySection;
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

- (NSArray *)matchingSongs
{
    if (!_matchingSongs) {
        _matchingSongs = [self songsMatchingSearchString:self.searchString];
    }
    return _matchingSongs;
}

- (NSArray *)matchingSections
{
    NSMutableArray *sections = [NSMutableArray array];
    
    for (NSDictionary *songDictionary in self.matchingSongs) {
        Song *song = songDictionary[kSongKey];
        
        if (![sections containsObject:song.section]) {
            [sections addObject:song.section];
        }
    }
    
    return [sections copy];
}

- (NSArray *)matchingSongsBySection
{
    if (!_matchingSongsBySection) {
        NSMutableArray *matchingSongsBySection = [@[] mutableCopy];
        NSArray *sections = self.matchingSections;
        for (NSUInteger sectionIndex = 0; sectionIndex < [sections count]; sectionIndex++) {
            [matchingSongsBySection addObject:[self matchingSongsInSection:sections[sectionIndex]]];
        }
        _matchingSongsBySection = [matchingSongsBySection copy];
    }
    return _matchingSongsBySection;
}

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    self.matchingSongs = nil;
    self.matchingSongsBySection = nil;
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
    return [self.matchingSongsBySection[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *songDictionary = self.matchingSongsBySection[indexPath.section][indexPath.row];
    
    Song *songForRow = songDictionary[kSongKey];
    NSAttributedString *fragment = songDictionary[kFragmentKey];
    
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
    
    NSDictionary *songDictionary = self.matchingSongsBySection[indexPath.section][indexPath.row];
    
    Song *songForRow = songDictionary[kSongKey];
    NSAttributedString *fragment = songDictionary[kFragmentKey];

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
    NSDictionary *songDictionary = self.matchingSongsBySection[indexPath.section][indexPath.row];
    return songDictionary[kSongKey];
}

- (NSIndexPath *)indexPathForSong:(Song *)song
{
    return nil;
}

#pragma mark - Helper Methods

- (NSArray *)matchingSongsInSection:(Section *)section
{
    NSMutableArray *matchingSongs = [NSMutableArray array];
    
    for (NSDictionary *songDictionary in self.matchingSongs) {
        Song *matchingSong = songDictionary[kSongKey];
//        NSLog(@"Checking %@", [matchingSong headerString]);
        if (matchingSong.section == section) {
            [matchingSongs addObject:songDictionary];
        }
    }
    
    return [matchingSongs copy];
}

- (NSArray *)songsMatchingSearchString:(NSString *)searchString
{
    NSString *letterOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet letterCharacterSet]];
    NSString *decimalDigitOnlyString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([letterOnlyString length] > 0) {
        return [self tokenSearchForString:searchString];
    } else if ([decimalDigitOnlyString length] > 0) {
        return [self numberSearchForString:decimalDigitOnlyString];
    }
    
    return @[];
}

- (NSArray *)tokenSearchForString:(NSString *)searchString
{
    NSMutableArray *matchingSongs = [@[] mutableCopy];
    NSMutableArray *uniqueSongs = [@[] mutableCopy];
    
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
                Song *song = tokenInstance.song;
//                NSUInteger tokenIndex = [song.tokenInstances indexOfObject:tokenInstance];
                
                NSMutableArray *songTokenInstances = [@[] mutableCopy];
                
                [songTokenInstances addObject:tokenInstance];
                
                while (tokenInstance.nextInstance && [songTokenInstances count] < [searchTokens count]) {
                    tokenInstance = tokenInstance.nextInstance;
                    [songTokenInstances addObject:tokenInstance];
                }
                
                
//                NSArray *songTokenInstances = [[song.tokenInstances array] subarrayWithRange:NSMakeRange(tokenIndex, [song.tokenInstances count] - tokenIndex)];
                
                if ([songTokenInstances count] == [searchTokens count]) {
//                    songTokenInstances = [songTokenInstances subarrayWithRange:NSMakeRange(0, [searchTokens count])];
                    
                    NSMutableArray *songTokens = [@[] mutableCopy];
                    for (TokenInstance *songTokenInstance in songTokenInstances) {
                        [songTokens addObject:songTokenInstance.token];
                    }
                    
                    BOOL matched = [self tokenArray:songTokens matchesTokenOptionsArrays:searchTokens];
                    
//                    BOOL allMatched = YES;
//                    for (NSUInteger tokenPosition = 1; tokenPosition < [searchTokens count]; tokenPosition++) {
//                        BOOL foundMatch = NO;
//                        NSArray *tokenOptions = searchTokens[tokenPosition];
//                        Token *songToken = songTokens[tokenPosition]; //((TokenInstance *)songTokenInstances[tokenPosition]).token;
//                        for (Token *tokenOption in tokenOptions) {
//                            if ([tokenOption.text isEqualToString:songToken.text]) {
//                                foundMatch = YES;
//                                break;
//                            }
//                        }
//                        
//                        if (!foundMatch) {
//                            allMatched = NO;
//                            break;
//                        } else {
//                            NSLog(@"found match");
//                        }
//                    }
                    
                    if (matched) {
                        
                        if (![uniqueSongs containsObject:song]) {
                            [uniqueSongs addObject:song];
                            
                            // Add the song's title as a matching fragment.
                            NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
                            if (song.number) {
                                [titleString appendString:[song.number stringValue] attributes:self.matchingTitleAttributes];
                                [titleString appendString:@" " attributes:self.matchingTitleAttributes];
                            }
                            if ([song.title length] > 0) {
                                [titleString appendString:song.title attributes:self.normalTitleAttributes];
                            }
                            
                            NSArray *titleTokens = [titleString.string tokens];

                            // Make the matching text bold.
                            NSArray *titleRangeLists = [StringToken rangeListsMatchingTokens:searchStringTokens inTokens:titleTokens];
                            for (NSArray *rangeList in titleRangeLists) {
                                for (NSValue *rangeValue in rangeList) {
                                    NSRange range = [rangeValue rangeValue];
                                    
                                    // Make matching text black and bold.
                                    [titleString setAttributes:self.matchingTitleAttributes range:NSMakeRange(range.location, range.length)];
                                }
                            }
                            
                            // Add the title to the matching songs array.
                            [matchingSongs addObject:@{kSongKey: song,
                                                       kFragmentKey: titleString}];
                            
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
                            [matchingSongs addObject:@{kSongKey: song,
                                                       kFragmentKey: fragment}];
                        }
                        
                        
                    }
                }
            }
        }
    }

    return [matchingSongs copy];
}

- (BOOL)tokenArray:(NSArray *)tokenArray matchesTokenOptionsArrays:(NSArray *)tokenOptionsArrays
{
    BOOL matches = NO;
    
    
    NSMutableString *testString = [@"" mutableCopy];
    for (Token *token in tokenArray) {
        [testString appendFormat:@"%@ ", token.text];
    }
    NSLog(@"%@", testString);
    
    if ([tokenArray count] > 0 && [tokenArray count] == [tokenOptionsArrays count]) {
        
        matches = YES;
        
        for (NSUInteger tokenIndex = 0; tokenIndex < [tokenArray count]; tokenIndex++) {
            
            BOOL foundMatchingTokenAtIndex = NO;
            
            Token *token = tokenArray[tokenIndex];
            NSArray *tokenOptionsArray = tokenOptionsArrays[tokenIndex];
            
            for (Token *tokenOption in tokenOptionsArray) {
                if ([token.text isEqualToString:tokenOption.text]) {
                    foundMatchingTokenAtIndex = YES;
                    
//                    NSLog(@"%@ matches %@", token.text, tokenOption.text);
                    
                    break;
                } else {
                    if (tokenIndex > 0) {
//                        NSLog(@"%@ does not match %@", token.text, tokenOption.text);
                    }
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

- (NSArray *)numberSearchForString:(NSString *)searchString
{
    NSMutableArray *matchingSongs = [@[] mutableCopy];
    
    NSString *decimalDigitSearchString = [searchString stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
    
    if ([decimalDigitSearchString length] > 0) {
        
        for (Section *section in self.book.sections) {
            for (Song *song in section.songs) {
                
                if (song.number) {
                    
                    NSString *songNumberDecimalOnly = [[song.number stringValue] stringLimitedToCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
                    
                    if ([songNumberDecimalOnly hasPrefix:decimalDigitSearchString]) {
                        
                        // Add the song's title as a matching fragment.
                        NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
                        if (song.number) {
                            [titleString appendString:[song.number stringValue] attributes:self.matchingTitleAttributes];
                            [titleString appendString:@" " attributes:self.matchingTitleAttributes];
                        }
                        if ([song.title length] > 0) {
                            [titleString appendString:song.title attributes:self.normalTitleAttributes];
                        }
                        
                        // Add the title to the matching songs array.
                        [matchingSongs addObject:@{kSongKey: song,
                                                   kFragmentKey: titleString}];
                    }
                    
                }
                
            }
        }
        
    }
    
    return [matchingSongs copy];
}

@end
