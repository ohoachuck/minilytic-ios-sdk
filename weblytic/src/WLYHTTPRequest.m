//
//  WLYHTTPRequest.m
//  weblytic iOS SDK
//
//  Copyright (c) 2013 Manbolo. All rights reserved.
//

#import "WLYHTTPRequest.h"
#import <zlib.h>

@implementation WLYHTTPRequest

- (NSData *)GZIPDataWithData:(NSData*)uncompressedData;
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
