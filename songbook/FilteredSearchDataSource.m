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

@end

@implementation FilteredSearchDataSource

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
    UITableViewCell *cellSpecimen = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    cellSpecimen.textLabel.text = @" ";
    NSMutableDictionary *defaultAttributes = [[cellSpecimen.textLabel.attributedText attributesAtIndex:0 effectiveRange:NULL] mutableCopy];
    
    NSMutableDictionary *normalTitle = [defaultAttributes mutableCopy];
    normalTitle[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    NSMutableDictionary *boldTitle = [normalTitle mutableCopy];
    boldTitle[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];

    NSMutableDictionary *normalFragment = [defaultAttributes mutableCopy];
    normalFragment[NSFontAttributeName] = [UIFont systemFontOfSize:16];
    normalFragment[NSForegroundColorAttributeName] = [UIColor darkGrayColor];
    
    NSMutableDictionary *boldFragment = [defaultAttributes mutableCopy];
    boldFragment[NSFontAttributeName] = [UIFont boldSystemFontOfSize:16];
    boldFragment[NSForegroundColorAttributeName] = [UIColor blackColor];
    
    NSMutableArray *matchingSongs = [@[] mutableCopy];
    
    NSArray *searchStringTokens = [searchString tokens];
    
    for (Section *section in self.book.sections) {
        for (Song *song in section.songs) {
            NSString *stringForSearching = [song stringForSearching];
            NSArray *songTokens = [stringForSearching tokens];
            
            NSArray *rangeLists = [Token rangeListsMatchingTokens:searchStringTokens inTokens:songTokens];
            
            if ([rangeLists count] > 0) {
                // Add the song's title as a matching fragment.
                NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] init];
                if (song.number) {
                    [titleString appendString:[song.number stringValue] attributes:boldTitle];
                    [titleString appendString:@" " attributes:boldTitle];
                }
                if ([song.title length] > 0) {
                    [titleString appendString:song.title attributes:normalTitle];
                }
                
                // Make the matching text bold.
                [titleString addAttributes:boldTitle toFirstOccurrenceOfString:searchString];

                // Add the title to the matching songs array.
                [matchingSongs addObject:@{kSongKey: song,
                                           kFragmentKey: titleString}];
            }
            
            for (NSArray *rangeList in rangeLists) {
                if ([rangeList count] > 0) {
                    NSRange firstRange = [rangeList[0] rangeValue];
                    
                    // Create an attributed string fragment around the matching ranges.
                    NSRange fragmentRange = NSMakeRange(firstRange.location, [stringForSearching length] - firstRange.location);
                    NSString *fragmentString = [stringForSearching substringWithRange:fragmentRange];
                    NSMutableAttributedString *fragment = [[NSMutableAttributedString alloc] initWithString:fragmentString attributes:normalFragment];
                    
                    for (NSValue *rangeValue in rangeList) {
                        NSRange range = [rangeValue rangeValue];
                        
                        // Make matching text black and bold.
                        [fragment setAttributes:boldFragment range:NSMakeRange(range.location - firstRange.location, range.length)];
                    }
                    
                    // Prepend the "..."
                    NSAttributedString *ellipsis = [[NSAttributedString alloc] initWithString:@"…" attributes:normalFragment];
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

@end
