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

@interface PageServer()

@property (nonatomic, strong) BookPageController *bookController;
@property (nonatomic, strong) SectionPageController *sectionController;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) Book *book;

@property (nonatomic, strong) PageController *destinationPageController;

@end

@implementation PageServer

- (id)init
{
    self = [super init];
    if (self) {
        self.context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
        [DataModelTests populateSampleDataInContext:self.context];
        
        NSArray *books = [Book allBooksInContext:self.context];
        self.book = [books firstObject];
    }
    return self;
}

- (BookPageController *)bookController
{
    if (!_bookController) {
        _bookController = [[BookPageController alloc] initWithBook:self.book];
    }
    return _bookController;
}

- (SectionPageController *)sectionController
{
    if (!_sectionController) {
        _sectionController = [[SectionPageController alloc] initWithSection:[self.book.sections firstObject]];
    }
    return _sectionController;
}

- (PageController *)pageAtIndex:(NSUInteger)index
{
    return self.bookController;
}

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
    
    return after;
}

#pragma mark - UIPageViewControllerDelegate

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    self.destinationPageController = [pendingViewControllers firstObject];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
//    if (finished && completed && self.destinationPageController) {
//        pageViewController
//    }
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
