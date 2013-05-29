//
//  WLYDevice.m
//  weblytic iOS SDK
//
//  Created by Jean-Christophe Amiel on 5/27/13.
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "WLYDevice.h"
#include <sys/sysctl.h>

@implementation WLYDevice

+ (WLYDevice *)defaultDevice {
    static dispatch_once_t onceToken;
    static WLYDevice *device = nil;
    dispatch_once(&onceToken, ^{
        device = [[WLYDevice alloc] init];
    });
    return device;
}

- (id)init
{
    self = [super init];
    if (self){
        
    }
    return self;
}

- (NSString *)sysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    
    NSString *results = [NSString stringWithCString:answer encoding: NSUTF8StringEncoding];
    
    free(answer);
    return results;
}

- (NSString *)platform
{
    return [self sysInfoByName:"hw.machine"];
}


- (NSString *)hardwareModel
{
    return [self sysInfoByName:"hw.model"];
}

- (NSString *)systemVersion
{
    return [UIDevice currentDevice].systemVersion;
}

- (NSString *)systemName
{
    return [UIDevice currentDevice].systemName;
}





@end
