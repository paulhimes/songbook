//
//  SearchTableDataSource.h
//  songbook
//
//  Created by Paul Himes on 9/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTableModel.h"

@interface SearchTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithTableModel:(SearchTableModel *)tableModel;
- (NSManagedObjectID *)songIDAtIndexPath:(NSIndexPath *)indexPath;
- (NSUInteger)songLocationAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSongID:(NSManagedObjectID *)songID;


@end
