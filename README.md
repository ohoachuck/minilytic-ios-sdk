<p align="center" >
<img src="https://github.com/manbolo/minilytic-ios-sdk/blob/master/minilytic/logo.png" alt="minilytic" title="minilytic">
</p>


minilytic iOS SDK
================

Mini footprint app analytics

This open-source library allows you to integrate minilytic analytics SDK into your iOS app.

The `MLYTracker` is your unique entry point to send tracking event. You do not need to know any other classes. Really.

You simply track an event like this:
 
```objectice-c
MLYTracker *tracker = [MLYTracker defaultTracker];
[tracker trackEvent:@"tab1.buttonOk"];
```

Tracking an event is just recording a lightweight instance of this event in memory. At this point, there is no network connection involved. When your app goes into background, all tracked event are sent to the server, in a gzip compressed payload. You do not need to sent the  events manually, as the singleton tracker registers to some notifications.

When first initialized, the singleton tracker will register to the following notifications:
 
1. `UIApplicationWillEnterForegroundNotification` will generate an "app.foreground" event
2. `UIApplicationDidEnterBackgroundNotification` will generate an "app.background" event and will send tracked items over the network
3. `UIApplicationDidFinishLaunchingNotification` will generate an "app.foreground" event
4. `UIApplicationWillTerminateNotification` will generate an "app.background" event and will send tracked items over the network

You must provide your minilytic account key and the app identifier of your app. You can initilialize this value in `application:didFinishLaunchingWithOptions:` like this:
 
```objectice-c
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

    return YES;
}
```

You can use "PV6IES01" as a public account key for testing purposes.

TRY IT OUT

1. Test your install; build and run the project at ~/Documents/minilytic-ios-sdk/Sample/Sample.xcodeproj
2. There is no step 2.

## Requirements

### libz

### ARC

## License

minilytic iOS SDK is available under the DWYW license. See the LICENSE file for more info.