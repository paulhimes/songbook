//
//  SplitViewController.m
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SplitViewController.h"
#import "SearchViewController.h"

static NSString * const kSearchIsVisibleKey = @"SearchIsVisibleKey";
static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kPageViewControllerKey = @"PageViewControllerKey";
static NSString * const kSearchViewControllerKey = @"SearchViewControllerKey";

@interface SplitViewController () <PageViewControllerDelegate, SearchViewControllerDelegate>

@property (nonatomic, strong) SearchViewController *searchViewController;
@property (nonatomic, strong) PageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UIView *searchViewControllerContainer;
@property (weak, nonatomic) IBOutlet UIView *pageViewControllerContainer;

@property (nonatomic) BOOL searchIsVisible;

@end

@implementation SplitViewController

- (SearchViewController *)searchViewController
{
    if (!_searchViewController) {
        _searchViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchViewController"];
        _searchViewController.coreDataStack = self.coreDataStack;
        _searchViewController.delegate = self;
    }
    return _searchViewController;
}

- (PageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        _pageViewController.coreDataStack = self.coreDataStack;
        _pageViewController.pageViewControllerDelegate = self;
    }
    return _pageViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Add the PageViewController.
    [self addChildViewController:self.pageViewController];
    self.pageViewController.view.frame = CGRectMake(0, 0, self.pageViewControllerContainer.frame.size.width, self.pageViewControllerContainer.frame.size.height);
    [self.pageViewControllerContainer addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    // Save the search visibility state
    [coder encodeBool:self.searchIsVisible forKey:kSearchIsVisibleKey];
    
    // Save the core data stack.
    [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    
    // Save the page view controller.
    [coder encodeObject:self.pageViewController forKey:kPageViewControllerKey];
    
    // Save the search view controller.
    if (_searchViewController) {
        [coder encodeObject:_searchViewController forKey:kSearchViewControllerKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
    
    self.searchViewController = [coder decodeObjectForKey:kSearchViewControllerKey];
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];

    BOOL searchIsVisible = [coder decodeBoolForKey:kSearchIsVisibleKey];
    if (searchIsVisible) {
        [self showSearch];
    }
}

- (void)showSearch
{
    self.searchIsVisible = YES;
    
    [self addChildViewController:self.searchViewController];
    self.searchViewController.view.frame = CGRectMake(0, 0, self.searchViewControllerContainer.frame.size.width, self.searchViewControllerContainer.frame.size.height);
    [self.searchViewControllerContainer addSubview:self.searchViewController.view];
    
    [UIView animateWithDuration:0.5 animations:^{
        // Show search.
        [self.searchViewControllerContainer setOriginX:0];
        CGFloat detailOriginX = self.searchViewControllerContainer.frame.size.width + 1;
        [self.pageViewControllerContainer setOriginX:detailOriginX];
    } completion:^(BOOL finished) {
        [self.searchViewController didMoveToParentViewController:self];
        [self.pageViewControllerContainer setWidth:self.view.bounds.size.width - self.pageViewControllerContainer.frame.origin.x];
    }];
}

- (void)hideSearch
{
    self.searchIsVisible = NO;
    
    [self.searchViewController willMoveToParentViewController:nil];
    
    [UIView animateWithDuration:0.5 animations:^{
        // Hide search.
        [self.searchViewControllerContainer setOriginX:-self.searchViewControllerContainer.frame.size.width];
        self.pageViewControllerContainer.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    } completion:^(BOOL finished) {
        [self.searchViewController.view removeFromSuperview];
        [self.searchViewController removeFromParentViewController];
    }];
}

#pragma mark - PageViewControllerDelegate

- (void)search
{
    if (self.searchIsVisible) {
        // Hide search.
        [self hideSearch];
    } else {
        self.searchViewController.closestSongID = self.pageViewController.closestSongID;
        // Show search.
        [self showSearch];
    }
}

- (void)closeBook
{
    [self performSegueWithIdentifier:@"CloseBook" sender:nil];
}

#pragma mark - SearchViewControllerDelegate

- (void)searchCancelled:(SearchViewController *)searchViewController
{
    [self hideSearch];
}

- (void)searchViewController:(SearchViewController *)searchViewController
                selectedSong:(NSManagedObjectID *)selectedSongID
                   withRange:(NSRange)range
{
    if (selectedSongID) {
        Song *song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:selectedSongID error:nil];
        if (song) {
            [self.pageViewController showPageForModelObject:song
                                             highlightRange:range
                                                   animated:NO];
        }
    }
}

@end
