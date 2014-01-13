//
//  AppDelegate.m
//  songbook
//
//  Created by Paul Himes on 7/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "PageController.h"
#import "BookCodec.h"
#import "BookManagerViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Crashlytics startWithAPIKey:@"9be265b58168dc66ff492f601ff87ed72389455f"];
    
    // Setup the default user defaults.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kStandardTextSizeKey: @20}];
    
    // Setup the window.
    self.window.tintColor = [Theme redColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    // Only restore state if the device type hasn't changed.
    NSNumber *idiom = [coder decodeObjectForKey:UIApplicationStateRestorationUserInterfaceIdiomKey];
    return [idiom integerValue] == [[UIDevice currentDevice] userInterfaceIdiom];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self handoffImportFile:url];
    return YES;
}

- (void)handoffImportFile:(NSURL *)url
{
    if ([url isFileURL]) {
        // Give the import file url to the book manager.
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Songbook" bundle:nil];
        BookManagerViewController *bookManagerViewController = [storyboard instantiateInitialViewController];
        bookManagerViewController.importFileURL = url;
        self.window.rootViewController = bookManagerViewController;
    } else {
        NSLog(@"Import URL was not a file: %@", url);
    }
    
    // Delete all inbox files other than this one.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *inbox = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
    NSError *contentsError;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtURL:inbox
                                            includingPropertiesForKeys:nil
                                                               options:0
                                                                 error:&contentsError];
    for (NSURL *item in directoryContents) {
        if (![item isEqual:url]) {
            NSError *deleteError;
            if (![fileManager removeItemAtURL:item error:&deleteError]) {
                NSLog(@"Failed to delete out-dated inbox file: %@", deleteError);
            }
        }
    }
}
                    
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
