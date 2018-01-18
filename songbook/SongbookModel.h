//
//  SongbookModel.h
//  songbook
//
//  Created by Paul Himes on 8/7/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Song.h"

@protocol SongbookModel <NSObject>

- (NSManagedObject<SongbookModel> *)nextObject;
- (NSManagedObject<SongbookModel> *)previousObject;
- (Song *)closestSong;

@end
