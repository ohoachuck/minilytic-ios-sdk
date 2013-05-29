//
//  WLYTracker.m
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "WLYTracker.h"
#import "WLYUser.h"
#import "WLYDevice.h"
#import "WLYHTTPRequest.h"

@interface WLYTracker ()

@property(strong) NSMutableArray *trackedItems;
@property(strong) NSDateFormatter *dateFormatter;
@end


@implementation WLYTracker

+ (WLYTracker *)defaultTracker {
    static dispatch_once_t onceToken;
    static WLYTracker *tracker = nil;
    dispatch_once(&onceToken, ^{
        tracker = [[WLYTracker alloc] init];
    });
    return tracker;
}

- (id)init
{
    self = [super init];
    if (self){
        _trackedItems = [NSMutableArray array];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss Z"];
        _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    }
    return self;
}

- (void)trackPage:(NSString *)name
{
    [self trackPage:name customMetrics:nil];
}

- (void)trackPage:(NSString *)pageName customMetrics:(NSDictionary*)dic
{
    NSDate *now = [[NSDate alloc] init];
    NSLog(@"trackPage: name=\"%@\" customMetrics=%@ date=\"%@\"", pageName, dic, now);
    
}

- (void)trackEvent:(NSString *)eventName
{
    NSDictionary *event = [self eventWithName:eventName];
    [self.trackedItems addObject:event];
    NSLog(@"trackEvent: %@", event);
}


- (NSDictionary *)eventWithName:(NSString *)eventName
{
    NSDate *now = [[NSDate alloc] init];
    now = [now dateByAddingTimeInterval:rand() % 10];
    return @{@"type": @"event",
             @"name": eventName,
             @"date": [self.dateFormatter stringFromDate:now],
             };
}

- (NSData *)JSONDataWithTrackedItems
{
    NSMutableDictionary *payloadDictionary = [NSMutableDictionary dictionary];
    payloadDictionary[@"account.username"] = self.account;
    payloadDictionary[@"app.identifier"] = self.identifier;
    payloadDictionary[@"user.identifier"] = [WLYUser defaultUser].identifier;
    payloadDictionary[@"device.platform"] = [WLYDevice defaultDevice].platform;
    payloadDictionary[@"device.hardware_model"] = [WLYDevice defaultDevice].hardwareModel;
    payloadDictionary[@"device.system_version"] = [WLYDevice defaultDevice].systemVersion;
    payloadDictionary[@"device.system_name"] = [WLYDevice defaultDevice].systemName;
    payloadDictionary[@"items"] = self.trackedItems;

    NSError *writeError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:payloadDictionary
                                                        options:NSJSONWritingPrettyPrinted
                                                          error:&writeError];
    if (!writeError){
        return jsonData;
    }
    else{
        return nil;
    }
}

- (NSString *)JSONStringWithTrackedItems
{
    NSData *jsonData = [self JSONDataWithTrackedItems];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                 encoding:NSUTF8StringEncoding];
    return jsonString;
}


- (void)sendTrackedItems
{
    NSString *jsonString = [self JSONStringWithTrackedItems];
    NSData *jsonData = [self JSONDataWithTrackedItems];
    
    WLYHTTPRequest *request = [[WLYHTTPRequest alloc] init];
    NSData *gzipData = [request GZIPDataWithData:jsonData];
    
    NSUInteger rawLenght = jsonData.length;
    NSUInteger compressedLenght = gzipData.length;
    CGFloat compressionRatio = 100.0 * (rawLenght - compressedLenght) / rawLenght;
    
    NSLog(@"sendTrackEvent uncompressed: %d bytes\n%@", rawLenght, jsonString);
    NSLog(@"sendTrackEvent compressed: %d bytes (%.0f%%) %@", compressedLenght, compressionRatio, gzipData);
    
}



@end
