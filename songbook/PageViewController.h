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

@interface PageViewController : UIPageViewController

@property (nonatomic, strong) PageServer *pageServer;
@property (nonatomic, strong) Book *book;

- (void)showPageForModelObject:(NSManagedObject *)modelObject
                highlightRange:(NSRange)highlightRange
                      animated:(BOOL)animated;

@end