//
//  SmartSearchDataSource.m
//  songbook
//
//  Created by Paul Himes on 8/27/13.
//

#import "SmartSearcher.h"
#import "SimpleSearcher.h"
#import "FilteredSearcher.h"

@implementation SmartSearcher

+ (SearchTableModel *)buildModelForSearchString:(NSString *)searchString
                                         inBook:(Book *)book
                                 shouldContinue:(BOOL (^)(void))shouldContinue
{
    if ([searchString length] > 0) {
        return [FilteredSearcher buildModelForSearchString:searchString inBook:book shouldContinue:shouldContinue];
    } else {
        return [SimpleSearcher buildModelForSearchString:searchString inBook:book shouldContinue:shouldContinue];
    }
}

@end
