//
//  SearchContextCellModel.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "SearchContextCellModel.h"

@implementation SearchContextCellModel

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                       content:(NSAttributedString *)content
                         range:(NSRange)range
{
    self = [super init];
    if (self) {
        _songID = songID;
        _content = content;
        _range = range;
    }
    return self;
}

@end
