//
//  SearchSectionModel.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//

#import "SearchSectionModel.h"

@implementation SearchSectionModel

- (instancetype)initWithTitle:(NSString *)title
                   cellModels:(NSArray *)cellModels
{
    self = [super init];
    if (self) {
        _title = title.length ? title : @"";
        _cellModels = [cellModels copy];
    }
    return self;
}

@end
