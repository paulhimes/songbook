//
//  SearchOperation.m
//  songbook
//
//  Created by Paul Himes on 9/23/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SearchOperation.h"
#import "SmartSearcher.h"

@interface SearchOperation()

@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectID *bookID;

@property (nonatomic, strong) SearchTableModel *tableModel;

@end

@implementation SearchOperation

- (instancetype)initWithSearchString:(NSString *)searchString
                                book:(Book *)book
{
    self = [super init];
    if (self) {
        if (book) {
            self.bookID = book.objectID;
            self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
            self.context.persistentStoreCoordinator = book.managedObjectContext.persistentStoreCoordinator;
            self.searchString = searchString;
        }
    }
    return self;
}

- (void)main
{
    @autoreleasepool {
        [self.context performBlockAndWait:^{
            NSLog(@"Searching for %@", self.searchString);
            NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
            
            Book *book = (Book *)[self.context objectWithID:self.bookID];
            __weak SearchOperation *weakSelf = self;
            self.tableModel = [SmartSearcher buildModelForSearchString:self.searchString
                                                                inBook:book
                                                        shouldContinue:^BOOL{
                                                            return weakSelf && !weakSelf.isCancelled;
                                                        }];
            
//            NSLog(@"%d sections", [self.tableModel.sectionModels count]);
//            for (SearchSectionModel *section in self.tableModel.sectionModels) {
//                NSLog(@"%d cells in section %@", [section.cellModels count], section.title);
//            }
            
            NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
            
            if (self.isCancelled) {
                NSLog(@"Finished Cancelled Search for %@ in %f seconds", self.searchString, endTime - startTime);
            } else {
                NSLog(@"Finished Search for %@ in %f seconds", self.searchString, endTime - startTime);
            }
        }];
    }
}

@end
