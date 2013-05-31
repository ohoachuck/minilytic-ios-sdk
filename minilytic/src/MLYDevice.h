//
//  MLYDevice.h
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MLYDevice : NSObject

+ (MLYDevice *)defaultDevice;

- (NSString *)platform;
- (NSString *)hardwareModel;
- (NSString *)systemVersion;
- (NSString *)systemName;


@end
