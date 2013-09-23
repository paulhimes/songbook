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

@property (nonatomic, strong) id<SearchDataSource> dataSource;

@end

@implementation SmartSearchDataSource

#pragma mark - SearchDataSource

- (instancetype)initWithBook:(Book *)book searchString:(NSString *)searchString
{
    self = [super init];
    if (self) {
        if ([searchString length] > 0) {
            self.dataSource = [[FilteredSearchDataSource alloc] initWithBook:book searchString:searchString];
        } else {
            self.dataSource = [[SimpleSearchDataSource alloc] initWithBook:book searchString:searchString];
        }
    }
    return self;
}

- (Song *)songAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource songAtIndexPath:indexPath];
}
- (NSIndexPath *)indexPathForSong:(Song *)song
{
    return [self.dataSource indexPathForSong:song];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource numberOfSectionsInTableView:tableView];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.dataSource tableView:tableView titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.dataSource tableView:tableView heightForRowAtIndexPath:indexPath];
}


@end
