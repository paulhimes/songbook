//
//  ExportProgressViewController.m
//  songbook
//
//  Created by Paul Himes on 5/2/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "ExportProgressViewController.h"

@interface ExportProgressViewController () <UIToolbarDelegate>

@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UIToolbar *dialogBackground;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation ExportProgressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dialogView.layer.cornerRadius = 10;
    self.dialogBackground.barTintColor = [Theme paperColor];
    self.label.textColor = [Theme textColor];
    
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @-10;
    horizontalMotionEffect.maximumRelativeValue = @10;
    
    [self.dialogView addMotionEffect:horizontalMotionEffect];
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @-10;
    verticalMotionEffect.maximumRelativeValue = @10;
    
    [self.dialogView addMotionEffect:verticalMotionEffect];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.dialogBackground.frame = CGRectMake(0, 0, self.dialogView.bounds.size.width, self.dialogView.bounds.size.height);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect dialogFrame = self.dialogView.frame;
    dialogFrame.origin.y = -dialogFrame.size.height;
    self.dialogView.frame = dialogFrame;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > self.progressView.progress) {
        [self.progressView setProgress:progress animated:YES];
    }
}

- (void)showWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:0.4
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
        self.backgroundView.alpha = 1.0;
        self.dialogView.center = CGPointMake(self.view.bounds.size.width / 2.0,
                                             self.view.bounds.size.height / 2.0);
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (void)hideWithCompletion:(void (^)())completion
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.backgroundView.alpha = 0.0;
        CGRect dialogFrame = self.dialogView.frame;
        dialogFrame.origin.y = self.view.bounds.size.height;
        self.dialogView.frame = dialogFrame;
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

- (IBAction)exportCancelled:(id)sender
{
    [self.delegate exportProgressViewControllerDidCancel:self];
}

#pragma mark - UIToolbarDelegate

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTop;
}

@end
