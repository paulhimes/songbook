//
//  SearchTableDataSource.h
//  songbook
//
//  Created by Paul Himes on 9/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTableModel.h"

@interface SearchTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UIDataSourceModelAssociation>

- (instancetype)initWithTableModel:(SearchTableModel *)tableModel;

- (NSManagedObjectID *)songIDAtIndexPath:(NSIndexPath *)indexPath;
- (NSRange)songRangeAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSongID:(NSManagedObjectID *)songID andRange:(NSRange)range;



@end
