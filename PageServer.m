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
#import "AppDelegate.h"
#import "DataModelTests.h"
#import "Book+Helpers.h"
#import "Section+Helpers.h"
#import "Song+Helpers.h"
#import "PageViewController.h"

@interface PageServer()

@end

@implementation PageServer

#pragma mark - UIPageViewControllerDataSource

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    PageController *before = nil;
    
    if ([viewController isKindOfClass:[SectionPageController class]]) {
        Section *section = [(SectionPageController *)viewController section];
        before = [self pageControllerForModelObject:[section previousObject]];
    } else if ([viewController isKindOfClass:[SongPageController class]]) {
        Song *song = [(SongPageController *)viewController song];
        before = [self pageControllerForModelObject:[song previousObject]];
    }
    
    if ([pageViewController isKindOfClass:[PageViewController class]]) {
        before.delegate = (PageViewController *)pageViewController;
    }
    return before;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    PageController *after = nil;
    
    if ([viewController isKindOfClass:[BookPageController class]]) {
        Book *book = [(BookPageController *)viewController book];
        after = [self pageControllerForModelObject:[book nextObject]];
    } else if ([viewController isKindOfClass:[SectionPageController class]]) {
        Section *section = [(SectionPageController *)viewController section];
        after = [self pageControllerForModelObject:[section nextObject]];
    } else if ([viewController isKindOfClass:[SongPageController class]]) {
        Song *song = [(SongPageController *)viewController song];
        after = [self pageControllerForModelObject:[song nextObject]];
    }
    
    if ([pageViewController isKindOfClass:[PageViewController class]]) {
        after.delegate = (PageViewController *)pageViewController;
    }
    return after;
}

- (PageController *)pageControllerForModelObject:(NSManagedObject *)modelObject
{
    PageController *pageController;
    if ([modelObject isKindOfClass:[Book class]]) {
        pageController = [[BookPageController alloc] initWithBook:(Book *)modelObject];
    } else if ([modelObject isKindOfClass:[Section class]]) {
        pageController = [[SectionPageController alloc] initWithSection:(Section *)modelObject];
    } else if ([modelObject isKindOfClass:[Song class]]) {
        pageController = [[SongPageController alloc] initWithSong:(Song *)modelObject];
    }
    return pageController;
}

@end
