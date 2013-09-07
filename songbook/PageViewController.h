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

@interface PageViewController : UIPageViewController

@property (nonatomic, strong) PageServer *pageServer;

- (Song *)closestSong;
- (void)showPageForModelObject:(NSManagedObject *)modelObject
                      animated:(BOOL)animated;

@end