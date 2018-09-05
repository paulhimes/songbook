//
//  ExportProgressViewController.m
//  songbook
//
//  Created by Paul Himes on 5/2/14.
//

#import "ExportProgressViewController.h"
#import "songbook-Swift.h"

@interface ExportProgressViewController ()

@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *dialogBackground;
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dialogView.translatesAutoresizingMaskIntoConstraints = YES;
    self.dialogView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.dialogView.layer.cornerRadius = 10;

    switch ([Theme currentThemeColor]) {
        case ThemeColorLight:
            self.dialogBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            break;
        case ThemeColorDark:
            self.dialogBackground.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            break;
    }

    self.label.textColor = [Theme textColor];
    self.progressView.trackTintColor = [Theme grayTrimColor];
    self.progressView.progressTintColor = [Theme redColor];

    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @-15;
    horizontalMotionEffect.maximumRelativeValue = @15;
    
    [self.dialogView addMotionEffect:horizontalMotionEffect];
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @-15;
    verticalMotionEffect.maximumRelativeValue = @15;
    
    [self.dialogView addMotionEffect:verticalMotionEffect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect dialogFrame = self.dialogView.frame;
    dialogFrame.origin.y = -dialogFrame.size.height;
    dialogFrame.origin.x = (self.view.bounds.size.width - dialogFrame.size.width) / 2;
    self.dialogView.frame = dialogFrame;
}

- (void)setProgress:(CGFloat)progress
{
    if (progress > self.progressView.progress) {
        [self.progressView setProgress:progress animated:YES];
    }
}

- (void)showWithCompletion:(void (^)(void))completion
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

- (void)hideWithCompletion:(void (^)(void))completion
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

@end
