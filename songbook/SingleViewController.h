//
//  SingleViewController.h
//  songbook
//
//  Created by Paul Himes on 11/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageViewController.h"

@protocol SingleViewControllerDelegate;

@interface SingleViewController : UIViewController <PageViewControllerDelegate>

@property (nonatomic, weak) id<SingleViewControllerDelegate> delegate;
@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, readonly) NSManagedObjectID *closestSongID;

- (void)updateThemedElements;
- (void)selectSong:(NSManagedObjectID *)selectedSongID
         withRange:(NSRange)range;

@end

@protocol SingleViewControllerDelegate <NSObject>

- (void)search:(SingleViewController *)singleViewController;

@end
