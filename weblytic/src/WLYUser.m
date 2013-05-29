//
//  WLYUser.m
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "WLYUser.h"

@implementation WLYUser

+ (WLYUser *)defaultUser {
    static dispatch_once_t onceToken;
    static WLYUser *defaultUser = nil;
    dispatch_once(&onceToken, ^{
        defaultUser = [[WLYUser alloc] init];
    });
    return defaultUser;
}

- (id)init
{
    self = [super init];
    if (self){
        // Get the udid key
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *udidString = [defaults objectForKey:@"com.weblytic.udid"];
        if (!udidString){
            CFUUIDRef identifierObject = CFUUIDCreate(kCFAllocatorDefault);
            udidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault,identifierObject);
            [defaults setObject:udidString forKey:@"com.weblytic.udid"];
            [defaults synchronize];
            CFRelease((CFTypeRef) identifierObject);
        }
        _identifier = udidString;
    }
    return self;
}





@end
