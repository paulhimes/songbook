//
//  PageViewController.h
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Song.h"

@protocol PageViewControllerDelegate;

@interface PageViewController : UIPageViewController

@property (nonatomic, weak) id<PageViewControllerDelegate> pageViewControllerDelegate;
@property (nonatomic, readonly) Song *closestSong;

@end

@protocol PageViewControllerDelegate <NSObject>

- (void)pageViewController:(PageViewController *)pageViewController contentTitleChangedTo:(NSString *)contentTitle;

@end