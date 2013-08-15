//
//  BookPageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookPageController.h"

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

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:self.book.title
                                           attributes:@{NSFontAttributeName: [UIFont fontWithName:@"Marion" size:40]}];
}

@end
