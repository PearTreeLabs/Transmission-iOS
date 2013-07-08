//
//  BPTransmissionTestProtocol.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 7/7/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTransmissionTestProtocol.h"
#import "BPTransmissionClient.h"

@interface BPTransmissionTestProtocol ()

@end

@implementation BPTransmissionTestProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return ([@[@"http", @"https"] containsObject:request.URL.scheme] &&
            [request.HTTPMethod isEqualToString:@"POST"] &&
            [request.URL.path hasPrefix:@"/transmission/rpc"]);
}

+ (NSURLResponse *)responseForRequest:(NSURLRequest *)request {
    NSURLResponse *response = nil;
    if ([request.allHTTPHeaderFields objectForKey:kBPTransmissionSessionIdHeader]) {
        // Typical JSON Request
        response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                               statusCode:200
                                              HTTPVersion:@"HTTP/1.1"
                                             headerFields:@{ @"Content-Type" : @"text/json" }];
    } else if ([request.allHTTPHeaderFields objectForKey:@"Authorization"]) {
        // Auth Request
        response = [[NSHTTPURLResponse alloc] initWithURL:request.URL
                                                              statusCode:409
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:@{ kBPTransmissionSessionIdHeader : @"MockSessionId" }];
    } else {
        // Unauthorized, non-authorization request, ignore it
    }
    return response;
}

+ (NSData *)dataForRequest:(NSURLRequest *)request {
    NSData *data = nil;
    if ([request.allHTTPHeaderFields objectForKey:kBPTransmissionSessionIdHeader]) {
        // Typical JSON Request
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:&error];
        if (json == nil) {
            DLog(@"Error parsing request: %@", error);
            return nil;
        }

        NSString *method = [json objectForKey:@"method"];
        if ([method isEqualToString:@"torrent-get"]) {
            // Load the response body from a file.
            NSString *path = [[NSBundle mainBundle] pathForResource:@"get-torrent" ofType:@"json"];
            NSData *torrentData = [NSData dataWithContentsOfFile:path options:0 error:&error];
            if (torrentData == nil) {
                DLog(@"Error loading torrent data: %@", error);
                return nil;
            }
            data = torrentData;
        }
    }
    return data;
}

@end
