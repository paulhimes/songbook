//
//  PageViewController.m
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageViewController.h"
#import "Book+Helpers.h"
#import "songbook-Swift.h"

static NSString * const kBookmarkedPageModelObjectIDStringKey = @"BookmarkedPageModelObjectIDStringKey";

@interface PageViewController () <PageControllerDelegate, UIPageViewControllerDelegate>

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
    self.delegate = self;
    self.dataSource = self.pageServer;    

    [self updateThemedElements];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.coreDataStack && [self.viewControllers count] == 0) {
        // Try to retrieve bookmarked page model object.
        id<SongbookModel> bookmarkedPageModelObject = [self loadBookmarkedPageModelObject];
        
        id<SongbookModel> targetPageModelObject = nil;
        if (bookmarkedPageModelObject) {
            // Use the bookmarked object if it exists.
            targetPageModelObject = (id<SongbookModel>)bookmarkedPageModelObject;
        } else {
            // Otherwise try to use the first page (the book cover).
            targetPageModelObject = [Book bookFromContext:self.coreDataStack.managedObjectContext];
        }
        
        // If there was a model to display...
        if (targetPageModelObject) {
            [self setViewControllers:@[[self.pageServer pageControllerForModelObject:targetPageModelObject
                                                                  pageViewController:self]]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];
        }
    }
}

- (void)viewLayoutMarginsDidChange
{
    [super viewLayoutMarginsDidChange];
    for (UIViewController *viewController in self.viewControllers) {
        viewController.view.directionalLayoutMargins = self.view.directionalLayoutMargins;
    }
    return;
}

- (void)updateThemedElements
{
    self.view.backgroundColor = [Theme paperColor];
    for (PageController *pageController in self.viewControllers) {
        [pageController updateThemedElements];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (NSManagedObjectID *)closestSongID
{
    if (self.viewControllers.count > 0) {
        PageController *currentController = self.viewControllers[0];
        id<SongbookModel> modelObject = currentController.modelObject;
        
        id<SongbookModel> songbookModel = (id<SongbookModel>)modelObject;
        return songbookModel.closestSong.objectID;
    } else {
        return nil;
    }
}

- (id<SongbookModel>)pageModelObject
{
    if (self.viewControllers.count > 0) {
        PageController *currentController = self.viewControllers[0];
        return currentController.modelObject;
    } else {
        return nil;
    }
}

- (UIColor *)pageControlColor
{
    if (self.viewControllers.count > 0) {
        PageController *currentController = self.viewControllers[0];
        return currentController.pageControlColor;
    } else {
        return nil;
    }
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    for (UIViewController *viewController in viewControllers) {
        viewController.viewRespectsSystemMinimumLayoutMargins = NO;
        viewController.view.insetsLayoutMarginsFromSafeArea = NO;
        viewController.view.directionalLayoutMargins = self.view.directionalLayoutMargins;
    }
    
    __weak PageViewController *welf = self;
    [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL completed) {
        [welf handlePageChange];
    }];
}

- (void)showPageForModelObject:(id<SongbookModel>)modelObject
                highlightRange:(NSRange)highlightRange
                      animated:(BOOL)animated;
{
    PageController *pageController = [self.pageServer pageControllerForModelObject:modelObject
                                                                pageViewController:self];
    pageController.highlightRange = highlightRange;
    
    if (pageController) {
        NSUInteger currentModelPageIndex = [self.pageModelObject pageIndex];
        NSUInteger newModelPageIndex = [modelObject pageIndex];

        if (currentModelPageIndex == newModelPageIndex) {
            [self setViewControllers:@[pageController]
                           direction:UIPageViewControllerNavigationDirectionForward
                            animated:NO
                          completion:nil];
        } else {
            UIPageViewControllerNavigationDirection direction = currentModelPageIndex > newModelPageIndex ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;

            [self setViewControllers:@[pageController]
                           direction:direction
                            animated:animated
                          completion:nil];
        }
    }
}

- (void)handlePageChange
{
    [self bookmarkPageModelObject:self.pageModelObject];
    [self.pageViewControllerDelegate pageDidChange];
}

- (void)bookmarkPageModelObject:(id<SongbookModel>)pageModelObject
{
    [NSUserDefaults.standardUserDefaults setObject:pageModelObject.objectID.URIRepresentation.absoluteString forKey:kBookmarkedPageModelObjectIDStringKey];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (id<SongbookModel>)loadBookmarkedPageModelObject
{
    NSString *bookmarkedPageModelObjectIDString = [NSUserDefaults.standardUserDefaults stringForKey:kBookmarkedPageModelObjectIDStringKey];
    NSURL *bookmarkedPageModelObjectIDURL = [NSURL URLWithString:bookmarkedPageModelObjectIDString];
    NSManagedObjectID *bookmarkedPageModelObjectID = [self.coreDataStack.managedObjectContext.persistentStoreCoordinator managedObjectIDForURIRepresentation:bookmarkedPageModelObjectIDURL];
    if (!bookmarkedPageModelObjectID) { return nil; }
    NSError *error = nil;
    return [self.coreDataStack.managedObjectContext existingObjectWithID:bookmarkedPageModelObjectID error:&error];
}

#pragma mark - PageControllerDelegate

- (void)pageController:(PageController *)pageController
   selectedModelObject:(id<SongbookModel>)modelObject
{
    [self showPageForModelObject:modelObject highlightRange:NSMakeRange(0, 0) animated:NO];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers
{
    for (PageController *pendingPageController in pendingViewControllers) {
        [pendingPageController updateThemedElements];
        pendingPageController.view.directionalLayoutMargins = self.view.directionalLayoutMargins;
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self handlePageChange];
}

@end
