//
//  MLYHTTPRequest.m
//  weblytic iOS SDK
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
        NSURL *url = [NSURL URLWithString:@"http://minilytic.com/api/v1/hits/"];
        _request = [NSMutableURLRequest requestWithURL:url];
        [_request setHTTPMethod:@"POST"];
    }
    return self;
}

- (void)setUsingLocalhost:(BOOL)usingLocalhost
{
    _usingLocalhost = usingLocalhost;
    NSURL *url = self.isUsingLocalhost ?
        [NSURL URLWithString:@"http://localhost:8000/api/v1/hits/"] :
        [NSURL URLWithString:@"http://minilytic.com/api/v1/hits/"];
    self.request = [NSMutableURLRequest requestWithURL:url];
    [self.request setHTTPMethod:@"POST"];

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
