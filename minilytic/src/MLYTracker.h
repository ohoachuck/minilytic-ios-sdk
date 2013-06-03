//
//  MLYTracker.h
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


/** Implements the singleton tracker `MLYTracker`.
 
This class is your unique entry point to send tracking event. You do not need to know any other classes. Really.

You simply track an event like this:
 
	MLYTracker *tracker = [MLYTracker defaultTracker];
	[tracker trackEvent:@"tab1.buttonOk"];
 
Tracking an event is just recording a lightweight instance of this event in memory. At this point, there is no network connection involved. When your app goes into background, all tracked event are sent to the server, in a gzip compressed payload. You do not need to sent the  events manually, as the singleton tracker registers to some notifications.

When first initialized, the singleton tracker will register to the following notifications:
 
1. `UIApplicationWillEnterForegroundNotification` will generate an "app.foreground" event
2. `UIApplicationDidEnterBackgroundNotification` will generate an "app.background" event and will send tracked items over the network
3. `UIApplicationDidFinishLaunchingNotification` will generate an "app.foreground" event
4. `UIApplicationWillTerminateNotification` will generate an "app.background" event and will send tracked items over the network
 

You must provide your minilytic account key and the app identifier of your app. You can initilialize this value in `application:didFinishLaunchingWithOptions:` like this:
 
	(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		...
		self.window.rootViewController = self.tabBarController;
		[self.window makeKeyAndVisible];

		// Initilialize our tracker
		MLYTracker* tracker = [MLYTracker defaultTracker];
		tracker.accountKey = @"PV6IES01";
		tracker.appIdentifier = @"1";

		[tracker trackEvent:@"app.foreground"];
	
		return YES;
	}
 
You can use "PV6IES01" as a public account key for testing purposes.

*/

@interface MLYTracker : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------
 
/** Returns the singleton instance of the tracker. */

+ (MLYTracker*)defaultTracker;

/** Specifies the identifier of your minilytic account */
@property(copy) NSString *accountKey;

/** Specifies the identifier of your app */
@property(copy) NSString *appIdentifier;

///---------------------------------------------------------------------------------------
/// @name Tracking items
///---------------------------------------------------------------------------------------

/** Tracks a named event. Tracked event are added to a memory queue and end when application goes into background.
 
@param eventName Name of the event to track.
@see trackPage:
@see trackPage:customMetrics:
*/
- (void)trackEvent:(NSString* )eventName;


/** Tracks a named page. Tracked page are added to a memory queue and send when application goes into background.
 
@param pageName Name of the page to track.
@see trackEvent:
@see trackPage:customMetrics:
*/
- (void)trackPage:(NSString *)pageName;


/** Tracks a named page with a custom metrics. Tracked page are added to a memory queue and send when application goes into background.
 
@param pageName Name of the page to track.
@param dic Dictionary of key/value for a custom metrics.
@see trackEvent:
@see trackPage:customMetrics:
*/

- (void)trackPage:(NSString *)pageName customMetrics:(NSDictionary *)dic;




@end
