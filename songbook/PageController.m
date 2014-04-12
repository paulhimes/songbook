//
//  PageController.m
//  songbook
//
//  Created by Paul Himes on 8/2/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageController.h"
#import "BookCodec.h"
#import "BookProvider.h"
#import "PlaySongActivity.h"

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

@interface PageController () <UIScrollViewDelegate, UIToolbarDelegate, UIViewControllerRestoration>

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGestureRecognizer;

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

- (NSArray *)activityItems
{
    return @[[[BookProvider alloc] initWithCoreDataStack:self.coreDataStack]];
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
        [self textContentChanged];
    }
}

- (void)textContentChanged
{
    self.textView.attributedText = self.text;
}

- (void)handleGesture:(UIPinchGestureRecognizer *)sender
{
    
}

#pragma mark - Action Methods

- (IBAction)searchAction:(id)sender
{
    [self.delegate search];
}

- (IBAction)activityAction:(id)sender
{
    NSArray *activityItems = [self activityItems];
    UIActivityViewController *activityViewController = [[NoStatusActivityViewController alloc] initWithActivityItems:activityItems
                                                                                               applicationActivities:@[[[PlaySongActivity alloc] init]]];
    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage];
    activityViewController.completionHandler = ^(NSString *activityType, BOOL completed) {
        // Delete the temporary file.
        NSURL *fileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
        if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
            NSError *deleteError;
            if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError]) {
                NSLog(@"Failed to delete temporary export file: %@", deleteError);
            }
        }
    };
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //iPhone, present activity view controller as is
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
    else
    {
        //iPad, present the view controller inside a popover
        if (![self.activityPopover isPopoverVisible]) {
            self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
            [self.activityPopover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            //Dismiss if the button is tapped while pop over is visible
            [self.activityPopover dismissPopoverAnimated:YES];
        }
    }
}

@end
