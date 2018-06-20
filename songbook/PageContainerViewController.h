//
//  PageContainerViewController.h
//  songbook
//
//  Created by Paul Himes on 11/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@protocol PageContainerViewControllerDelegate;

@interface PageContainerViewController : UIViewController <PageViewControllerDelegate>

@property (nonatomic, weak) id<PageContainerViewControllerDelegate> delegate;
@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, readonly) NSManagedObjectID *closestSongID;

- (void)updateThemedElements;
- (void)selectSong:(NSManagedObjectID *)selectedSongID
         withRange:(NSRange)range;

@end

@protocol PageContainerViewControllerDelegate <NSObject>

- (void)search:(PageContainerViewController *)pageContainerViewController;

@end
