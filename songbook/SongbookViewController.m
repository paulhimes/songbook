//
//  SongbookViewController.m
//  songbook
//
//  Created by Paul Himes on 8/22/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookViewController.h"
#import "SearchViewController.h"
#import "PageViewController.h"
#import "BookParser.h"

@interface SongbookViewController () <UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (nonatomic, weak) PageViewController *pageViewController;

@end

@implementation SongbookViewController

- (void)viewDidLoad
{
    self.toolbar.delegate = self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)searchCancelled:(UIStoryboardSegue *)segue
{
}

- (IBAction)songSelected:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = (SearchViewController *)segue.sourceViewController;
        
        if (searchViewController.selectedSong) {
            [self.pageViewController showPageForModelObject:searchViewController.selectedSong animated:NO];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedPageViewController"] &&
        [segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        self.pageViewController = segue.destinationViewController;
    } else if ([segue.identifier isEqualToString:@"Search"] &&
               [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        
        searchViewController.currentSong = self.pageViewController.closestSong;
    }
}

- (IBAction)testAction:(id)sender
{

}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
