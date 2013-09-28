//
//  SearchOperation.h
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchTableModel.h"

@interface SearchOperation : NSOperation

@property (nonatomic, readonly) SearchTableModel *tableModel;

- initWithSearchString:(NSString *)searchString
                bookID:(NSManagedObjectID *)bookID
      storeCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator;

@end
