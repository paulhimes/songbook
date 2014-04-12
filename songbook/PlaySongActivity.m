//
//  PlaySongActivity.m
//  songbook
//
//  Created by Paul Himes on 4/6/14.
//  Copyright (c) 2014 Paul Himes. All rights reserved.
//

#import "PlaySongActivity.h"
#import "PlaySongViewController.h"

@import AVFoundation;

@interface PlaySongActivity () <PlaySongViewControllerDelegate>

@property (nonatomic, strong) AVAudioPlayer *audioPlayer;

@end

@implementation PlaySongActivity

+ (UIActivityCategory)activityCategory
{
    return UIActivityCategoryAction;
}

- (NSString *)activityType
{
    return @"com.paulhimes.songbook.playsong";
}

- (NSString *)activityTitle
{
    return @"Play Song";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"PlaySongActivityIcon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    BOOL foundTargetItemType = NO;
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[AVAudioPlayer class]]) {
            foundTargetItemType = YES;
            break;
        }
    }
    return foundTargetItemType;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:[AVAudioPlayer class]]) {
            self.audioPlayer = activityItem;
            break;
        }
    }
}

- (UIViewController *)activityViewController
{
    PlaySongViewController *playSongViewController;
    
    if (self.audioPlayer) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Songbook" bundle:[NSBundle mainBundle]];
        playSongViewController = [storyboard instantiateViewControllerWithIdentifier:@"PlaySongViewController"];
        playSongViewController.audioPlayer = self.audioPlayer;
        playSongViewController.delegate = self;
    }
    
    return playSongViewController;
}

- (void)performActivity
{
    NSLog(@"Play Failed");
    
    [self activityDidFinish:YES];
}

#pragma mark - PlaySongViewControllerDelegate

- (void)playSongViewControllerDidStop:(PlaySongViewController *)playSongViewController;
{
    [self activityDidFinish:YES];
}

@end
