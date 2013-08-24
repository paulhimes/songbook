//
//  SongbookViewController.m
//  songbook
//
//  Created by Paul Himes on 8/22/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookViewController.h"

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

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
