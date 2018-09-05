//
//  SearchTitleCellModel.m
//  songbook
//
//  Created by Paul Himes on 2/9/14.
//

#import "SearchTitleCellModel.h"

@implementation SearchTitleCellModel

- (instancetype)initWithSongID:(NSManagedObjectID *)songID
                        number:(NSUInteger)number
                         title:(NSString *)title;
{
    self = [super init];
    if (self) {
        _songID = songID;
        _number = number;
        _title = title;
    }
    return self;
}

- (NSRange)range
{
    return NSMakeRange(0, 0);
}

@end
