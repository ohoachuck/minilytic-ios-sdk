//
//  MLYUser.m
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "MLYUser.h"

@implementation MLYUser

+ (MLYUser *)defaultUser {
    static dispatch_once_t onceToken;
    static MLYUser *defaultUser = nil;
    dispatch_once(&onceToken, ^{
        defaultUser = [[MLYUser alloc] init];
    });
    return defaultUser;
}

- (id)init
{
    self = [super init];
    if (self){
        // Get the UDID key
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *udidString = [defaults objectForKey:@"com.minilytic.udid"];
        if (!udidString){
            CFUUIDRef identifierObject = CFUUIDCreate(kCFAllocatorDefault);
            udidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault,identifierObject);
            [defaults setObject:udidString forKey:@"com.minilytic.udid"];
            [defaults synchronize];
            CFRelease((CFTypeRef) identifierObject);
        }
        _identifier = udidString;
    }
    return self;
}





@end
