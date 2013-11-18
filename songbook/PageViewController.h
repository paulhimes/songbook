//
//  PageViewController.h
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "PageServer.h"

@protocol PageViewControllerDelegate;

@interface PageViewController : UIPageViewController <UIViewControllerRestoration>

@property (nonatomic, strong) PageServer *pageServer;
@property (nonatomic, weak) id<PageViewControllerDelegate> bookDelegate;

- (void)showPageForModelObject:(NSManagedObject *)modelObject
                highlightRange:(NSRange)highlightRange
                      animated:(BOOL)animated;

@end

@protocol PageViewControllerDelegate <NSObject>

- (Book *)book;

@end