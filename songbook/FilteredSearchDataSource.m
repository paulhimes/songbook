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

static const NSUInteger kFragmentPrefixMaxLength = 5;
static const NSUInteger kFragmentSuffixMaxLength = 20;
static const NSString * const kSongKey = @"SongKey";
static const NSString * const kFragmentKey = @"FragmentKey";

@interface FilteredSearchDataSource()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSArray *matchingSongs;
@property (nonatomic, readonly) NSArray *matchingSections;
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

- (void)setSearchString:(NSString *)searchString
{
    _searchString = searchString;
    self.matchingSongs = nil;
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
    Section *sectionForTableSection = self.matchingSections[section];
    return [[self matchingSongsInSection:sectionForTableSection] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionForTableSection = self.matchingSections[indexPath.section];
    NSDictionary *songDictionary = [self matchingSongsInSection:sectionForTableSection][indexPath.row];
    
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
    
    Section *sectionForTableSection = self.matchingSections[indexPath.section];
    NSDictionary *songDictionary = [self matchingSongsInSection:sectionForTableSection][indexPath.row];
    
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
    Section *sectionForTableSection = self.matchingSections[indexPath.section];
    NSDictionary *songDictionary = [self matchingSongsInSection:sectionForTableSection][indexPath.row];
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
    
    NSArray *searchStringTokens = [searchString tokens];
    
    for (Section *section in self.book.sections) {
        for (Song *song in section.songs) {
            
            NSString *stringForSearching = [song stringForSearching];
            NSArray *songTokens = [stringForSearching tokens];
            
            NSArray *rangeLists = [Token rangeListsMatchingTokens:searchStringTokens inTokens:songTokens];
            
            // Song title.
            if ([rangeLists count] > 0) {
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
                NSArray *titleRangeLists = [Token rangeListsMatchingTokens:searchStringTokens inTokens:titleTokens];
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
            for (NSArray *rangeList in rangeLists) {
                if ([rangeList count] > 0) {
                    NSRange firstRange = [rangeList[0] rangeValue];
                    
                    // Create an attributed string fragment around the matching ranges.
                    NSRange fragmentRange = NSMakeRange(firstRange.location, [stringForSearching length] - firstRange.location);
                    NSString *fragmentString = [stringForSearching substringWithRange:fragmentRange];
                    NSMutableAttributedString *fragment = [[NSMutableAttributedString alloc] initWithString:fragmentString attributes:self.normalFragmentAttributes];
                    
                    for (NSValue *rangeValue in rangeList) {
                        NSRange range = [rangeValue rangeValue];
                        
                        // Make matching text black and bold.
                        [fragment setAttributes:self.matchingFragmentAttributes range:NSMakeRange(range.location - firstRange.location, range.length)];
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
    
    return [matchingSongs copy];
}

- (NSArray *)numberSearchForString:(NSString *)searchString
{
    NSMutableArray *matchingSongs = [@[] mutableCopy];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    
    NSNumber *searchNumber = [formatter numberFromString:searchString];
    
    if (searchNumber) {
        for (Section *section in self.book.sections) {
            for (Song *song in section.songs) {
                
                if (song.number && [song.number isEqualToNumber:searchNumber]) {
                    
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
    
    return [matchingSongs copy];
}

@end
