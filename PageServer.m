//
//  PageServer.m
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageServer.h"
#import "BookPageController.h"
#import "SectionPageController.h"
#import "SongPageController.h"
#import "DataModelTests.h"
#import "Book+Helpers.h"
#import "Section+Helpers.h"
#import "Song+Helpers.h"

@interface PageServer()

@end

@implementation PageServer

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageController *before = nil;
    
    if ([viewController isKindOfClass:[SectionPageController class]]) {
        Section *section = [(SectionPageController *)viewController section];
        before = [self pageControllerForModelObject:[section previousObject]
                                 pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    } else if ([viewController isKindOfClass:[SongPageController class]]) {
        Song *song = [(SongPageController *)viewController song];
        before = [self pageControllerForModelObject:[song previousObject]
                                 pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    }

    return before;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageController *after = nil;
    
    if ([viewController isKindOfClass:[BookPageController class]]) {
        Book *book = [(BookPageController *)viewController book];
        after = [self pageControllerForModelObject:[book nextObject]
                                pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    } else if ([viewController isKindOfClass:[SectionPageController class]]) {
        Section *section = [(SectionPageController *)viewController section];
        after = [self pageControllerForModelObject:[section nextObject]
                                pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    } else if ([viewController isKindOfClass:[SongPageController class]]) {
        Song *song = [(SongPageController *)viewController song];
        after = [self pageControllerForModelObject:[song nextObject]
                                pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController];
    }

    return after;
}

#pragma mark - Helper methods

- (PageController *)pageControllerForModelObject:(NSManagedObject *)modelObject
                              pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController
{
    PageController *pageController;
    if ([modelObject isKindOfClass:[Book class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"BookPage"];
        ((BookPageController *)pageController).book = (Book *)modelObject;
    } else if ([modelObject isKindOfClass:[Section class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"SectionPage"];
        ((SectionPageController *)pageController).section = (Section *)modelObject;
    } else if ([modelObject isKindOfClass:[Song class]]) {
        pageController = [pageViewController.storyboard instantiateViewControllerWithIdentifier:@"SongPage"];
        ((SongPageController *)pageController).song = (Song *)modelObject;
    }
    
    if ([pageViewController conformsToProtocol:@protocol(PageControllerDelegate)]) {
        pageController.delegate = pageViewController;
    }
    
    return pageController;
}

@end
