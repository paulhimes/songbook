//
//  SectionPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SectionPageController.h"
#import "SectionPageView.h"

@interface SectionPageController ()

@property (strong, nonatomic) Section *section;

@end

@implementation SectionPageController

- (instancetype)initWithSection:(Section *)section
{
    self = [super init];
    if (self) {
        self.section = section;
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.section;
}

- (PageView *)buildPageView
{
    return [[SectionPageView alloc] initWithSection:self.section];
}

@end
