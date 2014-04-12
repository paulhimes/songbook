//
//  PlaySongViewController.h
//  songbook
//
//  Created by Paul Himes on 4/9/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import <UIKit/UIKit.h>

@import AVFoundation;

@protocol PlaySongViewControllerDelegate;

@interface PlaySongViewController : UIViewController

@property (nonatomic, weak) id<PlaySongViewControllerDelegate> delegate;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@protocol PlaySongViewControllerDelegate <NSObject>

- (void)playSongViewControllerDidStop:(PlaySongViewController *)playSongViewController;

@end