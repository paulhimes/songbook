//
//  PageViewController.m
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageViewController.h"
#import "SongbookModel.h"
#import "Book+Helpers.h"
#import "SearchViewController.h"
#import "SplitViewController.h"

static NSString * const kPageViewControllerDelegateKey = @"PageViewControllerDelegateKey";
static NSString * const kCurrentPageModelObjectIDKey = @"CurrentPageModelObjectIDKey";

@interface PageViewController () <PageControllerDelegate>

@property (nonatomic, strong) NSURL *currentPageModelObjectID;

@end

@implementation PageViewController

- (PageServer *)pageServer
{
    if (!_pageServer) {
        _pageServer = [[PageServer alloc] init];
    }
    return _pageServer;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.restorationClass = [self class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    self.dataSource = self.pageServer;
    
    
//    if (!self.book) {
//        self.book = self.splitController.userData;
//    }
    
    if (self.bookDelegate) {
        Book *book = [self.bookDelegate book];
        
        // Get the model object for the page to start on.
        NSManagedObject *currentObjectModel;
        if (self.currentPageModelObjectID) {
            NSManagedObjectID *managedObjectID = [book.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:self.currentPageModelObjectID];
            if (managedObjectID) {
                NSError *currentModelError;
                currentObjectModel = [book.managedObjectContext existingObjectWithID:managedObjectID
                                                                               error:&currentModelError];
            }
        }
        if (!currentObjectModel) {
            currentObjectModel = book;
        }
        
        // If there was a model to display...
        if (currentObjectModel) {
            [self setViewControllers:@[[self.pageServer pageControllerForModelObject:currentObjectModel
                                                                  pageViewController:self]]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:NULL];
        }
    }
    
    [self.view setDebugColor:[UIColor purpleColor]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"] &&
               [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        searchViewController.currentSong = [self closestSong];
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    // Save the book delegate.
    if (self.bookDelegate) {
        [coder encodeObject:self.bookDelegate forKey:kPageViewControllerDelegateKey];
    }
    
    // Save the current page.
    if ([self.viewControllers count] > 0 &&
        [self.viewControllers[0] isKindOfClass:[PageController class]]) {
        PageController *pageController = self.viewControllers[0];
        NSManagedObject *modelObject = pageController.modelObject;
        NSURL *currentModelID = [modelObject.objectID URIRepresentation];
        
        if (currentModelID) {
            [coder encodeObject:currentModelID forKey:kCurrentPageModelObjectIDKey];
        }
    }
    
    [super encodeRestorableStateWithCoder:coder];
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents
                                                            coder:(NSCoder *)coder
{
    PageViewController *controller;
    UIStoryboard *storyboard = [coder decodeObjectForKey:UIStateRestorationViewControllerStoryboardKey];
    id<PageViewControllerDelegate> bookDelegate = [coder decodeObjectForKey:kPageViewControllerDelegateKey];
    NSURL *currentPageModelObjectID = [coder decodeObjectForKey:kCurrentPageModelObjectIDKey];
    if (storyboard && bookDelegate && currentPageModelObjectID) {
        controller = (PageViewController *)[storyboard instantiateViewControllerWithIdentifier:[identifierComponents lastObject]];
        controller.bookDelegate = bookDelegate;
        controller.currentPageModelObjectID = currentPageModelObjectID;
    }
    return controller;
}

- (IBAction)searchCancelled:(UIStoryboardSegue *)segue
{
}

- (IBAction)songSelected:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        
        if (searchViewController.selectedSong) {
            [self showPageForModelObject:searchViewController.selectedSong
                          highlightRange:searchViewController.selectedRange
                                animated:NO];
        }
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (Song *)closestSong
{
    PageController *currentController = self.viewControllers[0];
    NSManagedObject *modelObject = currentController.modelObject;
    
    if ([modelObject conformsToProtocol:@protocol(SongbookModel)]) {
        id<SongbookModel> songbookModel = (id<SongbookModel>)modelObject;
        return songbookModel.closestSong;
    } else {
        return nil;
    }
}

- (void)showPageForModelObject:(NSManagedObject *)modelObject
                highlightRange:(NSRange)highlightRange
                      animated:(BOOL)animated;
{
    PageController *pageController = [self.pageServer pageControllerForModelObject:modelObject
                                                                pageViewController:self];
    pageController.highlightRange = highlightRange;
    
    [self setViewControllers:@[pageController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:animated
                  completion:NULL];
}

#pragma mark - PageControllerDelegate

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject
{
    [self showPageForModelObject:modelObject highlightRange:NSMakeRange(0, 0) animated:NO];
}

- (void)search
{
    if ([self.splitController.master isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)self.splitController.master;
        searchViewController.currentSong = [self closestSong];
        
        self.splitController.masterHidden = !self.splitController.masterHidden;
    } else {
        [self performSegueWithIdentifier:@"Search" sender:nil];
    }
}

@end
