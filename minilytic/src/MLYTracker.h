//
//  MLYTracker.h
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import <Foundation/Foundation.h>


/** Implements the singleton tracker `MLYTracker`.
 
This class is your unique entry point to send tracking event. You do not need to know any other classes. Really.

You simply track an event like this:
 
	MLYTracker *tracker = [MLYTracker defaultTracker];
	[tracker trackEvent:@"tab1.buttonOk"];
 
Tracking an event is just recording a lightweight instance of this event in memory. At this point, there is no network connection involved. You are the responsible for sending all event to the server, by using `sendTrackedItems` on the singleton tracker. Tracked event are then sent in bulk, with a compressed gzip payload. A typical implementation is to send tracked items when the app goes in background (i.e. in `applicationDidEnterBackground:` and `applicationWillTerminate:`).

To track session, you must track "app.foreground" event in `application:didFinishLaunchingWithOptions:` and in `applicationWillEnterForeground:` in your app delegate:
 
	MLYTracker *tracker = [MLYTracker defaultTracker];
	[tracker trackEvent:@"app.foreground"];
 
You must also send the event "app.background" in `applicationDidEnterBackground:` and in `applicationWillTerminate:` in your app delegate. These selectors are also the best place to send tracked items, so a typical implementation of `applicationDidEnterBackground:` is:
 
	- (void)applicationDidEnterBackground:(UIApplication *)application
	{
		[[MLYTracker defaultTracker] trackEvent:@"app.background"];
		[[MLYTracker defaultTracker] sendTrackedItems];
	}

You must also provide your account username and the app identifier of your app. You can initilialize this value in `application:didFinishLaunchingWithOptions:` like this:
 
	(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
	{
		self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		...
		self.window.rootViewController = self.tabBarController;
		[self.window makeKeyAndVisible];

		// Initilialize our tracker
		MLYTracker* tracker = [MLYTracker defaultTracker];
		tracker.account = @"bob@gmail.com";
		tracker.identifier = @"1";

		[tracker trackEvent:@"app.foreground"];
	
		return YES;
	}

*/

@interface MLYTracker : NSObject

///---------------------------------------------------------------------------------------
/// @name Initialization & disposal
///---------------------------------------------------------------------------------------
 
/** Returns the singleton instance of the tracker. */

+ (MLYTracker*)defaultTracker;

/** Specifies the identifier of your weblytic account */
@property(copy) NSString *account;

/** Specifies the identifier of your app */
@property(copy) NSString *identifier;

///---------------------------------------------------------------------------------------
/// @name Tracking items
///---------------------------------------------------------------------------------------

/** Tracks a named event. Tracked event are added to a memory queue and send on demand with `sendTrackedItems:`
 
@param eventName Name of the event to track.
@see trackPage:
@see trackPage:customMetrics:
@see sendTrackedItems
*/
- (void)trackEvent:(NSString* )eventName;


/** Tracks a named page. Tracked page are added to a memory queue and send on demand with `sendTrackedItems:`
 
@param pageName Name of the page to track.
@see trackEvent:
@see trackPage:customMetrics:
@see sendTrackedItems
*/
- (void)trackPage:(NSString *)pageName;


/** Tracks a named page with a custom metrics. Tracked page are added to a memory queue and send on demand with `sendTrackedItems`
 
@param pageName Name of the page to track.
@param dic Dictionary of key/value for a custom metrics.
@see trackEvent:
@see trackPage:customMetrics:
@see sendTrackedItems
*/

- (void)trackPage:(NSString *)pageName customMetrics:(NSDictionary *)dic;

///---------------------------------------------------------------------------------------
/// @name Sending tracked items
///---------------------------------------------------------------------------------------

/** Send tracked items on the network and flush the in-memory tracked items queue.

@see trackEvent:
@see trackPage:customMetrics:
@see trackPage:customMetrics:
@see sendTrackedItems
*/

- (void)sendTrackedItems;



@end
