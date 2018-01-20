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

@property(nonatomic, readonly) NSManagedObjectID *objectID;

- (id<SongbookModel>)nextObject;
- (id<SongbookModel>)previousObject;
- (Song *)closestSong;

@end
