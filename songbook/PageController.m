//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "BookCodec.h"
#import "BookActivityItemSource.h"
#import "ExportProgressViewController.h"
#import "TTOpenInAppActivity.h"

NSString * const kStandardTextSizeKey = @"StandardTextSize";

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kModelIDURLKey = @"ModelIDURLKey";
static NSString * const kDelegateKey = @"DelegateKey";
static NSString * const kHighlightRangeKey = @"HighlightRangeKey";
static NSString * const kBookmarkedCharacterIndexKey = @"BookmarkedCharacterIndexKey";
static NSString * const kBookmarkedCharacterYOffsetKey = @"BookmarkedCharacterYOffsetKey";

const float kSuperMaximumStandardTextSize = 60;
const float kMaximumStandardTextSize = 40;
const float kMinimumStandardTextSize = 8;

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate, UIViewControllerRestoration, ExportProgressViewControllerDelegate>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) ExportProgressViewController *exportProgressViewController;
@property (nonatomic) BOOL exportCancelled;
@property (nonatomic, strong) NSNumber *previousExportIncludedExtraFiles;

@end

@implementation PageController

- (NSAttributedString *)text
{
    return [[NSAttributedString alloc] initWithString:@""];
}

- (UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    if (!_pinchGestureRecognizer) {
        _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(handleGesture:)];
    }
    return _pinchGestureRecognizer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.restorationClass = [self class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.attributedText = self.text;
    self.textView.layoutManager.allowsNonContiguousLayout = NO;
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    [self.view addGestureRecognizer:self.pinchGestureRecognizer];
    
    self.textView.clipsToBounds = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(userDefaultsChanged:)
                                                 name:NSUserDefaultsDidChangeNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];

    [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    
    [coder encodeObject:[self.modelID URIRepresentation] forKey:kModelIDURLKey];
    
    if (self.delegate) {
        [coder encodeObject:self.delegate forKey:kDelegateKey];
    }
    
    [coder encodeObject:[NSValue valueWithRange:self.highlightRange] forKey:kHighlightRangeKey];
    
    [coder encodeObject:@(self.bookmarkedCharacterIndex) forKey:kBookmarkedCharacterIndexKey];
    [coder encodeDouble:self.bookmarkedCharacterYOffset forKey:kBookmarkedCharacterYOffsetKey];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    PageController *controller;
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    CoreDataStack *coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    NSURL *modelIDURL = [coder decodeObjectForKey:kModelIDURLKey];
    NSManagedObjectID *modelID = [coreDataStack.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:modelIDURL];
    id<PageControllerDelegate> delegate = [coder decodeObjectForKey:kDelegateKey];
    NSRange highlightRange = [[coder decodeObjectForKey:kHighlightRangeKey] rangeValue];
    NSUInteger bookmarkedCharacterIndex = [[coder decodeObjectForKey:kBookmarkedCharacterIndexKey] unsignedIntegerValue];
    CGFloat bookmarkedCharacterYOffset = [coder decodeDoubleForKey:kBookmarkedCharacterYOffsetKey];
    
    if (storyboard && coreDataStack && modelID && delegate) {
        controller = (PageController *)[storyboard instantiateViewControllerWithIdentifier:[identifierComponents lastObject]];
        controller.coreDataStack = coreDataStack;
        controller.modelID = modelID;
        controller.delegate = delegate;
        controller.highlightRange = highlightRange;
        controller.bookmarkedCharacterIndex = bookmarkedCharacterIndex;
        controller.bookmarkedCharacterYOffset = bookmarkedCharacterYOffset;
    }
    
    return controller;
}

- (void)userDefaultsChanged:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:NSUserDefaultsDidChangeNotification]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self textContentChanged];
        });
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

#pragma mark - Book Sharing

- (void)shareBookWithExtraFiles:(BOOL)includeExtraFiles
{
    __block NSURL *exportedFileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[exportedFileURL path]] &&
        self.previousExportIncludedExtraFiles &&
        [self.previousExportIncludedExtraFiles boolValue] == includeExtraFiles) {
        // Just share the existing file.
        [self shareExportedBookFile:exportedFileURL];
    } else {
        // Determine the source directory for the book files.
        NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
        
        if (includeExtraFiles) {
            // Create the alert window and view controller.
            self.alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.alertWindow.opaque = NO;
            self.alertWindow.tintColor = [Theme redColor];
            self.exportProgressViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportProgressViewController"];
            self.exportProgressViewController.delegate = self;
            //Put window on top of all other windows/views
            [self.alertWindow setWindowLevel:UIWindowLevelNormal];
            [self.alertWindow setRootViewController:self.exportProgressViewController];
            [self.alertWindow makeKeyAndVisible];
            [self.exportProgressViewController showWithCompletion:nil];
            self.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            self.exportCancelled = NO;
            
            // Export the book directory to a file, and share it when ready.
            __weak PageController *welf = self;
            __weak ExportProgressViewController *weakProgressViewController = self.exportProgressViewController;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                exportedFileURL = [BookCodec exportBookFromDirectory:bookDirectory
                                                   includeExtraFiles:includeExtraFiles
                                                            progress:^(CGFloat progress, BOOL *stop) {
                                                                dispatch_sync(dispatch_get_main_queue(), ^{
                                                                    [weakProgressViewController setProgress:progress];
                                                                    
                                                                    *stop = welf.exportCancelled;
                                                                });
                                                            }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Dismiss alert by making main window key and visible
                    [welf.exportProgressViewController hideWithCompletion:^{
                        welf.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
                        [welf.view.window makeKeyAndVisible];
                        welf.alertWindow = nil;
                        welf.exportProgressViewController = nil;
                        
                        // Share the completed book file.
                        welf.previousExportIncludedExtraFiles = @(includeExtraFiles);
                        [welf shareExportedBookFile:exportedFileURL];
                    }];
                });
            });
        } else {
            exportedFileURL = [BookCodec exportBookFromDirectory:bookDirectory
                                               includeExtraFiles:NO
                                                        progress:nil];
            self.previousExportIncludedExtraFiles = @(includeExtraFiles);
            [self shareExportedBookFile:exportedFileURL];
        }
    }
}

- (void)shareExportedBookFile:(NSURL *)exportedFileURL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportedFileURL.path]) {
        
        NSArray *activityItems = @[[[BookActivityItemSource alloc] initWithBookFileURL:exportedFileURL]];
        TTOpenInAppActivity *openInAppActivity = [[TTOpenInAppActivity alloc] initWithView:self.view andBarButtonItem:self.activityButton];
        UIActivityViewController *activityViewController = [[NoStatusActivityViewController alloc] initWithActivityItems:activityItems
                                                                                                   applicationActivities:@[openInAppActivity]];
        
        NSArray *excludedActivityTypes = @[UIActivityTypeMessage];
        // Check if the file size is greater than 10 MB.
        NSNumber *fileSizeInBytes;
        [exportedFileURL getResourceValue:&fileSizeInBytes forKey:NSURLFileSizeKey error:nil];
        if ([fileSizeInBytes integerValue] / 1024 / 1024 > 10) {
            // Remove the email activity. The email would likely be rejected anyway.
            excludedActivityTypes = [excludedActivityTypes arrayByAddingObject:UIActivityTypeMail];
        }
        
        activityViewController.excludedActivityTypes = excludedActivityTypes;
        activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
            if (completed) {
                // Delete the temporary file.
                NSURL *fileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
                if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
                    NSError *deleteError;
                    if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError]) {
                        NSLog(@"Failed to delete temporary export file: %@", deleteError);
                    }
                }
            }
        };
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            // Store reference to superview (UIActionSheet) to allow dismissal
            openInAppActivity.superViewController = activityViewController;
            //iPhone, present activity view controller as is
            [self presentViewController:activityViewController animated:YES completion:nil];
        } else {
            //iPad, present the view controller inside a popover
            if (![self.activityPopover isPopoverVisible]) {
                self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                
                // Store reference to superview (UIPopoverController) to allow dismissal
                openInAppActivity.superViewController = self.activityPopover;
                
                [self.activityPopover presentPopoverFromBarButtonItem:self.activityButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            } else {
                //Dismiss if the button is tapped while pop over is visible
                [self.activityPopover dismissPopoverAnimated:YES];
            }
        }
    }
}

- (BOOL)bookDirectoryHasSongFiles
{
    NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:bookDirectory
                                                   includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                      options:0
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"Error enumerating url: %@", url);
                                                                     return YES;
                                                                 }];
    
    BOOL foundSongFile = NO;
    
    for (NSURL *url in directoryEnumerator) {
        // Skip directories.
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue]) {
            continue;
        }
        
        NSString *fileExtension = [url pathExtension];
        if ([fileExtension localizedCaseInsensitiveCompare:@"m4a"] == NSOrderedSame ||
            [fileExtension localizedCaseInsensitiveCompare:@"mp3"] == NSOrderedSame ||
            [fileExtension localizedCaseInsensitiveCompare:@"wav"] == NSOrderedSame) {
            
            foundSongFile = YES;
            break;
        }
    }
    
    return foundSongFile;
}

#pragma mark - Action Methods

- (IBAction)searchAction:(id)sender
{
    [self.delegate search];
}

- (IBAction)activityAction:(id)sender
{
    if ([self bookDirectoryHasSongFiles]) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                   destructiveButtonTitle:nil
                                                        otherButtonTitles:nil];
        
        [actionSheet addButtonWithTitle:@"Share Book"];
        [actionSheet addButtonWithTitle:@"Share Book & Tunes"];
        [actionSheet addButtonWithTitle:@"Cancel"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            //iPhone, present action sheet from view.
            [actionSheet showInView:self.textView];
        } else {
            //iPad, present the action sheet from bar button.
            [actionSheet showFromBarButtonItem:self.activityButton animated:YES];
        }
    } else {
        [self shareBookWithExtraFiles:NO];
    }
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self shareBookWithExtraFiles:NO];
    } else if (buttonIndex == 1) {
        [self shareBookWithExtraFiles:YES];
    }
}

#pragma mark - ExportProgressViewControllerDelegate

- (void)exportProgressViewControllerDidCancel:(ExportProgressViewController *)exportProgressViewController
{
    self.exportCancelled = YES;
}

@end
