weblytic iOS SDK
================

Analytics for the anti-analytics

This open-source library allows you to integrate weblytic analytics SDK into your iOS app.

You simply track an event like this:
 
```objectice-c
WLYTracker *tracker = [WLYTracker defaultTracker];
[tracker trackEvent:@"tab1.buttonOk"];
```

Tracking an event is just recording a lightweight instance of this event in memory. At this point, there is no network connection involved. You are the responsible for sending all event to the server, by using `sendTrackedItems` on the singleton tracker. Tracked event are then sent in bulk, with a compressed gzip payload. A typical implementation is to send tracked items when the app goes in background (i.e. in `applicationDidEnterBackground:` and `applicationWillTerminate:`).

TRY IT OUT

1. Test your install; build and run the project at ~/Documents/weblytic-ios-sdk/Sample/Sample.xcodeproj
2. There is no step 2.

## Requirements

### libz

### ARC

## License

weblytic iOS SDK is available under the [WTFPL license](http://en.wikipedia.org/wiki/WTFPL). See the LICENSE file for more info.