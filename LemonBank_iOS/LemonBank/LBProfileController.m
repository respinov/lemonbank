//
//  LBProfileController.m
//  LemonBank
//
//  Copyright (c) 2020 ThreatMetrix. All rights reserved.
//

#import "LBProfileController.h"
#import "LBProfilingConnections.h"

@interface LBProfileController()
@property(readwrite, nonatomic) NSString* sessionID;
@end

NSString *const ORG_ID    = @"invalid";
NSString *const FP_SERVER = @"enhanced-fp-server";
BOOL useTMXProfilingConnections = YES;

@implementation LBProfileController

- (instancetype) init
{
    self = [super init];

    _sessionID         = nil;
    _profileTimeout    = @20;

    id connectionInstance;
    if(useTMXProfilingConnections)
    {
        /*
         * Optionally you can configure TMXProfilingConnections, if so please pass the configured
         * instance to configure method. On the other hand, if you prefer to use TMXProfilingConnection
         * default settings, there is no need to create an instance of it.
         * */
        TMXProfilingConnections *profilingConnections = [[TMXProfilingConnections alloc] init];
        profilingConnections.connectionTimeout    = 20; // Default value is 10 seconds
        profilingConnections.connectionRetryCount = 2;  // Default value is 0 (no retry)
        connectionInstance = profilingConnections;
    }
    else
    {
        /*
         * If you decide to implement TMXProfilingConnectionsProtocol you should create an instance of your
         * implementation and pass it to configure method.
         */
        connectionInstance = [[LBProfilingConnections alloc] init];
    }

    // The profile.configure method is effective only once and subsequent calls to it will be ignored.
    // Please note that configure may throw NSException if NSDictionary key/value(s) are invalid.
    // This only happen due to programming error, therefore we don't catch the exception to make sure there is no error in our configuration dictionary
    [[TMXProfiling sharedInstance] configure:@{
                                               // (REQUIRED) Organisation ID
                                               TMXOrgID              : ORG_ID,
                                               // (REQUIRED) Enhanced fingerprint server
                                               TMXFingerprintServer  : FP_SERVER,
                                               // (OPTIONAL) Set the profile timeout, in seconds
                                               TMXProfileTimeout     : _profileTimeout,
                                               // (OPTIONAL) If Keychain Access sharing groups are used, specify it
                                               TMXKeychainAccessGroup: @"<TEAM_ID>.<BUNDLE_ID>",
                                               // (OPTIONAL) Register for location service updates.
                                               // Requires permission to access to device location.
                                               TMXLocationServices   : @YES,
                                               // (OPTIONAL) Pass the configured instance of TMXProfilingConnections to TMX SDK.
                                               // If not passed, configure method tries to create and instance of TMXProfilingConnections
                                               // with the default settings.
                                               TMXProfilingConnectionsInstance : connectionInstance,
    }];
    return self;
}

-(void)doProfile
{
    // (OPTIONAL) Assign some custom attributes to be included with the profiling information
    NSArray *customAttributes = @[@"attribute 1", @"attribute 2"];

    self.loginOkay = NO;

    // Fire off the profiling request.
    TMXProfileHandle *profileHandle = [[TMXProfiling sharedInstance] profileDeviceUsing:@{TMXCustomAttributes : customAttributes}
                                                                          callbackBlock:^(NSDictionary * _Nullable result) {
        TMXStatusCode statusCode = [[result valueForKey:TMXProfileStatus] integerValue];
        // If we registered a delegate, this function will be called once the profiling is complete
        if(statusCode == TMXStatusCodeOk)
        {
            // No errors, profiling succeeded!
        }
        NSLog(@"Profile completed with: %s and session ID: %@", statusCode == TMXStatusCodeOk ? "OK"
              : statusCode == TMXStatusCodeNetworkTimeoutError ? "Timed out"
              : statusCode == TMXStatusCodeConnectionError     ? "Connection Error"
              : statusCode == TMXStatusCodeHostNotFoundError   ? "Host not found error"
              : statusCode == TMXStatusCodeInternalError       ? "Internal Error"
              : statusCode == TMXStatusCodeInterruptedError    ? "Interrupted"
              : "other",
              [result valueForKey:TMXSessionID]);
        [self setLoginOkay:YES];
    }];

    // Session id can be collected here (to use in API call (AKA session query))
    self.sessionID = profileHandle.sessionID;
    NSLog(@"Session id is %@", self.sessionID);

    /*
     * profileHandle can also be used to cancel this profile if needed
     *
     * [profileHandle cancel];
     * */
}

@end

