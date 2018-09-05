//
//  PageViewController.h
//  songbook
//
//  Created by Paul Himes on 7/25/13.
//

#import <UIKit/UIKit.h>
#import "PageServer.h"

@protocol PageViewControllerDelegate;

@interface PageViewController : UIPageViewController

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) PageServer *pageServer;
@property (nonatomic, weak) id<PageViewControllerDelegate> pageViewControllerDelegate;
@property (nonatomic, readonly) NSManagedObjectID *closestSongID;
@property (nonatomic, readonly) id<SongbookModel> pageModelObject;
@property (nonatomic, readonly) UIColor *pageControlColor;

- (void)showPageForModelObject:(id<SongbookModel>)modelObject
                highlightRange:(NSRange)highlightRange
                      animated:(BOOL)animated;
- (void)updateThemedElements;

@end

@protocol PageViewControllerDelegate <NSObject>

- (void)closeBook;
- (void)pageDidChange;

@end
