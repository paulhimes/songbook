//
//  PageViewController.h
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"
#import "PageServer.h"
#import "PageController.h"

@interface PageViewController : UIPageViewController <PageControllerDelegate>

@property (nonatomic, readonly) Song *closestSong;
@property (nonatomic, strong) PageServer *pageServer;

@end