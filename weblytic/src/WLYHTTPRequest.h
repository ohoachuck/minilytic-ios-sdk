//
//  WLYHTTPRequest.h
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    WLYHTTPRequestStateReady = 1,
    WLYHTTPRequestStateExecuting = 2,
    WLYHTTPRequestStateStateFinished = 3
} WLYHTTPRequestState;

@interface WLYHTTPRequest : NSOperation <NSURLConnectionDataDelegate>

@property(nonatomic,strong) NSData *body;
@property(nonatomic,readonly) WLYHTTPRequestState state;

@end


