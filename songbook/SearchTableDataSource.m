//
//  SearchTableDataSource.m
//  songbook
//
//  Created by Paul Himes on 9/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchTableDataSource.h"
#import "SearchSectionModel.h"
#import "SearchTitleCellModel.h"
#import "SearchContextCellModel.h"
#import "SearchHeaderFooterView.h"
#import "BasicCell.h"
#import "ContextCell.h"

@interface SearchTableDataSource()

@property (nonatomic, strong) SearchTableModel *tableModel;
@property (nonatomic) CGFloat basicHeight;
@property (nonatomic) CGFloat contextHeight;

@end

@implementation SearchTableDataSource

- (instancetype)initWithTableModel:(SearchTableModel *)tableModel
{
    self = [super init];
    if (self) {
        self.tableModel = tableModel;
        if (!self.tableModel || [self.tableModel.sectionModels count] < 1) {
            self.tableModel = [[SearchTableModel alloc] initWithSectionModels:@[[[SearchSectionModel alloc] initWithTitle:@"No Results" cellModels:@[]]] persistentStoreCoordinator:nil];
        }
    }
    return self;
}

- (NSManagedObjectID *)songIDAtIndexPath:(NSIndexPath *)indexPath
{
    id<SearchCellModel> cell = [self cellModelAtIndexPath:indexPath];
    return cell.songID;
}

- (NSRange)songRangeAtIndexPath:(NSIndexPath *)indexPath
{
    id<SearchCellModel> cell = [self cellModelAtIndexPath:indexPath];
    return cell.range;
}

- (id<SearchCellModel>)cellModelAtIndexPath:(NSIndexPath *)indexPath
{
    SearchSectionModel *section = indexPath.section < [self.tableModel.sectionModels count] ? self.tableModel.sectionModels[indexPath.section] : nil;
    id<SearchCellModel> cell = indexPath.row < [section.cellModels count] ? section.cellModels[indexPath.row] : nil;
    
    return cell;
}

- (NSIndexPath *)indexPathForSongID:(NSManagedObjectID *)songID andRange:(NSRange)range
{
    for (NSUInteger sectionIndex = 0; sectionIndex < [self.tableModel.sectionModels count]; sectionIndex++) {
        SearchSectionModel *section = self.tableModel.sectionModels[sectionIndex];
        for (NSInteger row = 0; row < [section.cellModels count]; row++) {
            id<SearchCellModel> cell = section.cellModels[row];
            
            if ([cell.songID isEqual:songID] && NSEqualRanges(cell.range, range)) {
                return [NSIndexPath indexPathForRow:row inSection:sectionIndex];
            }
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDataSource

//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    NSMutableArray *sectionIndexTitles = [@[] mutableCopy];
//    [self.tableModel.sectionModels enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        SearchSectionModel *section = (SearchSectionModel *)obj;
//        NSString *title = [section.title substringToIndex:MIN(5, [section.title length])];
//        [sectionIndexTitles addObject:title];
//    }];
//    
//    return [sectionIndexTitles copy];
//}
//
//- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//{
//    return index;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[section];
    return [sectionModel.cellModels count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[indexPath.section];
    id<SearchCellModel> cellModel = sectionModel.cellModels[indexPath.row];
    
    UITableViewCell *cell;
    if ([cellModel isKindOfClass:[SearchTitleCellModel class]]) {
        SearchTitleCellModel *searchTitleCellModel = (SearchTitleCellModel *)cellModel;
        BasicCell *basicCell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        
        basicCell.numberLabel.textColor = [Theme textColor];
        if (searchTitleCellModel.number > 0) {
            basicCell.numberLabel.text = [NSString stringWithFormat:@"%d", searchTitleCellModel.number];
        } else {
            basicCell.numberLabel.text = @"";
        }
        
        basicCell.titleLabel.textColor = [Theme textColor];
        basicCell.titleLabel.text = searchTitleCellModel.title;
        cell = basicCell;
    } else if ([cellModel isKindOfClass:[SearchContextCellModel class]]) {
        SearchContextCellModel *searchContextCellModel = (SearchContextCellModel *)cellModel;
        ContextCell *contextCell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell" forIndexPath:indexPath];
        contextCell.contentLabel.attributedText = searchContextCellModel.content;
        cell = contextCell;
    }
    
    cell.backgroundColor = [Theme paperColor];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableModel.sectionModels count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerFooterView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSearchHeaderFooterFiewIdentifier];
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[section];
    headerFooterView.textLabel.text = sectionModel.title;
    return headerFooterView;
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
    
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[indexPath.section];
    id<SearchCellModel> cellModel = sectionModel.cellModels[indexPath.row];
    
    CGFloat cellHeight;
    if ([cellModel isKindOfClass:[SearchTitleCellModel class]]) {
        cellHeight = self.basicHeight;
    } else {
        cellHeight = self.contextHeight;
    }
    
    return cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the selected song.
    NSManagedObjectID *selectedSongID = [self songIDAtIndexPath:indexPath];
    
    // Which location in the song was selected.
    NSRange selectedRange = [self songRangeAtIndexPath:indexPath];
    
    [self.delegate selectedSong:selectedSongID withRange:selectedRange];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIDataSourceModelAssociation

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    NSManagedObjectID *songId = [self songIDAtIndexPath:idx];
    NSRange range = [self songRangeAtIndexPath:idx];
    
    NSURL *url = [songId URIRepresentation];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%d", range.location]];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%d", range.length]];
    return [url absoluteString];
}

- (NSIndexPath *)indexPathForElementWithModelIdentifier:(NSString *)identifier inView:(UIView *)view
{
    NSURL *url =  [NSURL URLWithString:identifier];
    NSInteger length = [[url lastPathComponent] integerValue];
    url = [url URLByDeletingLastPathComponent];
    NSInteger location = [[url lastPathComponent] integerValue];
    url = [url URLByDeletingLastPathComponent];
    
    NSRange range = NSMakeRange(location, length);
    NSManagedObjectID *songId = [self.tableModel.coordinator managedObjectIDForURIRepresentation:url];
    
    NSIndexPath *indexPath = [self indexPathForSongID:songId andRange:range];
    return indexPath;
}

@end
