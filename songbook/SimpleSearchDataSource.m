//
//  SimpleSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SimpleSearchDataSource.h"
#import "Section.h"
#import "Song.h"

@interface SimpleSearchDataSource()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) NSString *searchString;

@end

@implementation SimpleSearchDataSource

- (instancetype)initWithBook:(Book *)book searchString:(NSString *)searchString
{
    self = [super init];
    if (self) {
        self.book = book;
        self.searchString = searchString;
    }
    return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.book.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    Section *sectionAtIndex = self.book.sections[section];
    return sectionAtIndex.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    Section *sectionForTableSection = self.book.sections[section];
    return [sectionForTableSection.songs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionForTableSection = self.book.sections[indexPath.section];
    Song *songForRow = sectionForTableSection.songs[indexPath.row];
    
    NSMutableDictionary *numberAttributes = [@{} mutableCopy];
    numberAttributes[NSFontAttributeName] = [UIFont boldSystemFontOfSize:18];
    NSMutableDictionary *titleAttributes = [@{} mutableCopy];
    titleAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:18];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:@""
                                                                                         attributes:nil];
    if (songForRow.number) {
        [attributedString appendString:[NSString stringWithFormat:@"%d", [songForRow.number integerValue]]attributes:numberAttributes];
        [attributedString appendString:@" " attributes:titleAttributes];
    }
    
    [attributedString appendString:songForRow.title attributes:titleAttributes];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    cell.textLabel.attributedText = attributedString;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *basicCell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell"];
    return basicCell.frame.size.height;
}

#pragma mark - SearchDataSource

- (Song *)songAtIndexPath:(NSIndexPath *)indexPath
{
    Section *sectionForTableSection = self.book.sections[indexPath.section];
    return sectionForTableSection.songs[indexPath.row];
}

- (NSIndexPath *)indexPathForSong:(Song *)song
{
    NSUInteger row = [song.section.songs indexOfObject:song];
    NSUInteger section = [song.section.book.sections indexOfObject:song.section];
    
    NSIndexPath *indexPath;
    
    if (row != NSNotFound &&
        section != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:row inSection:section];
    }
    
    return indexPath;
}

@end
