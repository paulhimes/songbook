//
//  SearchSectionModel.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchSectionModel.h"

@implementation SearchSectionModel

- (instancetype)initWithTitle:(NSString *)title
                   cellModels:(NSArray *)cellModels
{
    self = [super init];
    if (self) {
        _title = title;
        _cellModels = [cellModels copy];
    }
    return self;
}

@end
