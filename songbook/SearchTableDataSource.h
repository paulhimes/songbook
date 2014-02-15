//
//  SearchTableDataSource.h
//  songbook
//
//  Created by Paul Himes on 9/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTableModel.h"

@protocol SearchTableDataSourceDelegate;

@interface SearchTableDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, UIDataSourceModelAssociation>

@property (nonatomic, weak) id<SearchTableDataSourceDelegate> delegate;

- (instancetype)initWithTableModel:(SearchTableModel *)tableModel;

- (NSManagedObjectID *)songIDAtIndexPath:(NSIndexPath *)indexPath;
- (NSRange)songRangeAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSongID:(NSManagedObjectID *)songID andRange:(NSRange)range;

@end

@protocol SearchTableDataSourceDelegate <NSObject>

- (void)selectedSong:(NSManagedObjectID *)selectedSongID withRange:(NSRange)range;
- (void)usedSectionIndexBar;

@end
