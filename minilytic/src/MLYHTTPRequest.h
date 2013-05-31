//
//  MLYHTTPRequest.h
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MLYHTTPRequest : NSOperation <NSURLConnectionDataDelegate>

@property(nonatomic,strong) NSData *body;
@property(nonatomic,assign,getter=isUsingLocalhost) BOOL usingLocalhost;

@end


