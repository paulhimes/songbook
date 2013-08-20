//
//  PageServer.h
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageController.h"
#import "Song.h"

@interface PageServer : NSObject <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (PageController *)pageControllerForModelObject:(NSManagedObject *)modelObject;

@end