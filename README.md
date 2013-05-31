minilytic iOS SDK
================

Mini footprint app analytics

This open-source library allows you to integrate minilytic analytics SDK into your iOS app.

You simply track an event like this:
 
```objectice-c
MLYTracker *tracker = [MLYTracker defaultTracker];
[tracker trackEvent:@"tab1.buttonOk"];
```

Tracking an event is just recording a lightweight instance of this event in memory. At this point, there is no network connection involved. You are the responsible for sending all event to the server, by using `sendTrackedItems` on the singleton tracker. Tracked event are then sent in bulk, with a compressed gzip payload. A typical implementation is to send tracked items when the app goes in background (i.e. in `applicationDidEnterBackground:` and `applicationWillTerminate:`).

TRY IT OUT

1. Test your install; build and run the project at ~/Documents/minilytic-ios-sdk/Sample/Sample.xcodeproj
2. There is no step 2.

## Requirements

### libz

### ARC

## License

minilytic iOS SDK is available under the DWYW license. See the LICENSE file for more info.