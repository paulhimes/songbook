//
//  PageViewController.m
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageViewController.h"
#import "SongbookModel.h"
#import "AppDelegate.h"
#import "DataModelTests.h"
#import "Book+Helpers.h"

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
    self.view.backgroundColor = [UIColor whiteColor];
//    [self.view setDebugColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    self.dataSource = self.pageServer;
    
    NSManagedObjectContext *context = ((AppDelegate *)[UIApplication sharedApplication].delegate).managedObjectContext;
    [DataModelTests populateSampleDataInContext:context];
    
    NSArray *books = [Book allBooksInContext:context];
    Book *book = [books firstObject];
    
    [self setViewControllers:@[[self.pageServer pageControllerForModelObject:book
                                                          pageViewController:self]]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:NULL];
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
                      animated:(BOOL)animated;
{
    PageController *pageController = [self.pageServer pageControllerForModelObject:modelObject
                                                                pageViewController:self];
    
    [self setViewControllers:@[pageController]
                   direction:UIPageViewControllerNavigationDirectionForward
                    animated:animated
                  completion:NULL];
}

#pragma mark - PageControllerDelegate

- (void)pageController:(PageController *)pageController
   selectedModelObject:(NSManagedObject *)modelObject
{
    [self showPageForModelObject:modelObject animated:NO];
}

@end
