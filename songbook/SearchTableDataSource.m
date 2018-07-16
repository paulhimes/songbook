//
//  SearchTableDataSource.m
//  songbook
//
//  Created by Paul Himes on 9/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchTableDataSource.h"
#import "SearchSectionModel.h"
#import "SearchCellModel.h"
#import "SearchTitleCellModel.h"
#import "SearchContextCellModel.h"
#import "BasicCell.h"
#import "ContextCell.h"
#import "songbook-Swift.h"

@interface SearchTableDataSource()

@property (nonatomic, strong) SearchTableModel *tableModel;

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
    if ([cellModel isKindOfClass:[SearchExactMatchCellModel class]]) {
        SearchExactMatchCellModel *searchExactMatchCellModel = (SearchExactMatchCellModel *)cellModel;
        ExactMatchCell *exactMatchCell = [tableView dequeueReusableCellWithIdentifier:@"ExactMatchCell" forIndexPath:indexPath];
        
        exactMatchCell.sectionTitleLabel.textColor = [Theme textColor];
        exactMatchCell.sectionTitleLabel.text = searchExactMatchCellModel.sectionTitle;
        exactMatchCell.sectionTitleLabel.font = [Theme fontForTextStyle:UIFontTextStyleCaption1];
        
        exactMatchCell.numberLabel.textColor = [Theme textColor];
        if (searchExactMatchCellModel.number > 0) {
            exactMatchCell.numberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)searchExactMatchCellModel.number];
        } else {
            exactMatchCell.numberLabel.text = @"";
        }
        exactMatchCell.numberLabel.font = [Theme fontForTextStyle:UIFontTextStyleHeadline];
        exactMatchCell.hiddenSpacerLabel.font = [Theme fontForTextStyle:UIFontTextStyleHeadline];
        
        exactMatchCell.songTitleLabel.textColor = [Theme textColor];
        exactMatchCell.songTitleLabel.text = searchExactMatchCellModel.songTitle;
        exactMatchCell.songTitleLabel.font = [Theme fontForTextStyle:UIFontTextStyleBody];
        
        cell = exactMatchCell;
    } else if ([cellModel isKindOfClass:[SearchTitleCellModel class]]) {
        SearchTitleCellModel *searchTitleCellModel = (SearchTitleCellModel *)cellModel;
        BasicCell *basicCell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
        
        basicCell.numberLabel.textColor = [Theme textColor];
        if (searchTitleCellModel.number > 0) {
            basicCell.numberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)searchTitleCellModel.number];
        } else {
            basicCell.numberLabel.text = @"";
        }
        basicCell.numberLabel.font = [Theme fontForTextStyle:UIFontTextStyleHeadline];
        basicCell.hiddenSpacerLabel.font = [Theme fontForTextStyle:UIFontTextStyleHeadline];
        
        basicCell.titleLabel.textColor = [Theme textColor];
        basicCell.titleLabel.text = searchTitleCellModel.title;
        basicCell.titleLabel.font = [Theme fontForTextStyle:UIFontTextStyleBody];
        
        cell = basicCell;
    } else if ([cellModel isKindOfClass:[SearchContextCellModel class]]) {
        SearchContextCellModel *searchContextCellModel = (SearchContextCellModel *)cellModel;
        ContextCell *contextCell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell" forIndexPath:indexPath];
        [contextCell setAttributedText:searchContextCellModel.content];
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
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[section];
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [Theme grayTrimColor];

    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.adjustsFontForContentSizeCategory = YES;
    
    label.attributedText = [[NSAttributedString alloc] initWithString:sectionModel.title attributes:@{NSForegroundColorAttributeName: [Theme paperColor],
                                                                                                      NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]}];
    
    [headerView addSubview:label];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[label]-2-|" options:0 metrics:nil views:@{@"label": label}]];
    [headerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:@{@"label": label}]];
    
    return headerView;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Get the selected song.
    NSManagedObjectID *selectedSongID = [self songIDAtIndexPath:indexPath];
    
    // Which location in the song was selected.
    NSRange selectedRange = [self songRangeAtIndexPath:indexPath];
    
    [self.delegate selectedSong:selectedSongID withRange:selectedRange];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.delegate tableViewScrolled];
}

#pragma mark - UIDataSourceModelAssociation

- (NSString *)modelIdentifierForElementAtIndexPath:(NSIndexPath *)idx inView:(UIView *)view
{
    NSManagedObjectID *songId = [self songIDAtIndexPath:idx];
    NSRange range = [self songRangeAtIndexPath:idx];
    
    NSURL *url = [songId URIRepresentation];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)range.location]];
    url = [url URLByAppendingPathComponent:[NSString stringWithFormat:@"%lu", (unsigned long)range.length]];
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
