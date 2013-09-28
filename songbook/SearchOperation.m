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
@property (nonatomic, strong) NSPersistentStoreCoordinator *storeCoordinator;

@property (nonatomic, strong) SearchTableModel *tableModel;

@end

@implementation SearchOperation

- (NSManagedObjectContext *)context
{
    if (!_context) {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _context.persistentStoreCoordinator = self.storeCoordinator;
    }
    return _context;
}

- initWithSearchString:(NSString *)searchString
                bookID:(NSManagedObjectID *)bookID
      storeCoordinator:(NSPersistentStoreCoordinator *)storeCoordinator
{
    self = [super init];
    if (self) {
        self.searchString = searchString;
        self.bookID = bookID;
        self.storeCoordinator = storeCoordinator;
    }
    return self;
}

- (void)main
{
    NSLog(@"Searching for %@", self.searchString);
    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
    
    Book *book = (Book *)[self.context objectWithID:self.bookID];
    self.tableModel = [SmartSearcher buildModelForSearchString:self.searchString inBook:book];
    
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    NSLog(@"Finished Searching for %@ in %f seconds", self.searchString, endTime - startTime);
    
}

@end
