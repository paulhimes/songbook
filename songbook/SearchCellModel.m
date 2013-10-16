//
//  SearchCellModel.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchCellModel.h"

@implementation SearchCellModel

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                       content:(NSAttributedString *)content
                         range:(NSRange)range
                   asTitleCell:(BOOL)titleCell
{
    self = [super init];
    if (self) {
        _songID = songID;
        _content = content;
        _range = range;
        _titleCell = titleCell;
    }
    return self;
}

@end
