//
//  WLYDevice.h
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WLYDevice : NSObject

+ (WLYDevice *)defaultDevice;

- (NSString *)platform;
- (NSString *)hardwareModel;
- (NSString *)systemVersion;
- (NSString *)systemName;


@end
