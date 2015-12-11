//
//  AppDelegate.m
//  SaveSnap
//
//  Created by heliumsoft on 12/24/14.
//  Copyright (c) 2014 quantum. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [AppSettings defineUserDefaults];
    [MKStoreManager sharedManager];

    [[UINavigationBar appearance]setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
//    if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
//        // Init the singleton
//        [LTHPasscodeViewController sharedUser];
//        if ([LTHPasscodeViewController didPasscodeTimerEnd])
//            [[LTHPasscodeViewController sharedUser] showLockscreen];
//    }
    
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)applicationWillResignActive:(UIApplication *)application {
    if ([LTHPasscodeViewController passcodeExistsInKeychain]) {
        [LTHPasscodeViewController saveTimerStartTime];
        if ([LTHPasscodeViewController timerDuration] == 0)
            [[LTHPasscodeViewController sharedUser] showLockscreen];
    }
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    if ([LTHPasscodeViewController passcodeExistsInKeychain] && [LTHPasscodeViewController didPasscodeTimerEnd]) {
        [[LTHPasscodeViewController sharedUser] showLockscreen];
    }
}
@end