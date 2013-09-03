//
//  SmartSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SmartSearchDataSource.h"
#import "SimpleSearchDataSource.h"
#import "FilteredSearchDataSource.h"

@interface SmartSearchDataSource()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) id<SearchDataSource> activeDataSource;
@property (nonatomic, strong) SimpleSearchDataSource *simpleDataSource;
@property (nonatomic, strong) FilteredSearchDataSource *filteredDataSource;

@end

@implementation SmartSearchDataSource

#pragma mark - SearchDataSource

- (void)setSearchString:(NSString *)searchString
{
    [self.filteredDataSource setSearchString:searchString];
    [self.simpleDataSource setSearchString:searchString];
    
    self.activeDataSource = [searchString length] > 0 ? self.filteredDataSource : self.simpleDataSource;
}

- (id<SearchDataSource>)activeDataSource
{
    if (!_activeDataSource) {
        _activeDataSource = self.simpleDataSource;
    }
    return _activeDataSource;
}

- (SimpleSearchDataSource *)simpleDataSource
{
    if (!_simpleDataSource) {
        _simpleDataSource = [[SimpleSearchDataSource alloc] initWithBook:self.book];
    }
    return _simpleDataSource;
}

- (FilteredSearchDataSource *)filteredDataSource
{
    if (!_filteredDataSource) {
        _filteredDataSource = [[FilteredSearchDataSource alloc] initWithBook:self.book];
    }
    return _filteredDataSource;
}

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
    }
    return self;
}

- (Song *)songAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.activeDataSource songAtIndexPath:indexPath];
}
- (NSIndexPath *)indexPathForSong:(Song *)song
{
    return [self.activeDataSource indexPathForSong:song];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.activeDataSource numberOfSectionsInTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.activeDataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.activeDataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.activeDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.activeDataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}


@end
