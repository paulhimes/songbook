//
//  SingleViewController.m
//  songbook
//
//  Created by Paul Himes on 11/26/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import "SingleViewController.h"
#import "SearchViewController.h"
#import "BookCodec.h"
#import "ExportProgressViewController.h"
#import "BookActivityItemSource.h"

@import AVFoundation;

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kPageViewControllerKey = @"PageViewControllerKey";

static const NSTimeInterval kPlayerAnimationDuration = 0.5;

@interface SingleViewController () <SearchViewControllerDelegate, ExportProgressViewControllerDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) PageViewController *pageViewController;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *activityButton;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) ExportProgressViewController *exportProgressViewController;
@property (nonatomic) BOOL exportCancelled;
@property (nonatomic, strong) NSNumber *previousExportIncludedExtraFiles;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIView *playerView;

@end

@implementation SingleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *clearImage = [[UIImage alloc] init];
    [self.bottomBar setBackgroundImage:clearImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomBar setShadowImage:clearImage forToolbarPosition:UIBarPositionAny];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.bottomBar invalidateIntrinsicContentSize];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Search"] &&
        [segue.destinationViewController isKindOfClass:[SearchViewController class]]) {
        SearchViewController *searchViewController = ((SearchViewController *)segue.destinationViewController);
        searchViewController.delegate = self;
        searchViewController.coreDataStack = self.coreDataStack;
        searchViewController.closestSongID = self.pageViewController.closestSongID;
    } else if ([segue.identifier isEqualToString:@"EmbedPageViewController"] &&
               [segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.pageViewControllerDelegate = self;
        self.pageViewController.coreDataStack = self.coreDataStack;
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super encodeRestorableStateWithCoder:coder];
    
    // Save the core data stack.
    if (self.coreDataStack) {
        [coder encodeObject:self.coreDataStack forKey:kCoreDataStackKey];
    }
    
    // Save the page view controller.
    if (self.pageViewController) {
        [coder encodeObject:self.pageViewController forKey:kPageViewControllerKey];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    [super decodeRestorableStateWithCoder:coder];
    
    self.coreDataStack = [coder decodeObjectForKey:kCoreDataStackKey];
}

- (IBAction)searchAction:(id)sender
{
    [self performSegueWithIdentifier:@"Search" sender:nil];
}

- (IBAction)activityAction:(id)sender
{
    if ([self bookDirectoryHasSongFiles]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        __weak SingleViewController *welf = self;
        
        NSArray<NSURL *> *pageSongFiles = self.pageViewController.pageSongFiles;
        
        if ([pageSongFiles count] == 1) {
            [alertController addAction:[UIAlertAction actionWithTitle:@"Play Tune" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [welf playSongFile:pageSongFiles[0]];
            }]];
        } else {
            [pageSongFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Play Tune %lu", (unsigned long)(idx + 1)] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [welf playSongFile:pageSongFiles[idx]];
                }]];
            }];
        }
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [welf shareBookWithExtraFiles:NO];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share Book & Tunes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [welf shareBookWithExtraFiles:YES];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
        
        alertController.popoverPresentationController.barButtonItem = self.activityButton;
        
        [self presentViewController:alertController animated:YES completion:^{}];
    } else {
        [self shareBookWithExtraFiles:NO];
    }
}

#pragma mark - Book Sharing

- (void)shareBookWithExtraFiles:(BOOL)includeExtraFiles
{
    __block NSURL *exportedFileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[exportedFileURL path]] &&
        self.previousExportIncludedExtraFiles &&
        [self.previousExportIncludedExtraFiles boolValue] == includeExtraFiles) {
        // Just share the existing file.
        [self shareExportedBookFile:exportedFileURL];
    } else {
        // Determine the source directory for the book files.
        NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
        
        if (includeExtraFiles) {
            // Create the alert window and view controller.
            self.alertWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            self.alertWindow.opaque = NO;
            self.alertWindow.tintColor = [Theme redColor];
            self.exportProgressViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExportProgressViewController"];
            self.exportProgressViewController.delegate = self;
            //Put window on top of all other windows/views
            [self.alertWindow setWindowLevel:UIWindowLevelNormal];
            [self.alertWindow setRootViewController:self.exportProgressViewController];
            [self.alertWindow makeKeyAndVisible];
            [self.exportProgressViewController showWithCompletion:nil];
            self.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            
            self.exportCancelled = NO;
            
            // Export the book directory to a file, and share it when ready.
            __weak SingleViewController *welf = self;
            __weak ExportProgressViewController *weakProgressViewController = self.exportProgressViewController;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                exportedFileURL = [BookCodec exportBookFromDirectory:bookDirectory
                                                   includeExtraFiles:includeExtraFiles
                                                            progress:^(CGFloat progress, BOOL *stop) {
                                                                dispatch_sync(dispatch_get_main_queue(), ^{
                                                                    [weakProgressViewController setProgress:progress];
                                                                    
                                                                    *stop = welf.exportCancelled;
                                                                });
                                                            }];
                dispatch_async(dispatch_get_main_queue(), ^{
                    //Dismiss alert by making main window key and visible
                    [welf.exportProgressViewController hideWithCompletion:^{
                        welf.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
                        [welf.view.window makeKeyAndVisible];
                        welf.alertWindow = nil;
                        welf.exportProgressViewController = nil;
                        
                        // Share the completed book file.
                        welf.previousExportIncludedExtraFiles = @(includeExtraFiles);
                        [welf shareExportedBookFile:exportedFileURL];
                    }];
                });
            });
        } else {
            exportedFileURL = [BookCodec exportBookFromDirectory:bookDirectory
                                               includeExtraFiles:NO
                                                        progress:nil];
            self.previousExportIncludedExtraFiles = @(includeExtraFiles);
            [self shareExportedBookFile:exportedFileURL];
        }
    }
}

- (void)shareExportedBookFile:(NSURL *)exportedFileURL
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:exportedFileURL.path]) {
        
        NSArray *activityItems = @[[[BookActivityItemSource alloc] initWithBookFileURL:exportedFileURL]];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems
                                                                                             applicationActivities:nil];
        
        activityViewController.completionWithItemsHandler = ^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError *activityError) {
            if (completed) {
                // Delete the temporary file.
                NSURL *fileURL = [BookCodec fileURLForExportingFromContext:self.coreDataStack.managedObjectContext];
                if (fileURL && [[NSFileManager defaultManager] fileExistsAtPath:fileURL.path]) {
                    NSError *deleteError;
                    if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&deleteError]) {
                        NSLog(@"Failed to delete temporary export file: %@", deleteError);
                    }
                }
            }
        };
        
        activityViewController.popoverPresentationController.barButtonItem = self.activityButton;
        
        [self presentViewController:activityViewController animated:YES completion:^{}];
    }
}

- (BOOL)bookDirectoryHasSongFiles
{
    NSURL *bookDirectory = self.coreDataStack.databaseDirectory;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:bookDirectory
                                                   includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                      options:0
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"Error enumerating url: %@", url);
                                                                     return YES;
                                                                 }];
    
    BOOL foundSongFile = NO;
    
    for (NSURL *url in directoryEnumerator) {
        // Skip directories.
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if ([isDirectory boolValue]) {
            continue;
        }
        
        NSString *fileExtension = [url pathExtension];
        if ([fileExtension localizedCaseInsensitiveCompare:@"m4a"] == NSOrderedSame ||
            [fileExtension localizedCaseInsensitiveCompare:@"mp3"] == NSOrderedSame ||
            [fileExtension localizedCaseInsensitiveCompare:@"wav"] == NSOrderedSame) {
            
            foundSongFile = YES;
            break;
        }
    }
    
    return foundSongFile;
}

#pragma mark - Song Playback

- (void)playSongFile:(NSURL *)songFile
{
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    self.progressView.progress = 0;
    
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.playerView.alpha = 1;
        self.bottomBar.alpha = 0;
    } completion:^(BOOL finished) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:songFile error:nil];
        self.audioPlayer.delegate = self;
        
        if (self.audioPlayer) {
            
            self.playbackTimer = [NSTimer timerWithTimeInterval:0.01
                                                         target:self
                                                       selector:@selector(playbackTimerUpdate)
                                                       userInfo:nil
                                                        repeats:YES];
            
            NSRunLoop *runloop = [NSRunLoop currentRunLoop];
            [runloop addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
            [runloop addTimer:self.playbackTimer forMode:UITrackingRunLoopMode];
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }];
}

- (IBAction)stopPlayingAction:(id)sender
{
    [self dismissPlayer];
}

- (void)dismissPlayer
{
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.playerView.alpha = 0;
        self.bottomBar.alpha = 1;
    } completion:^(BOOL finished) {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
        
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }];
}

- (void)playbackTimerUpdate
{
    float progress = 0.0;
    if (self.audioPlayer) {
        progress = self.audioPlayer.currentTime / self.audioPlayer.duration;
    }
    
    if (progress > self.progressView.progress) {
        [self.progressView setProgress:progress animated:YES];
    }
}

#pragma mark - PageViewControllerDelegate

- (void)closeBook
{
    [self performSegueWithIdentifier:@"CloseBook" sender:nil];
}

- (void)pageDidChange
{
    __weak SingleViewController *welf = self;
    [[[UIViewPropertyAnimator alloc] initWithDuration:0.4 curve:UIViewAnimationCurveEaseInOut animations:^{
        welf.bottomBar.tintColor = welf.pageViewController.pageControlColor;
    }] startAnimation];
}

#pragma mark - SearchViewControllerDelegate

- (void)searchCancelled:(SearchViewController *)searchViewController
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)searchViewController:(SearchViewController *)searchViewController
                selectedSong:(NSManagedObjectID *)selectedSongID
                   withRange:(NSRange)range
{
    if (selectedSongID) {
        Song *song = (Song *)[self.coreDataStack.managedObjectContext existingObjectWithID:selectedSongID error:nil];
        if (song) {
            [self.pageViewController showPageForModelObject:song
                                             highlightRange:range
                                                   animated:NO];
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - ExportProgressViewControllerDelegate

- (void)exportProgressViewControllerDidCancel:(ExportProgressViewController *)exportProgressViewController
{
    self.exportCancelled = YES;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self dismissPlayer];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self dismissPlayer];
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    [self dismissPlayer];
}

@end
