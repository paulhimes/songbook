//
//  SearchDataSource.h
//  songbook
//
//  Created by Paul Himes on 8/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"
#import "Book.h"

@protocol SearchDataSource <NSObject, UITableViewDataSource, UITableViewDelegate>

- (instancetype)initWithBook:(Book *)book;
- (Song *)songAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForSong:(Song *)song;
- (void)setSearchString:(NSString *)searchString;

@end
