//
//  SearchViewController.h
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//

#import <UIKit/UIKit.h>
#import "CoreDataStack.h"

@protocol SearchViewControllerDelegate;

@interface SearchViewController : UIViewController

@property (nonatomic, strong) CoreDataStack *coreDataStack;
@property (nonatomic, strong) NSManagedObjectID *closestSongID;

@property (nonatomic, weak) id<SearchViewControllerDelegate> delegate;

- (void)beginSearch;
- (void)endSearch;
- (void)updateThemedElements;

@end

@protocol SearchViewControllerDelegate <NSObject>

- (void)searchCancelled:(SearchViewController *)searchViewController;
- (void)searchViewController:(SearchViewController *)searchViewController selectedSong:(NSManagedObjectID *)selectedSongID withRange:(NSRange)range;

@end
