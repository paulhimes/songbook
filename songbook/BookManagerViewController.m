//
//  BookManagerViewController.m
//  songbook
//
//  Created by Paul Himes on 10/31/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookManagerViewController.h"
#import "PageViewController.h"
#import "DataModelTests.h"
#import "BookCodec.h"
#import "CoreDataStack.h"
#import "SplitViewController.h"
#import "Section.h"
#import "Song+Helpers.h"
#import "Book+Helpers.h"
#import "TokenizeOperation.h"

NSString * const kTemporaryDatabaseDirectoryName = @"temporaryBook";
NSString * const kMainDatabaseDirectoryName = @"mainBook";
NSString * const kBookDatabaseFileName = @"book.sqlite";

@interface BookManagerViewController ()

@property (nonatomic, strong) CoreDataStack *mainBookStack;
@property (nonatomic, strong) NSOperationQueue *tokenizerOperationQueue;
//@property (nonatomic, strong) id observerToken;

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
    }
    return _mainBookStack;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [Theme redColor];
    
//    self.observerToken = [[NSNotificationCenter defaultCenter] addObserverForName:kTokenizeProgressNotification
//                                                                           object:nil
//                                                                            queue:[NSOperationQueue mainQueue]
//                                                                       usingBlock:^(NSNotification *note) {
//                                                                           NSError *getBookError;
//                                                                           Book *book = (Book *)[self.mainBookStack.managedObjectContext existingObjectWithID:note.userInfo[kBookIDKey] error:&getBookError];
//                                                                           int complete = [note.userInfo[kCompletedSongCountKey] integerValue];
//                                                                           int total = [note.userInfo[kTotalSongCountKey] integerValue];
//                                                                           float percentComplete = (float)complete / (float)total;
//                                                                           NSLog(@"Tokenizing %@: %d", book.title, (int)floor(percentComplete * 100));
//                                                                       }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.importFileURL && [self.importFileURL isFileURL]) {
        [self loadBookFromFileURL:self.importFileURL];
    } else {
        [self loadDefaultBookIfNeeded];
    }
    self.importFileURL = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"OpenBook"]) {
        Book *book = [Book bookFromContext:self.mainBookStack.managedObjectContext];
        
        // Begin tokenizing any untokenized songs in this book.
        [self tokenizeBook:book];
        
        if ([segue.destinationViewController isKindOfClass:[PageViewController class]]) {
            // iPhone
            PageViewController *pageViewController = (PageViewController *)segue.destinationViewController;
            pageViewController.book = book;
        } else if ([segue.destinationViewController isKindOfClass:[SplitViewController class]]) {
            // iPad
            SplitViewController *splitViewController = (SplitViewController *)segue.destinationViewController;
            splitViewController.userData = book;
        }

    }
}

//- (void)dealloc
//{
//    if (self.observerToken) {
//        [[NSNotificationCenter defaultCenter] removeObserver:self.observerToken];
//    }
//}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Book management

- (void)openBook
{
    // Check if the main book is ready to open.
    Book *book = [Book bookFromContext:self.mainBookStack.managedObjectContext];
    if (book) {
        [self performSegueWithIdentifier:@"OpenBook" sender:nil];
    }
}

- (void)loadDefaultBookIfNeeded
{
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
        [self loadBookFromFileURL:[[NSBundle mainBundle] URLForResource:@"Songs & Hymns of Believers" withExtension:@"songbook"]];
    } else {
        [self openBook];
    }
}

- (void)loadBookFromFileURL:(NSURL *)fileURL
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
    
    // Delete the import file. It is no longer needed.
    NSError *deleteError;
    if (![fileManager removeItemAtURL:fileURL error:&deleteError]) {
        NSLog(@"Failed to delete the import file: %@", deleteError);
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

    // Open the book.
    [self openBook];
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
