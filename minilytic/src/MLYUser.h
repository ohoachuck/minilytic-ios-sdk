//
//  MLYUser.h
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implements the singleton user `MLYUser`.

This class is internal, uses `MLYTrcaker`instead.
 
This class represents the unique user of your application. It mains purpose is to create/register an UDID for the user. This UDID is stored under `NSUserDefaults, in "com.minilytic.udid" key.

*/
 
@interface MLYUser : NSObject

+ (MLYUser *)defaultUser;

@property(readonly) NSString *identifier;


@end
