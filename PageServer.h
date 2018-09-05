//
//  PageServer.h
//  songbook
//
//  Created by Paul Himes on 7/27/13.
//

#import <Foundation/Foundation.h>
#import "PageController.h"

@interface PageServer : NSObject <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (PageController *)pageControllerForModelObject:(id<SongbookModel>)modelObject
                              pageViewController:(UIPageViewController<PageControllerDelegate> *)pageViewController;

@end
