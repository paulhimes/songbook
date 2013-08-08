//
//  DataModelTests.h
//  songbook
//
//  Created by Paul Himes on 7/28/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Book.h"

@interface DataModelTests : NSObject

+ (void)populateSampleDataInContext:(NSManagedObjectContext *)context;
+ (void)printBook:(Book *)book;

@end
