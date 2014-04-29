//
//  BookManagerViewController.m
//  songbook
//
//  Created by Paul Himes on 10/31/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "BookManagerViewController.h"
#import "BookCodec.h"
#import "TokenizeOperation.h"
#import "CoreDataStack.h"
#import "SplitViewController.h"
#import "GradientView.h"
#import "Book+Helpers.h"

static NSString * const kTemporaryDatabaseDirectoryName = @"temporaryBook";
static NSString * const kMainDatabaseDirectoryName = @"mainBook";
static NSString * const kMainBookStackKey = @"mainBookStack";

@interface BookManagerViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) CoreDataStack *mainBookStack;
@property (nonatomic, strong) NSOperationQueue *tokenizerOperationQueue;

@property (weak, nonatomic) IBOutlet UILabel *busyMessageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busySpinner;

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
        _mainBookStack = [BookCodec coreDataStackFromBookDirectory:[self mainBookDirectory]
                                                   concurrencyType:NSMainQueueConcurrencyType];
        if (_mainBookStack) {
            [UIApplication registerObjectForStateRestoration:_mainBookStack
                                       restorationIdentifier:kMainBookStackKey];
        }
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
    
    self.busyMessageLabel.textColor = [Theme paperColor];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (self.importFileURL &&
        [self.importFileURL isFileURL] &&
        [fileManager fileExistsAtPath:self.importFileURL.path]) {
        [self loadBookFromFileURL:self.importFileURL andWarnAboutReplacement:YES];
    } else {
        [self openBook];
    }
    self.importFileURL = nil;
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
        Book *book = [Book bookFromContext:self.mainBookStack.managedObjectContext];
        if (book) {
            // Begin tokenizing any untokenized songs in this book.
            [self tokenizeBook:book];
        }
    }
}

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
        // Begin tokenizing any untokenized songs in this book.
        [self tokenizeBook:book];
        
        [self performSegueWithIdentifier:@"OpenBook" sender:nil];
    } else {
        // Load the built-in book.
        [self loadBuiltInBook];
    }
}

- (void)loadBuiltInBook
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
    
    // Copy the built-in book file to a temporary directory.
    NSURL *builtInBookURL = [[NSBundle mainBundle] URLForResource:@"default" withExtension:@"songbook"];
    NSURL *temporaryURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[builtInBookURL lastPathComponent]];
    NSError *copyError;
    if (![fileManager copyItemAtURL:builtInBookURL toURL:temporaryURL error:&copyError]) {
        NSLog(@"Failed to copy the built-in songbook file to the documents directory.");
        abort();
    }
    
    // Load the built-in book.
    [self loadBookFromFileURL:temporaryURL andWarnAboutReplacement:NO];
}

- (void)loadBookFromFileURL:(NSURL *)fileURL andWarnAboutReplacement:(BOOL)warnAboutReplacement
{
    // Import the book into a directory.
    [BookCodec importBookFromURL:fileURL intoDirectory:[self temporaryBookDirectory]];
    
    // Hide busy message.
    self.busyMessageLabel.hidden = YES;
    self.busySpinner.hidden = YES;
    
    // Delete the import file. It is no longer needed.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *deleteError;
    if (![fileManager removeItemAtURL:fileURL error:&deleteError]) {
        NSLog(@"Failed to delete the import file: %@", deleteError);
    }
    
    // Get a core data stack connected to the database in the book directory.
    CoreDataStack *temporaryBookStack = [BookCodec coreDataStackFromBookDirectory:[self temporaryBookDirectory]
                                                                  concurrencyType:NSPrivateQueueConcurrencyType];
    
    Book *replacementBook = [Book bookFromContext:temporaryBookStack.managedObjectContext];
    if (replacementBook) {
        // A book was found in the file.
        if (warnAboutReplacement) {
            // Build a custom message based on whether or not the new book has a title.
            NSString *message = @"This app can only hold one songbook at a time. Would you like to replace your current book?";
            if ([replacementBook.title length] > 0) {
                NSString *versionString = @"";
                if (replacementBook.version) {
                    versionString = [NSString stringWithFormat:@" (v%@)", replacementBook.version];
                }
                message = [NSString stringWithFormat:@"This app can only hold one songbook at a time. Would you like to replace your current book with %@%@?", replacementBook.title, versionString];
            }
            
            // Ask people here if they would like to replace their current book with this new book.
            UIAlertView *replaceAlertView = [[UIAlertView alloc] initWithTitle:@"Replace Book?"
                                                                       message:message
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles:@"Replace", nil];
            [replaceAlertView show];
        } else {
            [self finalizeTemporaryBookAndOpen];
        }
        
    } else {
        [self alertFailure];
    }
}

- (void)alertFailure
{
    // Could not open the file.
    UIAlertView *replaceAlertView = [[UIAlertView alloc] initWithTitle:@"Failed to Open Book"
                                                               message:@"The app could not open this file."
                                                              delegate:self
                                                     cancelButtonTitle:@"Ok"
                                                     otherButtonTitles:nil];
    [replaceAlertView show];
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
        }
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            // Cancel
            [self deleteTemporaryDirectory];
            [self openBook];
            break;
        case 1:
            // Replace
            [self finalizeTemporaryBookAndOpen];
            break;
        default:
            break;
    }
}

- (void)finalizeTemporaryBookAndOpen
{
    // Replace the main book database directory with the temporary database directory.
    self.mainBookStack = nil; // Drop the main stack so it will be recreated using the new files.
    
    NSError *replaceError;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager replaceItemAtURL:[self mainBookDirectory]
                         withItemAtURL:[self temporaryBookDirectory]
                        backupItemName:nil
                               options:0
                      resultingItemURL:nil
                                 error:&replaceError]) {
        NSLog(@"Failed to replace book directory: %@", replaceError);
        [self alertFailure];
    } else {
        [self deleteTemporaryDirectory];
        [self openBook];
    }
}

@end
