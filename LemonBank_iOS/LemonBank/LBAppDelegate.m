//
//  AppDelegate.m
//  LemonBank
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//

#import "LBAppDelegate.h"
#import "LBViewController.h"

@implementation LBAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.viewController = [storyboard instantiateInitialViewController];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    // Request permission to access device location, this is required for using ThreatMetrix location services
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestWhenInUseAuthorization];

    //Using push services requires the end user's permission, requesting registration without the permission can cause rejection from the App Store, to avoid that the we have to ask for permission
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
        if (granted)
        {
            dispatch_sync(dispatch_get_main_queue(), ^
                          {
                [application registerForRemoteNotifications];
            });
        }
    }];


    // Apple push token is propagated when register for push is finished (in application:didRegisterForRemoteNotificationsWithDeviceToken: method)
    // once APN is received it should be sent to fingerprint server (via profiling call) to be able to receive notification from Strong Authentication
    // Please note that at least one profiling call is required when 1. application is installed for the first time and 2. also when APN token is changed
    [self.viewController.td doProfile];
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
// the deviceToken can be used to test pushing notification to the device
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Registered for notification device token is: %@", deviceToken);
    if([self isPushTokenChanged:deviceToken])
    {
        self.viewController.isApnTokenChanged = YES;
    }
}

// Sent to the delegate when Apple Push Notification service cannot successfully complete the registration process.
// In this case Strong Authentication will fail
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    // The token is not currently available.
    NSLog(@"Remote notification support is unavailable due to error (in app): %@", err);
}

// Tells the app that a remote notification arrived that indicates there is data to be fetched.
// This method is called when the app is foreground and background
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    completionHandler(UIBackgroundFetchResultNewData);
}

/*!
 * This method makes sure that APN token received on this app launch matches the previous one.
 *
 * @return YES if the push token received on this application launch is different than what is saved before
 */
-(BOOL) isPushTokenChanged:(NSData *) apnToken
{
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] init];
    NSData *storedToken  = [userDefaults dataForKey:@"lemonbank.apn.token"];

    if(!storedToken || ![storedToken isEqualToData:apnToken])
    {
        //Save the new APN token
        [userDefaults setObject:apnToken forKey:@"lemonbank.apn.token"];
        return YES;
    }

    return NO;
}

#pragma mark UNUserNotificationCenterDelegate

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
// Called when a notification is delivered to a foreground app. iOS 10+
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    //App was on foreground when notification is received, so there is no need to show an alert to user
    completionHandler(UNNotificationPresentationOptionNone);
}
#endif

@end
