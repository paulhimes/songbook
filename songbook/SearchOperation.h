//
//  SearchOperation.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//

#import <Foundation/Foundation.h>
#import "SearchTableModel.h"
#import "Book.h"

@interface SearchOperation : NSOperation

@property (nonatomic, readonly) SearchTableModel *tableModel;

- (instancetype)initWithSearchString:(NSString *)searchString
                                book:(Book *)book;

@end
