//
//  AppDelegate.h
//  LemonBank
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//

#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
@import Foundation;
@import CoreLocation;
#else
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#endif

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
#if defined(__has_feature) && __has_feature(modules)
@import UserNotifications;
#else
#import <UserNotifications/UserNotifications.h>
#endif
#endif

@class LBViewController;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
@interface LBAppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
#else
@interface LBAppDelegate : UIResponder <UIApplicationDelegate>
#endif


@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readwrite) LBViewController *viewController;

/// Used to request accessing location while application is in used
@property (readwrite, nonatomic) CLLocationManager *locationManager;
@end

