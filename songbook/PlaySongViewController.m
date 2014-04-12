//
//  PlaySongViewController.m
//  songbook
//
//  Created by Paul Himes on 4/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "PlaySongViewController.h"

static const NSTimeInterval kFadeDuration = 0.25;

@interface PlaySongViewController () <AVAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *playerView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic) CGFloat *progressShift;

@end

@implementation PlaySongViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self connectMotionEffects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.playerView setOriginY:self.view.bounds.size.height];
    self.audioPlayer.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:kFadeDuration animations:^{
        self.backgroundView.alpha = 0.3;
        [self.playerView setOriginY:self.view.bounds.size.height - self.playerView.frame.size.height];
    } completion:^(BOOL finished) {
        self.playbackTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                              target:self
                                                            selector:@selector(playbackTimerUpdate)
                                                            userInfo:nil
                                                             repeats:YES];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:NULL];
        [self.audioPlayer prepareToPlay];
        [self.audioPlayer play];
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (IBAction)stopAction:(id)sender
{
    [self dismiss];
}

- (void)connectMotionEffects
{
    CGFloat horizontalSwing = 10;
    CGFloat verticalSwing = 8;
    
    UIInterpolatingMotionEffect *stopMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    stopMotionEffect.minimumRelativeValue = @(-horizontalSwing);
    stopMotionEffect.maximumRelativeValue = @(horizontalSwing);
    [self.stopButton addMotionEffect:stopMotionEffect];
    
    UIInterpolatingMotionEffect *playViewOriginXMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"frame.origin.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    playViewOriginXMotionEffect.minimumRelativeValue = @(-verticalSwing);
    playViewOriginXMotionEffect.maximumRelativeValue = @(verticalSwing);
    [self.playerView addMotionEffect:playViewOriginXMotionEffect];
    
    UIInterpolatingMotionEffect *playViewSizeHeightMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"bounds.size.height" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    playViewSizeHeightMotionEffect.minimumRelativeValue = @(2 * verticalSwing);
    playViewSizeHeightMotionEffect.maximumRelativeValue = @(verticalSwing);
    [self.playerView addMotionEffect:playViewSizeHeightMotionEffect];
}

- (void)dismiss
{
    [self.playbackTimer invalidate];
    [self.audioPlayer stop];
    
    [UIView animateWithDuration:kFadeDuration animations:^{
        self.backgroundView.alpha = 0;
        [self.playerView setOriginY:self.view.bounds.size.height];
    } completion:^(BOOL finished) {
        [self.delegate playSongViewControllerDidStop:self];
    }];
}

- (void)playbackTimerUpdate
{
    float progress = self.audioPlayer.currentTime / self.audioPlayer.duration;    
    self.progressView.progress = progress;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self dismiss];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self dismiss];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self dismiss];
}

@end
