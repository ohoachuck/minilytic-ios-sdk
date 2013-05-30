//
//  WLYHTTPRequest.m
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "WLYHTTPRequest.h"



@interface WLYHTTPRequest ( )

@property(nonatomic,assign) UIBackgroundTaskIdentifier backgroundTaskId;
@property(nonatomic,strong) NSMutableURLRequest *request;
@property(nonatomic,strong) NSURLConnection *connection;
@property(nonatomic,assign) WLYHTTPRequestState state;


@end


@implementation WLYHTTPRequest

#pragma mark - Entry point

- (id)init
{
    self = [super init];
    if (self){
        NSURL *url = [NSURL URLWithString:@"http://weblytic.com/api/v1/hits/"];
        _request = [NSMutableURLRequest requestWithURL:url];
        [_request setHTTPMethod:@"POST"];
        _state = WLYHTTPRequestStateReady;
    }
    return self;
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
        self.state = WLYHTTPRequestStateExecuting;
    }
    else {
        self.state =WLYHTTPRequestStateStateFinished;
        [self endBackgroundTask];
    }
}

#pragma - mark NSOperation stuff

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isReady {
    
    return (self.state == WLYHTTPRequestStateReady && [super isReady]);
}


- (BOOL)isFinished
{
    return (self.state == WLYHTTPRequestStateStateFinished);
}

- (BOOL)isExecuting {
    
    return (self.state == WLYHTTPRequestStateExecuting);
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
        if(self.state == WLYHTTPRequestStateExecuting){
            self.state = WLYHTTPRequestStateStateFinished;
        }
        [self endBackgroundTask];
    }
    [super cancel];
}

#pragma mark -
#pragma mark NSURLConnection delegates

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
