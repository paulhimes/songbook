//
//  SongbookViewController.m
//  songbook
//
//  Created by Paul Himes on 8/6/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SongbookViewController.h"
#import "PageViewController.h"

@interface SongbookViewController () <PageServerDelegate>

@property (nonatomic, weak) PageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UINavigationItem *singleNavigationItem;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation SongbookViewController

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGFLOAT_MAX, self.navigationBar.frame.size.height)];
        [_titleLabel setDebugColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:0.1]];
    }
    return _titleLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.singleNavigationItem.titleView = self.titleLabel;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedPageViewController"]) {
        if ([segue.destinationViewController isKindOfClass:[PageViewController class]]) {
            self.pageViewController = segue.destinationViewController;
            self.pageViewController.pageServer.delegate = self;
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

#pragma mark - PageServerDelegate

- (void)pageServer:(PageServer *)pageServer contentTitleChangedTo:(NSAttributedString *)contentTitle
{
    NSTimeInterval duration = 0.2;
    
    __weak SongbookViewController *weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.titleLabel.alpha = 0;
    } completion:^(BOOL finished) {
        
        weakSelf.titleLabel.attributedText = contentTitle;

        [UIView animateWithDuration:duration animations:^{
            weakSelf.titleLabel.alpha = 1;
        }];
    }];
}

@end
