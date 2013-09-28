//
//  SearchTableModel.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchTableModel.h"

@implementation SearchTableModel

- (instancetype)initWithSectionModels:(NSArray *)sectionModels
{
    self = [super init];
    if (self) {
        _sectionModels = [sectionModels copy];
    }
    return self;
}

@end
