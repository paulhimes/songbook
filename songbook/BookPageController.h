//
//  BookPageController.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageController.h"
#import "Book.h"

@interface BookPageController : TitlePageController

- (instancetype)initWithBook:(Book *)book;
- (Book *)book;

@end
