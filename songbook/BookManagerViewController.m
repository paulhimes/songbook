//
//  BookManagerViewController.m
//  songbook
//
//  Created by Paul Himes on 10/31/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookManagerViewController.h"
#import "DataModelTests.h"
#import "BookCodec.h"
#import "CoreDataStack.h"
#import "Section.h"
#import "Song+Helpers.h"
#import "Book+Helpers.h"
#import "TokenizeOperation.h"
#import "SplitViewController.h"
#import "SingleViewController.h"
#import "GradientView.h"

static NSString * const kTemporaryDatabaseDirectoryName = @"temporaryBook";
static NSString * const kMainDatabaseDirectoryName = @"mainBook";
static NSString * const kBookDatabaseFileName = @"book.sqlite";

static NSString * const kMainBookStackKey = @"mainBookStack";

@interface BookManagerViewController ()

@property (nonatomic, strong) CoreDataStack *mainBookStack;
@property (nonatomic, strong) NSOperationQueue *tokenizerOperationQueue;

@end

@implementation BookManagerViewController

- (NSOperationQueue *)tokenizerOperationQueue
{
    if (!_tokenizerOperationQueue) {
        _tokenizerOperationQueue = [[NSOperationQueue alloc] init];
        [_tokenizerOperationQueue setMaxConcurrentOperationCount:1];
    }
    return _tokenizerOperationQueue;
}

- (CoreDataStack *)mainBookStack
{
    if (!_mainBookStack) {
        NSURL *directory = [self mainBookDirectory];
        NSURL *file = [directory URLByAppendingPathComponent:kBookDatabaseFileName];
        _mainBookStack = [[CoreDataStack alloc] initWithFileURL:file concurrencyType:NSMainQueueConcurrencyType];
        [UIApplication registerObjectForStateRestoration:_mainBookStack restorationIdentifier:kMainBookStackKey];
    }
    return _mainBookStack;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    GradientView *gradientView = [[GradientView alloc] initWithFrame:CGRectMake(-self.view.bounds.size.width, 0, 2 * self.view.bounds.size.width, self.view.bounds.size.height)];
    gradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:gradientView atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.importFileURL && [self.importFileURL isFileURL]) {
        [self loadBookFromFileURL:self.importFileURL andCleanup:YES];
    } else {
        [self loadDefaultBookIfNeeded];
    }
    self.importFileURL = nil;
    
    // Check if the main book is ready to open.
    Book *book = [Book bookFromContext:self.mainBookStack.managedObjectContext];
    if (book) {
        // Begin tokenizing any untokenized songs in this book.
        [self tokenizeBook:book];
        
        [self performSegueWithIdentifier:@"OpenBook" sender:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpenBook"]) {
        if ([segue.destinationViewController respondsToSelector:@selector(setCoreDataStack:)]) {
            [segue.destinationViewController setCoreDataStack:self.mainBookStack];
        }
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    [coder encodeObject:self.mainBookStack forKey:kMainBookStackKey];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    if ([coder containsValueForKey:kMainBookStackKey]) {
        CoreDataStack *mainBookStack = [coder decodeObjectForKey:kMainBookStackKey];
        self.mainBookStack = mainBookStack;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Book management

- (void)loadDefaultBookIfNeeded
{
    // Create the main book directory if it doesn't already exist.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:[self mainBookDirectory].path]) {
        NSError *createError;
        if (![fileManager createDirectoryAtURL:[self mainBookDirectory] withIntermediateDirectories:YES attributes:nil error:&createError]) {
            NSLog(@"Failed to create main book directory: %@", createError);
            return;
        }
    }
    
    // Load the main book database.
    // Load the inital data, if there are no books in the main book file.
    Book *book = [Book bookFromContext:self.mainBookStack.managedObjectContext];
    if (!book) {
        [self loadBookFromFileURL:[[NSBundle mainBundle] URLForResource:@"Songs & Hymns of Believers" withExtension:@"songbook"] andCleanup:NO];
    }
}

- (void)loadBookFromFileURL:(NSURL *)fileURL andCleanup:(BOOL)deleteFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:fileURL.path]) {
        return;
    }
    
    NSURL *temporaryFile = [[self temporaryBookDirectory] URLByAppendingPathComponent:kBookDatabaseFileName];
    
    // Delete any existing temporary database file.
    [self deleteTemporaryDirectory];
    
    // Create the temporary directory.
    NSError *createDirectoryError;
    if (![fileManager createDirectoryAtURL:[self temporaryBookDirectory]
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&createDirectoryError]) {
        NSLog(@"Failed to create temporary directory: %@", createDirectoryError);
        return;
    }
    
    // Create the temporary database stack.
    CoreDataStack *temporaryBookStack = [[CoreDataStack alloc] initWithFileURL:temporaryFile concurrencyType:NSPrivateQueueConcurrencyType];
    
    // Load the book into the temporary database.
    NSManagedObjectContext *temporaryContext = temporaryBookStack.managedObjectContext;
    [BookCodec importBookFromURL:fileURL intoContext:temporaryContext];
    
    if (deleteFile) {
        // Delete the import file. It is no longer needed.
        NSError *deleteError;
        if (![fileManager removeItemAtURL:fileURL error:&deleteError]) {
            NSLog(@"Failed to delete the import file: %@", deleteError);
        }
    }
    
    // Replace the main book database directory with the temporary database directory.
    self.mainBookStack = nil; // Drop the main stack so it will be recreated using the new files.
    temporaryContext = nil; // Set to nil to prevent further use.
    temporaryBookStack = nil; // Set to nil to prevent further use.
    NSError *replaceError;
    if (![fileManager replaceItemAtURL:[self mainBookDirectory]
                         withItemAtURL:[self temporaryBookDirectory]
                        backupItemName:nil
                               options:0
                      resultingItemURL:NULL
                                 error:&replaceError]) {
        NSLog(@"Failed to replace book directory: %@", replaceError);
        
        // Delete the temporary directory.
        [self deleteTemporaryDirectory];
    }
}

- (void)tokenizeBook:(Book *)book
{
    // Tokenize the book.
    TokenizeOperation *operation = [[TokenizeOperation alloc] initWithBook:book];
    [self.tokenizerOperationQueue addOperation:operation];
}

#pragma mark - File / Directory helper methods

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL *)mainBookDirectory
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent:kMainDatabaseDirectoryName isDirectory:YES];
}

- (NSURL *)temporaryBookDirectory
{
    return [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:kTemporaryDatabaseDirectoryName] isDirectory:YES];
}

- (void)deleteTemporaryDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *temporaryDirectory = [self temporaryBookDirectory];
    
    if ([fileManager fileExistsAtPath:temporaryDirectory.path]) {
        NSError *error;
        if (![fileManager removeItemAtURL:temporaryDirectory error:&error]) {
            NSLog(@"Failed to delete temporary database directory: %@", error);
            return;
        } else {
            NSLog(@"Deleted temporary directory at: %@", temporaryDirectory);
        }
    }
}

@end
