//
//  PageViewController.m
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "PageViewController.h"
#import "SongbookModel.h"

@interface PageViewController ()

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
    [self.view setDebugColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    self.delegate = self.pageServer;
    self.dataSource = self.pageServer;
    [self setViewControllers:@[[self.pageServer pageAtIndex:0]]
                                 direction:UIPageViewControllerNavigationDirectionForward
                                  animated:NO
                                completion:NULL];
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

@end
