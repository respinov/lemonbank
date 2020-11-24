//
//  LBProfileController.h
//  LemonBank
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//
#if defined(__has_feature) && __has_feature(modules)
@import TMXProfiling;
@import TMXProfilingConnections;
@import Foundation;
#else
#import <TMXProfiling/TMXProfiling.h>
#import <TMXProfilingConnections/TMXProfilingConnections.h>
#import <Foundation/Foundation.h>
#endif

/// This object handles setting up and calling the profiling function
@interface LBProfileController : NSObject

/// Session id used in profiling, this can be created by ThreatMetrix SDK or passed to
/// profiling request. NOTE: session id must be unique otherwise the result of API call will
/// be unexpected.
@property (readonly, nonatomic) NSString *sessionID;

/// Indicate if the login can proceed or if it needs to wait for the profiling to complete
@property (readwrite)BOOL loginOkay;

/// This timeout is used to set the maximum time for the entire profiling from start to the time the callback block method returns a result
@property(readonly) NSNumber *profileTimeout;

/// Configures ThreatMetrix SDK to make sure profiling can start when application starts.
- (instancetype)init;

/// Starts profiling process and sets a flag when profiling is finished.
- (void)doProfile;
@end
