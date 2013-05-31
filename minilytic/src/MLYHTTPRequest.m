//
//  MLYHTTPRequest.m
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "MLYHTTPRequest.h"



@interface MLYHTTPRequest ( )

@property(nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property(nonatomic,strong) NSMutableURLRequest *request;
@property(nonatomic,strong) NSURLConnection *connection;

@end


@implementation MLYHTTPRequest

#pragma mark - Entry point

- (id)init
{
    self = [super init];
    if (self){
        _usingLocalhost = NO;
        _request = [self requestWithURLString:@"http://minilytic.com/api/v1/hits/"];
    }
    return self;
}

- (NSMutableURLRequest *)requestWithURLString:(NSString*)urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [request setValue:@"text/json" forHTTPHeaderField:@"Content-Type"];
    return request;
}


- (void)setUsingLocalhost:(BOOL)usingLocalhost
{
    _usingLocalhost = usingLocalhost;
    self.request = self.isUsingLocalhost ?
        [self requestWithURLString:@"http://localhost:8000/api/v1/hits/"] :
        [self requestWithURLString:@"http://minilytic.com/api/v1/hits/"];
}

- (void)main
{
    @autoreleasepool {
        [self start];
    }
}

- (void) start
{
    self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.backgroundTaskId != UIBackgroundTaskInvalid){
                [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
                self.backgroundTaskId = UIBackgroundTaskInvalid;
                [self cancel];
            }
        });
    }];
    
    if(!self.isCancelled) {
        [self.request setHTTPBody:self.body];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.connection = [[NSURLConnection alloc] initWithRequest:self.request
                                                              delegate:self
                                                      startImmediately:NO];
            
            [self.connection scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                       forMode:NSRunLoopCommonModes];
            
            [self.connection start];
        });
    }
    else {
        [self endBackgroundTask];
    }
}


- (void)endBackgroundTask
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
            self.backgroundTaskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)cancel
{
    if([self isFinished])
        return;
    
    @synchronized(self) {
        //self.isCancelled = YES;
        [self.connection cancel];
        [self endBackgroundTask];
    }
    [super cancel];
}

#pragma mark -
#pragma mark NSURLConnection delegates

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.body = nil;
    [self endBackgroundTask];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    self.body = nil;
    [self endBackgroundTask];
}








@end
