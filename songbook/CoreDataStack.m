//
//  CoreDataStack.m
//  songbook
//
//  Created by Paul Himes on 11/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "CoreDataStack.h"

@interface CoreDataStack()

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic) NSManagedObjectContextConcurrencyType concurrencyType;

@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end

@implementation CoreDataStack

- (instancetype)initWithFileURL:(NSURL *)fileURL concurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType;
{
    self = [super init];
    if (self) {
        self.fileURL = fileURL;
        self.concurrencyType = concurrencyType;
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:self.concurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
        _managedObjectContext.undoManager = nil;
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil)
    {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"songbook" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSDictionary *lightweightMigrationOptionsDictionary = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                            NSInferMappingModelAutomaticallyOption: @YES};
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.fileURL options:lightweightMigrationOptionsDictionary error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

@end
