//
//  SearchTableModel.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchTableModel.h"

@interface SearchTableModel()

@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

@end

@implementation SearchTableModel

- (instancetype)initWithSectionModels:(NSArray *)sectionModels
           persistentStoreCoordinator:(NSPersistentStoreCoordinator *)coordinator
{
    self = [super init];
    if (self) {
        _sectionModels = [sectionModels copy];
        _coordinator = coordinator;
    }
    return self;
}

@end
