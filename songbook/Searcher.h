//
//  Searcher.h
//  songbook
//
//  Created by Paul Himes on 8/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"
#import "SearchTableModel.h"
#import "SearchSectionModel.h"
#import "SearchTitleCellModel.h"
#import "SearchContextCellModel.h"

@protocol Searcher <NSObject>

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString
                                         inBook:(Book *)book
                                 shouldContinue:(BOOL (^)(void))shouldContinue;

@end
