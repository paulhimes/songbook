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
    self.dataSource = self.pageServer;
    [self.view setDebugColor:[UIColor purpleColor]];
    
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
                          completion:NULL];
        }
    }
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
    
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    self.pageViewControllerDelegate = [coder decodeObjectForKey:kDelegateKey];
    
    UIViewController *viewController = [coder decodeObjectForKey:kViewControllerKey];
    if (viewController) {
        [self setViewControllers:@[viewController]
                       direction:UIPageViewControllerNavigationDirectionForward
                        animated:NO
                      completion:NULL];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (NSManagedObjectID *)closestSongID
{
    PageController *currentController = self.viewControllers[0];
    NSManagedObject *modelObject = currentController.modelObject;
    
    if ([modelObject conformsToProtocol:@protocol(SongbookModel)]) {
        id<SongbookModel> songbookModel = (id<SongbookModel>)modelObject;
        return songbookModel.closestSong.objectID;
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
    [self.pageViewControllerDelegate search];
}

@end
