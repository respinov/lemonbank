//
//  LemonBankProfilingConnections.swift
//  LemonBankSwift
//
//  Created by Samin Pour on 29/4/20.
//  Copyright © 2020 ThreatMetrix. All rights reserved.
//

import Foundation

class LemonBankProfilingConnections: NSObject, TMXProfilingConnectionsProtocol
{
    var urlSession : URLSession!
    let timeoutSec : TimeInterval = 20

    override init()
    {
        super.init()

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest  = timeoutSec;
        config.timeoutIntervalForResource = timeoutSec;

        let delegateQueue = OperationQueue.init()
        delegateQueue.maxConcurrentOperationCount = 1
        delegateQueue.name = "com.threatmetrix.lemonbank.connectionqueue"

        urlSession = URLSession.init(configuration:config, delegate:nil, delegateQueue:delegateQueue)
    }

    deinit
    {
        urlSession.finishTasksAndInvalidate()
    }

// MARK: TMXProfilingConnectionsProtocol methods

    func httpProfilingRequest(url:URL, method:TMXProfilingConnectionMethod, headers:[AnyHashable : Any]?, postData:Data?, completionHandler:((Data?, Error?) -> Void)? = nil)
    {
        var request = URLRequest.init(url:url, cachePolicy:URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval:timeoutSec)
        request.httpMethod = (method == TMXProfilingConnectionMethod.post) ? "POST" : "GET"
        request.httpBody   = postData
        request.httpShouldHandleCookies = false
        if let headers = headers, ((headers as? [String : String]) != nil)
        {
            request.allHTTPHeaderFields = (headers as! [String : String])
        }

        let task : URLSessionTask = urlSession.dataTask(with:request) { (data, response, error) in

            if let completionHandler = completionHandler
            {
                completionHandler(data, error)
            }
            else
            {
                // Should not happen but it is good to have an indication
                print("completionHandler is nil")
            }
        }

        task.resume()
    }

    func cancelProfiling()
    {
        urlSession.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            if dataTasks.count > 0
            {
                for dataTask in dataTasks
                {
                    if dataTask.state == URLSessionTask.State.running
                    {
                        dataTask.cancel()
                    }
                }
            }
        }
    }

    func resolveProfilingHostName(host: String)
    {
        let hostRef : CFHost = CFHostCreateWithName(kCFAllocatorDefault, host as CFString).takeRetainedValue()
        CFHostStartInfoResolution(hostRef, CFHostInfoType.addresses, nil)
    }

    func socketProfilingRequest(host: String, port: Int32, data: Data)
    {
        let task = urlSession.streamTask(withHostName:host, port:Int(port))
        task.resume()

        task.write(data, timeout:timeoutSec) {
            error in

            if let error = error
            {
                let code = (error as NSError).code
                print("Stream write failure: \(code)")
            }

            task.closeWrite()
            task.closeRead()
        }
    }
}
