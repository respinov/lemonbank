//
//  main.m
//  LemonBank
//
//  Created by Nick Blievers on 6/02/2015.
//  Copyright (c) 2015 threatmetrix. All rights reserved.
//

#if defined(__has_feature) && __has_feature(modules)
@import UIKit;
#else
#import <UIKit/UIKit.h>
#endif

#import "LBAppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([LBAppDelegate class]));
    }
}
