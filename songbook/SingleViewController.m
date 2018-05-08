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
#import "Book+Helpers.h"
#import "Section.h"
#import "Song+Helpers.h"
#import "songbook-Swift.h"

static NSString * const kCoreDataStackKey = @"CoreDataStackKey";
static NSString * const kPageViewControllerKey = @"PageViewControllerKey";

static const NSTimeInterval kPlayerAnimationDuration = 0.5;

@interface SingleViewController () <ExportProgressViewControllerDelegate, AudioPlayerDelegate>

@property (nonatomic, strong) PageViewController *pageViewController;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomBar;
@property (nonatomic, strong) UIWindow *alertWindow;
@property (nonatomic, strong) ExportProgressViewController *exportProgressViewController;
@property (nonatomic) BOOL exportCancelled;
@property (nonatomic, strong) NSNumber *previousExportIncludedExtraFiles;
@property (nonatomic, strong) NSTimer *playbackTimer;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic, strong) AudioPlayer *audioPlayer;

// Default Toolbar Items
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityButton;

// Playback Toolbar Items
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *continuousPlaybackButton;

// Spacers
@property (strong, nonatomic) IBOutlet UIBarButtonItem *flexibleSpaceOne;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *flexibleSpaceTwo;

@end

@implementation SingleViewController

- (NSManagedObjectID *)closestSongID
{
    return self.pageViewController.closestSongID;
}

- (AudioPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        _audioPlayer = [[AudioPlayer alloc] initWithDirectory:self.coreDataStack.databaseDirectory];
        _audioPlayer.delegate = self;
    }
    return _audioPlayer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *clearImage = [[UIImage alloc] init];
    [self.bottomBar setBackgroundImage:clearImage forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [self.bottomBar setShadowImage:clearImage forToolbarPosition:UIBarPositionAny];
    [self updateThemedElements];

    [self.bottomBar setItems:@[self.searchButton, self.flexibleSpaceOne, self.activityButton] animated:NO];
    
    [self updateContinuousPlaybackButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.bottomBar invalidateIntrinsicContentSize];
}

- (void)viewLayoutMarginsDidChange
{
    [super viewLayoutMarginsDidChange];
    self.pageViewController.view.directionalLayoutMargins = self.view.directionalLayoutMargins;
}

- (void)updateThemedElements
{
    self.bottomBar.tintColor = self.pageViewController.pageControlColor;
    self.progressView.progressTintColor = self.pageViewController.pageControlColor;
    self.progressView.trackTintColor = [UIColor clearColor];

    [self.pageViewController updateThemedElements];
}

- (void)updateContinuousPlaybackButton
{
    switch (AudioPlayer.playbackMode) {
        case PlaybackModeSingle:
            self.continuousPlaybackButton.image = [UIImage imageNamed:@"continuousPlayback"];
            self.continuousPlaybackButton.tintColor = Theme.grayTrimColor;
            break;
        case PlaybackModeContinuous:
            self.continuousPlaybackButton.image = [UIImage imageNamed:@"continuousPlayback"];
            self.continuousPlaybackButton.tintColor = Theme.redColor;
            break;
        case PlaybackModeRepeatOne:
            self.continuousPlaybackButton.image = [UIImage imageNamed:@"repeat"];
            self.continuousPlaybackButton.tintColor = Theme.redColor;
            break;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EmbedPageViewController"] &&
        [segue.destinationViewController isKindOfClass:[PageViewController class]]) {
        self.pageViewController = segue.destinationViewController;
        self.pageViewController.viewRespectsSystemMinimumLayoutMargins = NO;
        self.pageViewController.view.insetsLayoutMarginsFromSafeArea = NO;
        self.pageViewController.view.directionalLayoutMargins = self.view.directionalLayoutMargins;

        self.pageViewController.pageViewControllerDelegate = self;
        self.pageViewController.coreDataStack = self.coreDataStack;
    }
    [self updateThemedElements];
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
    [self.delegate search:self];
}

- (IBAction)activityAction:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak SingleViewController *welf = self;
    
    NSArray<NSURL *> *pageSongFiles = @[];
    id<SongbookModel> pageModelObject = self.pageViewController.pageModelObject;
    if ([pageModelObject isKindOfClass:[Song class]]) {
        pageSongFiles = [self.audioPlayer audioFileURLsForSong:(Song *)pageModelObject];
    }
    
    if ([pageSongFiles count] == 1) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Play Tune" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [welf.audioPlayer startPlayingAtSong:(Song *)pageModelObject tuneIndex:0];
        }]];
    } else {
        [pageSongFiles enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [alertController addAction:[UIAlertAction actionWithTitle:[NSString stringWithFormat:@"Play Tune %lu", (unsigned long)(idx + 1)] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [welf.audioPlayer startPlayingAtSong:(Song *)pageModelObject tuneIndex:idx];
            }]];
        }];
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Share Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [welf shareBookWithExtraFiles:NO];
    }]];
    
    if (self.audioPlayer.hasSongFiles) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"Share Book & Tunes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [welf shareBookWithExtraFiles:YES];
        }]];
    }
    
    switch ([Theme currentThemeColor]) {
        case ThemeColorLight:
            [alertController addAction:[UIAlertAction actionWithTitle:@"Black Background" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [Theme setCurrentThemeColor:ThemeColorDark];
            }]];
            break;
        case ThemeColorDark:
            [alertController addAction:[UIAlertAction actionWithTitle:@"White Background" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [Theme setCurrentThemeColor:ThemeColorLight];
            }]];
            break;
    }
    
//    // Add options to set the normal font and the title number font.
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Normal Font" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        
//        for (NSString *normalFontName in Theme.normalFontNames) {
//            NSString *title = [NSString stringWithFormat:@"%@%@", normalFontName, [Theme.normalFontName isEqualToString:normalFontName]  ? @" ✓" : @""];
//            
//            [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                
//                [Theme loadFontNamed:normalFontName completion:^{
//                    Theme.normalFontName = normalFontName;
//                }];
//                
//                NSString *titleNumberFontName = Theme.defaultPairs[normalFontName];
//                [Theme loadFontNamed:titleNumberFontName completion:^{
//                    Theme.titleNumberFontName = titleNumberFontName;
//                }];
//                
//            }]];
//        }
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
//        [welf presentViewController:alertController animated:YES completion:nil];
//    }]];
//    
//    [alertController addAction:[UIAlertAction actionWithTitle:@"Title Number Font" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//        
//        for (NSString *titleNumberFontName in Theme.titleNumberFontNames) {
//            NSString *title = [NSString stringWithFormat:@"%@%@", titleNumberFontName, [Theme.titleNumberFontName isEqualToString:titleNumberFontName] ? @" ✓" : @""];
//
//            [alertController addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                [Theme loadFontNamed:titleNumberFontName completion:^{
//                    Theme.titleNumberFontName = titleNumberFontName;
//                }];
//            }]];
//        }
//        
//        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
//        [welf presentViewController:alertController animated:YES completion:nil];
//    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
    
    alertController.popoverPresentationController.barButtonItem = self.activityButton;
    
    [self presentViewController:alertController animated:YES completion:^{}];
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

#pragma mark - Song Playback

- (IBAction)stopPlayingAction:(id)sender
{
    [self.audioPlayer stopPlayback];
}

- (IBAction)continuousPlaybackAction:(UIBarButtonItem *)sender
{
    switch (AudioPlayer.playbackMode) {
        case PlaybackModeSingle:
            AudioPlayer.playbackMode = PlaybackModeContinuous;
            break;
        case PlaybackModeContinuous:
            AudioPlayer.playbackMode = PlaybackModeRepeatOne;
            break;
        case PlaybackModeRepeatOne:
            AudioPlayer.playbackMode = PlaybackModeSingle;
            break;
    }
    [self updateContinuousPlaybackButton];
}

- (void)playbackTimerUpdate
{
    float progress = 0.0;

    if (self.audioPlayer) {
        progress = self.audioPlayer.playbackProgress;
    }

    [self.progressView setProgress:progress animated:NO];
}

#pragma mark - PageViewControllerDelegate

- (void)closeBook
{
    [self performSegueWithIdentifier:@"CloseBook" sender:nil];
}

- (void)pageDidChange
{
    __weak SingleViewController *welf = self;
    [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [welf updateThemedElements];
    } completion:^(UIViewAnimatingPosition finalPosition) {}];
    
    if (self.audioPlayer.currentSong &&
        self.audioPlayer.currentSong != self.pageViewController.pageModelObject &&
        [self.pageViewController.pageModelObject isKindOfClass:[Song class]] &&
        [self.audioPlayer audioFileURLsForSong:((Song *)self.pageViewController.pageModelObject)].count > 0) {
        [self.audioPlayer startPlayingAtSong:((Song *)self.pageViewController.pageModelObject) tuneIndex:0];
    }
}

- (void)selectSong:(NSManagedObjectID *)selectedSongID
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
}

#pragma mark - ExportProgressViewControllerDelegate

- (void)exportProgressViewControllerDidCancel:(ExportProgressViewController *)exportProgressViewController
{
    self.exportCancelled = YES;
}

#pragma mark - AudioPlayerDelegate

- (void)audioPlayerStartedPlayingSong:(Song *)song tuneIndex:(NSInteger)tuneIndex
{
    [self.playbackTimer invalidate];
    self.playbackTimer = nil;
    
    self.progressView.progress = 0;
    
    [self.bottomBar setItems:@[self.flexibleSpaceOne, self.stopButton, self.flexibleSpaceTwo, self.continuousPlaybackButton] animated:YES];
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.progressView.alpha = 1;
    } completion:^(BOOL finished) {
        NSTimeInterval interval = 0.01;
        if (self.audioPlayer.duration > 0) {
            interval = self.audioPlayer.duration / (double)self.progressView.frame.size.width;
        }
        self.playbackTimer = [NSTimer timerWithTimeInterval:interval
                                                     target:self
                                                   selector:@selector(playbackTimerUpdate)
                                                   userInfo:nil
                                                    repeats:YES];
        
        NSRunLoop *runloop = [NSRunLoop mainRunLoop];
        [runloop addTimer:self.playbackTimer forMode:NSRunLoopCommonModes];
        [runloop addTimer:self.playbackTimer forMode:UITrackingRunLoopMode];
    }];

    if (self.pageViewController.pageModelObject != song) {
        [self.pageViewController showPageForModelObject:song highlightRange:NSMakeRange(0, 0) animated:YES];
    }
}

- (void)audioPlayerStopped
{
    [self.bottomBar setItems:@[self.searchButton, self.flexibleSpaceOne, self.activityButton] animated:YES];
    [UIView animateWithDuration:kPlayerAnimationDuration animations:^{
        self.progressView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.playbackTimer invalidate];
        self.playbackTimer = nil;
    }];
}

@end
