//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"
#import "BookPageView.h"

@interface BookPageController ()

@property (strong, nonatomic) Book *book;

@end

@implementation BookPageController

- (instancetype)initWithBook:(Book *)book
{
    self = [super init];
    if (self) {
        self.book = book;
    }
    return self;
}

- (NSManagedObject *)modelObject
{
    return self.book;
}

- (PageView *)buildPageView
{
    return [[BookPageView alloc] initWithBook:self.book];
}

@end
