//
//  SongbookViewController.m
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookViewController.h"
#import "PageViewController.h"

@interface SongbookViewController ()

@property (nonatomic, weak) PageViewController *pageViewController;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SongbookViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedPageViewController"]) {
        if ([segue.destinationViewController isKindOfClass:[PageViewController class]]) {
            self.pageViewController = segue.destinationViewController;
        }
    } else if ([segue.identifier isEqualToString:@"Search"]) {
        if ([segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
            SearchViewController *searchController = (SearchViewController *)segue.destinationViewController;
            searchController.currentSong = self.pageViewController.closestSong;
        }
    }
    NSLog(@"%@", segue.identifier);
}

- (IBAction)searchCancelled:(UIStoryboardSegue *)seque
{
}

@end
