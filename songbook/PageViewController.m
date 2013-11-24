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

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kViewControllerKey = @"ViewControllerKey";

@interface PageViewController () <PageControllerDelegate>

@end

@implementation PageViewController

- (PageServer *)pageServer
{
    if (!_pageServer) {
        _pageServer = [[PageServer alloc] init];
    }
    return _pageServer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    self.dataSource = self.pageServer;
    [self.view setDebugColor:[UIColor purpleColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.coreDataStack && [self.viewControllers count] == 0) {
        Book *book = [Book bookFromContext:self.coreDataStack.managedObjectContext];
        
        // If there was a model to display...
        if (book) {
            [self setViewControllers:@[[self.pageServer pageControllerForModelObject:book
                                                                  pageViewController:self]]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:NULL];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"] &&
               [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        searchViewController.coreDataStack = self.coreDataStack;
        searchViewController.closestSongID = [self closestSong].objectID;
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"Encode PageViewController");
    // Save the core data stack.
    if (self.coreDataStack) {
        [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    }

    // Save the view controllers.
    if ([self.viewControllers count] > 0) {
        UIViewController *viewController = self.viewControllers[0];
        [coder encodeObject:viewController forKey:kViewControllerKey];
    }

    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    CoreDataStack *coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    UIViewController *viewController = [coder decodeObjectForKey:kViewControllerKey];
    NSLog(@"Decode PageViewController");

    if (coreDataStack && viewController) {
        self.coreDataStack = coreDataStack;
        [self setViewControllers:@[viewController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
}

- (IBAction)searchCancelled:(UIStoryboardSegue *)segue
{
}

- (IBAction)songSelected:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        
        if (searchViewController.selectedSongID) {
            NSError *getSongError;
            Song *song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:searchViewController.selectedSongID error:&getSongError];
            [self showPageForModelObject:song
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
    
    if (pageController) {
        [self setViewControllers:@[pageController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:animated
                      completion:NULL];
    }
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
        searchViewController.coreDataStack = self.coreDataStack;
        searchViewController.closestSongID = [self closestSong].objectID;
        
        self.splitController.masterHidden = !self.splitController.masterHidden;
    } else {
        [self performSegueWithIdentifier:@"Search" sender:nil];
    }
}

@end
