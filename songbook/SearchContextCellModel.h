//
//  SearchContextCellModel.h
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchCellModel.h"

@interface SearchContextCellModel : NSObject <SearchCellModel>

@property (nonatomic, readonly) NSManagedObjectID *songID;
@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) NSRange range;

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                       content:(NSAttributedString *)content
                         range:(NSRange)range;

@end
