//
//  PageViewController.m
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageViewController.h"
#import "Book+Helpers.h"

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kDelegateKey = @"DelegateKey";
static NSString * const kViewControllerKey = @"ViewControllerKey";

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
    self.view.backgroundColor = [Theme paperColor];
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
                          completion:nil];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
        
    // Save the core data stack.
    if (self.coreDataStack) {
        [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    }
    
    // Save the delegate
    if (self.pageViewControllerDelegate) {
        [coder encodeObject:self.pageViewControllerDelegate forKey:kDelegateKey];
    }
    
    // Save the view controllers.
    if ([self.viewControllers count] > 0) {
        UIViewController *viewController = self.viewControllers[0];
        [coder encodeObject:viewController forKey:kViewControllerKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    // Decode the core data stack.
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    
    // Decode the delegate.
    self.pageViewControllerDelegate = [coder decodeObjectForKey:kDelegateKey];
    
    // Decode the visible view controller.
    UIViewController *viewController = [coder decodeObjectForKey:kViewControllerKey];
    
    // Create a new view controller if we failed to decode one.
    if (!viewController) {
        Book *book = [Book bookFromContext:self.coreDataStack.managedObjectContext];
        // If there is a model to display...
        if (book) {
            viewController = [self.pageServer pageControllerForModelObject:book pageViewController:self];
        }
    }
    
    // Show the restored or created view controller.
    if (viewController) {
        [self setViewControllers:@[viewController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:nil];
    } else {
        // There is no page to display. Close the book.
        [self.pageViewControllerDelegate closeBook];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSManagedObjectID *)closestSongID
{
    PageController *currentController = self.viewControllers[0];
    id<SongbookModel> modelObject = currentController.modelObject;
    
    id<SongbookModel> songbookModel = (id<SongbookModel>)modelObject;
    return songbookModel.closestSong.objectID;
}

- (NSArray<NSURL *> *)pageSongFiles
{
    PageController *currentController = self.viewControllers[0];
    return currentController.pageSongFiles;
}

- (UIColor *)pageControlColor
{
    PageController *currentController = self.viewControllers[0];
    return currentController.pageControlColor;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers direction:(UIPageViewControllerNavigationDirection)direction animated:(BOOL)animated completion:(void (^)(BOOL))completion
{
    __weak PageViewController *welf = self;
    [super setViewControllers:viewControllers direction:direction animated:animated completion:^(BOOL completed) {
        [welf.pageViewControllerDelegate pageDidChange];
    }];
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
                      completion:nil];
    }
}

#pragma mark - PageControllerDelegate

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject
{
    [self showPageForModelObject:modelObject highlightRange:NSMakeRange(0, 0) animated:NO];
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    [self.pageViewControllerDelegate pageDidChange];
}

@end
