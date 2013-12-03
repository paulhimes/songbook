//
//  SplitViewController.m
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SplitViewController.h"
#import "PageViewController.h"
#import "SearchViewController.h"

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kPageViewControllerKey = @"PageViewControllerKey";
static NSString * const kSearchViewControllerKey = @"SearchViewControllerKey";

@interface SplitViewController () <PageViewControllerDelegate>

@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) PageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UIView *searchViewContrlllerContainer;
@property (weak, nonatomic) IBOutlet UIView *pageViewControllerContainer;

@end

@implementation SplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.searchHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedSearchViewController"] && [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.destinationViewController;
        searchViewController.coreDataStack = self.coreDataStack;
        self.searchViewController = searchViewController;
    } else if ([segue.identifier isEqualToString:@"EmbedPageViewController"] && [segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        PageViewController *pageViewController = (PageViewController *)segue.destinationViewController;
        pageViewController.pageViewControllerDelegate = self;
        pageViewController.coreDataStack = self.coreDataStack;
        self.pageViewController = pageViewController;
    }
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    // Save the core data stack.
    if (self.coreDataStack) {
        [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    }
    
    // Save the page view controller.
    if (self.pageViewController) {
        [coder encodeObject:self.pageViewController forKey:kPageViewControllerKey];
    }
    
    // Save the search view controller.
    if (self.searchViewController) {
        [coder encodeObject:self.searchViewController forKey:kSearchViewControllerKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
//    self.pageViewController = [coder decodeObjectForKey:kPageViewControllerKey];
//    self.searchViewController = [coder decodeObjectForKey:kSearchViewControllerKey];
}

- (IBAction)searchCancelled:(UIStoryboardSegue *)segue
{
}

- (IBAction)songSelected:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        
        if (searchViewController.selectedSongID) {
            NSError *getSongError;
            Song *song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:searchViewController.selectedSongID error:&getSongError];
            [self.pageViewController showPageForModelObject:song
                                             highlightRange:searchViewController.selectedRange
                                                   animated:NO];
        }
    }
}

- (void)setSearchHidden:(BOOL)searchHidden
{
    if (_searchHidden) {
        [UIView animateWithDuration:0.5 animations:^{
            if (_searchHidden && !searchHidden) {
                // Show search.
                [self.searchViewController viewWillAppear:YES];
                [self.searchViewContrlllerContainer setOriginX:0];
                CGFloat detailOriginX = self.searchViewContrlllerContainer.frame.size.width + 0.5;
                self.pageViewControllerContainer.frame = CGRectMake(detailOriginX, 0, self.view.bounds.size.width - detailOriginX, self.view.bounds.size.height);
            } else if (!_searchHidden && searchHidden) {
                // Hide search.
                [self.searchViewController viewWillDisappear:YES];
                [self.searchViewContrlllerContainer setOriginX:-self.searchViewContrlllerContainer.frame.size.width];
                CGFloat detailOriginX = 0;
                self.pageViewControllerContainer.frame = CGRectMake(detailOriginX, 0, self.view.bounds.size.width - detailOriginX, self.view.bounds.size.height);
            }
        } completion:^(BOOL finished) {
            if (_searchHidden && !searchHidden) {
                // Show search.
                [self.searchViewController viewDidAppear:YES];
            } else if (!_searchHidden && searchHidden) {
                // Hide search.
                [self.pageViewController viewDidDisappear:YES];
            }
        }];
    }
    
    _searchHidden = searchHidden;
}

#pragma mark - PageViewControllerDelegate

- (void)search
{
    self.searchViewController.coreDataStack = self.coreDataStack;
    self.searchViewController.closestSongID = self.pageViewController.closestSongID;
    self.searchHidden = NO;
}

@end
