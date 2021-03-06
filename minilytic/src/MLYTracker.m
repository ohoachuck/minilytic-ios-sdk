//
//  MLYTracker.m
//  minilytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//
#import "MLYTracker.h"
#import "MLYUser.h"
#import "MLYDevice.h"
#import "MLYHTTPRequest.h"
#import <zlib.h>

@interface MLYTracker ()

@property(strong) NSMutableArray *trackedItems;
@property(strong) NSDateFormatter *dateFormatter;
@property(strong) NSOperationQueue *requestsQueue;

@end



@implementation MLYTracker

#pragma mark - alloc / init

+ (MLYTracker *)defaultTracker {
    static dispatch_once_t onceToken;
    static MLYTracker *tracker = nil;
    dispatch_once(&onceToken, ^{
        tracker = [[MLYTracker alloc] init];
    });
    return tracker;
}

- (id)init
{
    self = [super init];
    if (self){
        _trackedItems = [NSMutableArray array];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ssZ"];
        _dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
        _requestsQueue = [[NSOperationQueue alloc] init];
        [self registerToNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Background / Foreground
- (void)registerToNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:UIApplicationDidFinishLaunchingNotification
                                               object:nil];

}


- (void)applicationWillEnterForeground:(NSNotification *)theNotification
{
    [self trackEvent:@"app.foreground"];
}

- (void)applicationDidEnterBackground:(NSNotification *)theNotification
{
    [self trackEvent:@"app.background"];
    [self sendTrackedItems];
}

- (void)applicationWillTerminate:(NSNotification *)theNotification
{
    [self trackEvent:@"app.background"];
    [self sendTrackedItems];
}

- (void)applicationDidFinishLaunching:(NSNotification *)theNotification
{
    [self trackEvent:@"app.foreground"];
}

#pragma mark - Track event / page
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
    [_trackedItems addObject:event];
    NSLog(@"trackEvent: %@", event);
}


- (NSDictionary *)eventWithName:(NSString *)eventName
{
    NSDate *now = [[NSDate alloc] init];
    return @{@"type": @"event",
             @"name": eventName,
             @"date": [_dateFormatter stringFromDate:now],
             };
}

- (NSData *)JSONDataWithTrackedItems
{
    NSString* appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];

    NSMutableDictionary *payloadDictionary = [NSMutableDictionary dictionary];
    payloadDictionary[@"version"] = @"1";
    payloadDictionary[@"account.key"] = _accountKey;
    payloadDictionary[@"app.identifier"] = _appIdentifier;
    payloadDictionary[@"app.version"] = appVersion;
    payloadDictionary[@"user.identifier"] = [MLYUser defaultUser].identifier;
    payloadDictionary[@"device.platform"] = [MLYDevice defaultDevice].platform;
    payloadDictionary[@"device.hardware_model"] = [MLYDevice defaultDevice].hardwareModel;
    payloadDictionary[@"device.system_version"] = [MLYDevice defaultDevice].systemVersion;
    payloadDictionary[@"device.system_name"] = [MLYDevice defaultDevice].systemName;
    payloadDictionary[@"items"] = _trackedItems;

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
    NSString *jsonString = [self JSONStringWithTrackedItems];
    NSLog(@"%@", jsonString);
    
    MLYHTTPRequest *request = [[MLYHTTPRequest alloc] init];
    request.usingLocalhost = YES;
    request.body = gzipData;
    [_requestsQueue addOperation:request];
    [_trackedItems removeAllObjects];
    
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
