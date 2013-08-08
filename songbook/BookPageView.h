//
//  BookPageView.h
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "TitlePageView.h"
#import "Book.h"

@interface BookPageView : TitlePageView

- (instancetype)initWithBook:(Book *)book;

@end
