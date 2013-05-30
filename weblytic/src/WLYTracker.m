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
#import <zlib.h>

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
    
    // Just testing purpose...
    now = [now dateByAddingTimeInterval:rand() % 10];
    
    return @{@"type": @"event",
             @"name": eventName,
             @"date": [self.dateFormatter stringFromDate:now],
             };
}

- (NSData *)JSONDataWithTrackedItems
{
    NSString* appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];

    NSMutableDictionary *payloadDictionary = [NSMutableDictionary dictionary];
    payloadDictionary[@"version"] = @"1";
    payloadDictionary[@"account.username"] = self.account;
    payloadDictionary[@"app.identifier"] = self.identifier;
    payloadDictionary[@"app.version"] = appVersion;
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
    NSData *jsonData = [self JSONDataWithTrackedItems];
    NSData *gzipData = [self GZIPDataWithData:jsonData];
    
    WLYHTTPRequest *request = [[WLYHTTPRequest alloc] init];
    request.body = gzipData;
    [request start];
    
}

- (NSData*)GZIPDataWithData:(NSData *)uncompressedData
{
    if ([uncompressedData length] == 0) {
        return uncompressedData;
    }
    
    z_stream zStream;
    bzero(&zStream, sizeof(z_stream));
    
    zStream.zalloc = Z_NULL;
    zStream.zfree = Z_NULL;
    zStream.opaque = Z_NULL;
    zStream.next_in = (Bytef *)[uncompressedData bytes];
    zStream.avail_in = (unsigned int)[uncompressedData length];
    zStream.total_out = 0;
    
    OSStatus status;
    if ((status = deflateInit(&zStream, Z_DEFAULT_COMPRESSION)) != Z_OK) {
        return nil;
    }
    
    NSMutableData *compressedData = [NSMutableData dataWithLength:1024];
    
    do {
        if ((status == Z_BUF_ERROR) || (zStream.total_out == [compressedData length])) {
            [compressedData increaseLengthBy:1024];
        }
        
        zStream.next_out = [compressedData mutableBytes] + zStream.total_out;
        zStream.avail_out = (unsigned int)([compressedData length] - zStream.total_out);
        
        status = deflate(&zStream, Z_FINISH);
    } while ((status == Z_OK) || (status == Z_BUF_ERROR));
    
    deflateEnd(&zStream);
    
    if ((status != Z_OK) && (status != Z_STREAM_END)) {
        return nil;
    }
    
    [compressedData setLength:zStream.total_out];
    
    return compressedData;
}


@end
