//
//  WLYUser.h
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Implements the singleton user `WLYUser`.

This class is internal, uses `WLYTrcaker`instead.
 
This class represents the unique user of your application. It mains purpose is to create/register an UDID for the user. This UDID is stored under `NSUserDefaults, in "com.weblytic.udid" key.

*/
 
@interface WLYUser : NSObject

+ (WLYUser *)defaultUser;

@property(readonly) NSString *identifier;


@end
