//
//  PageServer.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageServer.h"
#import "Section+Helpers.h"

@interface PageServer()

@end

@implementation PageServer

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageController *before = nil;
    
    if ([viewController isKindOfClass:[PageController class]]) {
        PageController *pageController = (PageController *)viewController;
        id<SongbookModel> songbookModel = pageController.modelObject;
        before = [self pageControllerForModelObject:[songbookModel previousObject]
                                 pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    }

    return before;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageController *after = nil;
    
    if ([viewController isKindOfClass:[PageController class]]) {
        PageController *pageController = (PageController *)viewController;
        id<SongbookModel> songbookModel = pageController.modelObject;
        after = [self pageControllerForModelObject:[songbookModel nextObject]
                                pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    }

    return after;
}

#pragma mark - Helper methods

- (PageController *)pageControllerForModelObject:(id<SongbookModel>)modelObject
                              pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController
{
    PageController *pageController;
    if ([modelObject isKindOfClass:[Book class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"BookPage"];
    } else if ([modelObject isKindOfClass:[Section class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"SectionPage"];
    } else if ([modelObject isKindOfClass:[Song class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"SongPage"];
    }
    
    pageController.delegate = pageViewController;
    pageController.coreDataStack = [pageViewController coreDataStack];
    pageController.modelID = modelObject.objectID;
    
    return pageController;
}

@end
