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
    
    self.window.tintColor = [Theme redColor];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{kStandardTextSizeKey: @20}];
    
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsURLKey]) {
//        [self handoffImportFile:(NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey]];
//    }
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
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
