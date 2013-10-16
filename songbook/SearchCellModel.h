//
//  SearchCellModel.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchCellModel : NSObject

@property (nonatomic, readonly) NSManagedObjectID *songID;
@property (nonatomic, readonly) NSAttributedString *content;
@property (nonatomic, readonly) NSRange range;
@property (nonatomic, readonly) BOOL titleCell;

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                       content:(NSAttributedString *)content
                         range:(NSRange)range
                   asTitleCell:(BOOL)titleCell;

@end
