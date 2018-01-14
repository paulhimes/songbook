//
//  CoreDataStack.m
//  songbook
//
//  Created by Paul Himes on 11/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "CoreDataStack.h"

static NSString * const kFileURLKey = @"FileURLKey";
static NSString * const kConcurrencyTypeKey = @"ConcurrencyTypeKey";

@interface CoreDataStack() <UIObjectRestoration>

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
    if (self && fileURL &&
        ((concurrencyType == NSPrivateQueueConcurrencyType) ||
		(concurrencyType == NSMainQueueConcurrencyType))) {
            
        self.fileURL = fileURL;
        self.concurrencyType = concurrencyType;
            
    } else {
        self = nil;
    }
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    if (!_managedObjectContext)
    {
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:self.concurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            _managedObjectContext.undoManager = nil;
        }
    }
    
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (!_managedObjectModel)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"songbook" withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (!_persistentStoreCoordinator)
    {
        NSDictionary *lightweightMigrationOptionsDictionary = @{NSMigratePersistentStoresAutomaticallyOption: @YES,
                                                                NSInferMappingModelAutomaticallyOption: @YES};
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *createDirectoryError;
        if ([fileManager createDirectoryAtURL:[self.fileURL URLByDeletingLastPathComponent]
                  withIntermediateDirectories:YES
                                   attributes:nil
                                        error:&createDirectoryError]) {
            NSError *error = nil;
            _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
            if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:self.fileURL options:lightweightMigrationOptionsDictionary error:&error])
            {
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        } else {
            NSLog(@"Failed to create the directories for %@: %@", self.fileURL, createDirectoryError);
        }
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)databaseDirectory
{
    NSArray *stores = self.managedObjectContext.persistentStoreCoordinator.persistentStores;
    NSURL *storeURL = [self.managedObjectContext.persistentStoreCoordinator URLForPersistentStore:[stores firstObject]];
    NSURL *storeDirectory = [storeURL URLByDeletingLastPathComponent];
    return storeDirectory;
}

#pragma mark - UIStateRestoring

- (Class<UIObjectRestoration>)objectRestorationClass
{
    return [self class];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    if (self.fileURL) {
        // Strip the application directory from the file URL to convert it to a relative URL.
        NSString *applicationDirectoryPath = NSHomeDirectory();
        NSString *absoluteDatabaseFilePath = [self.fileURL path];
        NSRange substringRange = [absoluteDatabaseFilePath rangeOfString:applicationDirectoryPath];
        NSString *relativeDatabaseFilePath;
        if (substringRange.location != NSNotFound &&
            NSMaxRange(substringRange) <= [absoluteDatabaseFilePath length]) {
            relativeDatabaseFilePath = [absoluteDatabaseFilePath substringFromIndex:NSMaxRange(substringRange)];
        }
        
        if ([relativeDatabaseFilePath length]) {
            [coder encodeObject:relativeDatabaseFilePath forKey:kFileURLKey];
        }
    }
    
    [coder encodeObject:@(self.concurrencyType) forKey:kConcurrencyTypeKey];
}

#pragma mark - UIObjectRestoration

+ (id<UIStateRestoring>)objectWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    // Decode the fileURL.
    NSURL *fileURL;
    NSString *relativeDatabaseFilePath = [coder decodeObjectForKey:kFileURLKey];
    if ([relativeDatabaseFilePath isKindOfClass:[NSString class]] &&
        [relativeDatabaseFilePath length]) {
        // Convert the relative file path to an absolute path and create an NSURL.
        NSString *applicationDirectoryPath = NSHomeDirectory();
        NSString *absoluteDatabaseFilePath = [applicationDirectoryPath stringByAppendingPathComponent:relativeDatabaseFilePath];
        fileURL = [NSURL fileURLWithPath:absoluteDatabaseFilePath];
    }
    
    // Decode the concurrencyType.
    NSNumber *concurrencyType = [coder decodeObjectForKey:kConcurrencyTypeKey];
    
    CoreDataStack *coreDataStack;
    if (fileURL && concurrencyType) {
        coreDataStack = [[CoreDataStack alloc] initWithFileURL:fileURL concurrencyType:[concurrencyType unsignedIntegerValue]];
        [UIApplication registerObjectForStateRestoration:coreDataStack restorationIdentifier:[identifierComponents lastObject]];
    }
    return coreDataStack;
}

@end
