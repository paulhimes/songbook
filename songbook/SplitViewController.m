//
//  SplitViewController.m
//  songbook
//
//  Created by Paul Himes on 10/12/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <objc/runtime.h>

#import "SplitViewController.h"

@interface SplitViewController ()

@property (nonatomic, strong) UIViewController *master;
@property (nonatomic, strong) UIViewController *detail;

@property (weak, nonatomic) IBOutlet UIView *masterContainer;
@property (weak, nonatomic) IBOutlet UIView *detailContainer;

@end

@implementation SplitViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.masterHidden = YES;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedMaster"]) {
        self.master = segue.destinationViewController;
        self.master.splitController = self;
    } else if ([segue.identifier isEqualToString:@"EmbedDetail"]) {
        self.detail = segue.destinationViewController;
        self.detail.splitController = self;
    }
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"EmbedMaster"]) {
        return NO;
    }
    
    return YES;
}

- (UIViewController *)master
{
    if (!_master) {
        [self performSegueWithIdentifier:@"EmbedMaster" sender:self];
    }
    return _master;
}

- (void)setMasterHidden:(BOOL)masterHidden
{
    if (_master) {
        [UIView animateWithDuration:0.5 animations:^{
            if (_masterHidden && !masterHidden) {
                // Show master.
                [self.master viewWillAppear:YES];
                [self.masterContainer setOriginX:0];
                CGFloat detailOriginX = self.masterContainer.frame.size.width + 0.5;
                self.detailContainer.frame = CGRectMake(detailOriginX, 0, self.view.bounds.size.width - detailOriginX, self.view.bounds.size.height);
            } else if (!_masterHidden && masterHidden) {
                // Hide master.
                [self.master viewWillDisappear:YES];
                [self.masterContainer setOriginX:-self.masterContainer.frame.size.width];
                CGFloat detailOriginX = 0;
                self.detailContainer.frame = CGRectMake(detailOriginX, 0, self.view.bounds.size.width - detailOriginX, self.view.bounds.size.height);
            }
        } completion:^(BOOL finished) {
            if (_masterHidden && !masterHidden) {
                // Show master.
                [self.master viewDidAppear:YES];
            } else if (!_masterHidden && masterHidden) {
                // Hide master.
                [self.master viewDidDisappear:YES];
            }
        }];
    }
    
    _masterHidden = masterHidden;
}

@end

@implementation UIViewController (SplitViewController)

static char const * const splitControllerKey = "splitControllerKey";

- (SplitViewController *)splitController
{
    return objc_getAssociatedObject(self, splitControllerKey);
}

- (void)setSplitController:(SplitViewController *)splitController
{
    objc_setAssociatedObject(self, splitControllerKey, splitController, OBJC_ASSOCIATION_ASSIGN);
}

@end
