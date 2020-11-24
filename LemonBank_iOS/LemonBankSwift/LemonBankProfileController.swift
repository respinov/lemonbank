//
//  ModelController.swift
//  LemonBankSwift
//
//  Copyright © 2020 ThreatMetrix. All rights reserved.
//

import UIKit
import TMXProfiling
import TMXProfilingConnections

class LemonBankProfileController: NSObject
{
    var profile       : TMXProfiling!
    var loginOkay                    = false
    var profileTimeout: TimeInterval = 20
    var sessionID                    = ""
    let useTMXProfilingConnections   = true

    override init()
    {
        super.init()

        let connectionInstance : TMXProfilingConnectionsProtocol
        if useTMXProfilingConnections == true
        {
            /*
             * Optionally you can configure TMXProfilingConnections, if so please pass the configured
             * instance to configure method. On the other hand, if you prefer to use TMXProfilingConnection
             * default settings, there is no need to create an instance of it.
             * */
            let profilingConnections : TMXProfilingConnections = TMXProfilingConnections.init()
            profilingConnections.connectionTimeout    = 20 // Default value is 10 seconds
            profilingConnections.connectionRetryCount = 2  // Default value is 0 (no retry)
            connectionInstance = profilingConnections
        }
        else
        {
            /*
             * If you decide to implement TMXProfilingConnectionsProtocol you should create an instance of your
             * implementation and pass it to configure method.
             */
            connectionInstance = LemonBankProfilingConnections.init()
        }



        //Get a singleton instance of TrustDefenderMobile
        profile = TMXProfiling.sharedInstance()

        // The profile.configure method is effective only once and subsequent calls to it will be ignored.
        // Please note that configure may throw NSException if NSDictionary key/value(s) are invalid.
        // This only happen due to programming error, therefore we don't catch the exception to make sure there is no error in our configuration dictionary
        profile.configure(configData:[
                            // (REQUIRED) Organisation ID
                            TMXOrgID              :"45ssiuz3",
                            // (REQUIRED) Enhanced fingerprint server
                            TMXFingerprintServer  :"h.online-metrix.net",
                            // (OPTIONAL) Set the profile timeout, in seconds
                            TMXProfileTimeout     : profileTimeout,
                            // (OPTIONAL) If Keychain Access sharing groups are used, specify like this
                            TMXKeychainAccessGroup: "<TEAM_ID>.<BUNDLE_ID>",
                            // (OPTIONAL) Register for location service updates.
                            // Requires permission to access device location
                            TMXLocationServices   : true,
                            // (OPTIONAL) Pass the configured instance of TMXProfilingConnections to TMX SDK.
                            // If not passed, configure method tries to create and instance of TMXProfilingConnections
                            // with the default settings.
                            TMXProfilingConnectionsInstance:connectionInstance,
                            ])
    }

    func doProfile()
    {
        let customAttributes : [String : Array<String>] = [TMXCustomAttributes: ["attribute 1", "attribute 2"]]

        loginOkay = false

        // Fire off the profiling request.
        let profileHandle: TMXProfileHandle = profile.profileDevice(profileOptions:customAttributes, callbackBlock:{(result: [AnyHashable : Any]?) -> Void in

                let results:NSDictionary! = result! as NSDictionary
                let status:TMXStatusCode  = TMXStatusCode(rawValue:(results.value(forKey: TMXProfileStatus) as! NSNumber).intValue)!

                self.sessionID = results.value(forKey: TMXSessionID) as! String
                if(status == .ok)
                {
                    // No errors, profiling succeeded!
                }

            let statusString: String =
                status == .ok                  ? "OK"                   :
                status == .networkTimeoutError ? "Timed out"            :
                status == .connectionError     ? "Connection Error"     :
                status == .hostNotFoundError   ? "Host Not Found Error" :
                status == .internalError       ? "Internal Error"       :
                status == .interruptedError    ? "Interrupted Error"    :
                "Other"
                print("Profile completed with: \(statusString) and session ID: \(self.sessionID)")
                self.loginOkay = true
        })

        // Session id can be collected here (to use in API call (AKA session query))
        self.sessionID = profileHandle.sessionID;
        print("Session id is \(self.sessionID)");

        /*
         * profileHandle can also be used to cancel this profile if needed
         *
         * profileHandle.cancel()
         * */
    }
}

