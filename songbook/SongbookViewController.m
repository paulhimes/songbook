//
//  SongbookViewController.m
//  songbook
//
//  Created by Paul Himes on 8/22/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookViewController.h"
#import "SearchViewController.h"

@interface SongbookViewController () <UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"] &&
        [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        
        searchViewController.currentSong = 
    }
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
