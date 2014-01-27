//
//  SingleViewController.m
//  songbook
//
//  Created by Paul Himes on 11/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SingleViewController.h"
#import "SearchViewController.h"

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kPageViewControllerKey = @"PageViewControllerKey";

@interface SingleViewController () <SearchViewControllerDelegate>

@property (nonatomic, strong) PageViewController *pageViewController;

@end

@implementation SingleViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"] &&
        [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        searchViewController.delegate = self;
        searchViewController.coreDataStack = self.coreDataStack;
        searchViewController.closestSongID = self.pageViewController.closestSongID;
    } else if ([segue.identifier isEqualToString:@"EmbedPageViewController"] &&
               [segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.pageViewControllerDelegate = self;
        self.pageViewController.coreDataStack = self.coreDataStack;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
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
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
}

#pragma mark - PageViewControllerDelegate

- (void)search
{
    [self performSegueWithIdentifier:@"Search" sender:nil];
}

#pragma mark - SearchViewControllerDelegate

- (void)searchCancelled:(SearchViewController *)searchViewController
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)searchViewController:(SearchViewController *)searchViewController
                selectedSong:(NSManagedObjectID *)selectedSongID
                   withRange:(NSRange)range
{
    if (selectedSongID) {
        Song *song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:selectedSongID error:NULL];
        if (song) {
            [self.pageViewController showPageForModelObject:song
                                             highlightRange:range
                                                   animated:NO];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
