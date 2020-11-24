//
//  LBProfilingConnections.m
//  LemonBank
//
//  Copyright © 2020 ThreatMetrix. All rights reserved.
//

#import "LBProfilingConnections.h"

@interface LBProfilingConnections()
@property(nonatomic, readwrite) NSURLSession *urlSession;
@property(nonatomic, readwrite) NSTimeInterval timeoutSec;
@end

@implementation LBProfilingConnections

- (instancetype)init
{
    self = [super init];
    if(self)
    {
        _timeoutSec = 20;

        // In this implementation we use NSURLSession to manage connections
        // set session timeouts
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.timeoutIntervalForRequest  = _timeoutSec;
        config.timeoutIntervalForResource = _timeoutSec;

        // creating a dedicated queue for connection to avoid using main queue (and slowing down the UI actions)
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        delegateQueue.maxConcurrentOperationCount = 1;
        [delegateQueue setName:@"com.threatmetrix.lemonbank.connectionqueue"];

        // creating one NSURLSession object for all connections
        _urlSession  = [NSURLSession sessionWithConfiguration:config delegate:nil delegateQueue:delegateQueue];
    }
    return self;
}

- (void)dealloc
{
    [self.urlSession finishTasksAndInvalidate];
}

#pragma mark TMXProfilingConnections methods

- (void)httpProfilingRequestWithUrl:(NSURL * _Nonnull)url method:(TMXProfilingConnectionMethod)method headers:(NSDictionary * _Nullable)headers postBody:(NSData * _Nullable)postData completionHandler:(void (^ _Nullable)(NSData * _Nullable, NSError * _Nullable))completionHandler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutSec];
    [request setHTTPMethod:(method == TMXProfilingConnectionMethodPost) ? @"POST" : @"GET"];
    [request setHTTPBody:postData];
    [request setHTTPShouldHandleCookies:NO];
    if([headers count] > 0)
    {
        //add headers
        [request setAllHTTPHeaderFields:headers];
    }

    NSURLSessionTask *task = [self.urlSession dataTaskWithRequest:request  completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable __unused response, NSError * _Nullable error) {
        completionHandler(data, error);
    }];
    [task resume];
}

- (void)cancelProfiling
{
    [self.urlSession getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * __unused _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * __unused _Nonnull downloadTasks) {
        if(dataTasks.count > 0)
        {
            for(NSURLSessionDataTask *task in dataTasks)
            {
                if(task.state == NSURLSessionTaskStateRunning)
                {
                    [task cancel];
                }
            }
        }
    }];
}

- (void)resolveProfilingHostName:(NSString * _Nonnull)host
{
    @try
    {
        CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)host);
        if (hostRef)
        {
            CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
            /* ignore return, we don't care about the actual address returned */
            CFRelease(hostRef);
        }
    }
    @catch(NSException *runtimeEx)
    {
        NSLog(@"Host resolution failure: %@", runtimeEx.reason);
    }
}

- (void)socketProfilingRequestWithHost:(NSString *)host port:(int)port data:(NSData *)data
{
    __block NSURLSessionStreamTask *task = [self.urlSession streamTaskWithHostName:host port:port];
    [task resume];

    [task writeData:data timeout:self.timeoutSec completionHandler:^(NSError * _Nullable error) {
        if(error)
        {
            NSLog(@"Stream write failure: %ld", (long)error.code);
        }

        [task closeWrite];
        [task closeRead];
    }];
}

@end
