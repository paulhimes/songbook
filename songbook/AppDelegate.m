//
//  AppDelegate.m
//  songbook
//
//  Created by Paul Himes on 7/24/13.
//  Copyright (c) 2013 Paul Himes. All rights reserved.
//

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "AppDelegate.h"
#import "PageController.h"
#import "BookManagerViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit]];
    
    // Setup the default user defaults.
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kStandardTextSizeKey: @18}];
    
    // Setup the window.
    self.window.tintColor = [Theme redColor];
    [self.window makeKeyAndVisible];
    
    // Disable screen sleeping.
    application.idleTimerDisabled = YES;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
    return YES;
}

- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
    // Only restore state if the device type hasn't changed.
    NSNumber *savedIdiom = [coder decodeObjectForKey:UIApplicationStateRestorationUserInterfaceIdiomKey];
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    BOOL equalIdioms = [savedIdiom integerValue] == idiom;
    
    // Only restore state if the app version hasn't changed.
    NSString *savedAppVersion = [coder decodeObjectForKey:UIApplicationStateRestorationBundleVersionKey];
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][(NSString *)kCFBundleVersionKey];
    BOOL equalAppVersions = [savedAppVersion isEqualToString:appVersion];
    
    // Only restore state if the system version hasn't changed.
    NSString *savedSystemVersion = [coder decodeObjectForKey:UIApplicationStateRestorationSystemVersionKey];
    NSString *systemVersion = [UIDevice currentDevice].systemVersion;
    BOOL equalSystemVersions = [savedSystemVersion isEqualToString:systemVersion];
    
    return equalIdioms && equalAppVersions && equalSystemVersions;
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSLog(@"State restoration complete.");
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
        NSString *storyboardName = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"Songbook~iPad" : @"Songbook";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
        BookManagerViewController *bookManagerViewController = [storyboard instantiateInitialViewController];
        bookManagerViewController.importFileURL = url;
        self.window.rootViewController = bookManagerViewController;
    } else {
        NSLog(@"Import URL was not a file: %@", url);
    }
    
    // Delete all inbox files other than this one.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *inbox = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Inbox" isDirectory:YES];
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtURL:inbox
                                            includingPropertiesForKeys:nil
                                                               options:0
                                                                 error:nil];
    for (NSURL *item in directoryContents) {
        if (![item isEqual:url]) {
            NSError *deleteError;
            if (![fileManager removeItemAtURL:item error:&deleteError]) {
                NSLog(@"Failed to delete out-dated inbox file: %@", deleteError);
            }
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [AppDelegate clearTemporaryDirectory];
}
                    
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

+ (void)clearTemporaryDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtURL:[NSURL fileURLWithPath:NSTemporaryDirectory()]
                                                   includingPropertiesForKeys:@[NSURLIsDirectoryKey]
                                                                      options:0
                                                                 errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                     NSLog(@"Error enumerating url: %@", url);
                                                                     return YES;
                                                                 }];

    for (NSURL *url in directoryEnumerator) {
        [fileManager removeItemAtURL:url error:nil];
    }
}

@end
