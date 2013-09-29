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
            self.tableModel = [[SearchTableModel alloc] initWithSectionModels:@[]];
        }
    }
    return self;
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
    SearchCellModel *cellModel = sectionModel.cellModels[indexPath.row];
    
    UITableViewCell *cell;
    if (cellModel.titleCell) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"BasicCell" forIndexPath:indexPath];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContextCell" forIndexPath:indexPath];
    }
    
    cell.textLabel.attributedText = cellModel.content;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.tableModel.sectionModels count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    SearchSectionModel *sectionModel = self.tableModel.sectionModels[section];
    return sectionModel.title;
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
    SearchCellModel *cellModel = sectionModel.cellModels[indexPath.row];
    
    CGFloat cellHeight;
    if (cellModel.titleCell) {
        cellHeight = self.basicHeight;
    } else {
        cellHeight = self.contextHeight;
    }
    
    return cellHeight;
}

@end
