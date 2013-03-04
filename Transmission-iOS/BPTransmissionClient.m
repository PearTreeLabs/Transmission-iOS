//
//  BPTransmissionClient.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTransmissionClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"

NSString * const kBPTransmissionClientErrorDomain = @"BPTransmissionClientErrorDomain";
static NSString * const kBPTransmissionSessionIdHeader = @"X-Transmission-Session-Id";

#define handleErrorInResult(JSON) \
NSString *status = [JSON objectForKey:@"result"]; \
if (![status isEqualToString:@"success"]) { \
    if (errorBlock != nil) { \
        NSError *error = [NSError errorWithDomain:kBPTransmissionClientErrorDomain \
                                             code:0 \
                                         userInfo:@{ NSLocalizedDescriptionKey : status }]; \
        errorBlock(error); \
    } \
    return; \
}

@interface BPTransmissionClient ()

@property (nonatomic, copy) NSString *sessionId;

@end

@implementation BPTransmissionClient

+ (void)load {
    NSInteger sessionNeededStatusCode = 409;
    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:sessionNeededStatusCode]];
    [AFJSONRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:sessionNeededStatusCode]];
}

#pragma mark - Properties

- (void)setSessionId:(NSString *)sessionId {
    [self setDefaultHeader:kBPTransmissionSessionIdHeader value:sessionId];
}

- (NSString *)sessionId {
    return [self defaultValueForHeader:kBPTransmissionSessionIdHeader];
}

- (BOOL)isConnected {
    return (self.sessionId != nil);
}

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port {
    NSString *scheme = @"http";
    NSString *path = @"/transmission/rpc";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d%@", scheme, hostAddress, port, path]];
    BPTransmissionClient *client = [self clientWithBaseURL:url];
    return client;
}

#pragma mark - Connection

- (NSOperation *)connectAsUser:(NSString *)username password:(NSString *)password completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    if (username != nil &&
        password != nil) {
        [self setAuthorizationHeaderWithUsername:username password:password];
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];

    AFHTTPRequestOperation *op = [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.sessionId = [operation.response.allHeaderFields objectForKey:kBPTransmissionSessionIdHeader];
        if (completionBlock != nil) {
            completionBlock();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

- (void)disconnect {
    self.sessionId = nil;
}

#pragma mark - Retrieval

- (NSOperation *)retrieveTorrent:(NSString *)torrentId completion:(BPTorrentBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-get",
                             @"arguments" : @{ @"ids" : @[ torrentId ],
                                               @"fields" : @[ @"id", @"name", @"status", @"totalSize", @"uploadRatio", @"leftUntilDone", @"percentDone", @"recheckProgress", @"desiredAvailable", @"isFinished", @"error", @"errorString", @"rateDownload", @"rateUpload", @"magenetLink" ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);

        NSArray *dicts = [[JSON objectForKey:@"arguments"] objectForKey:@"torrents"];
        NSDictionary *dict = [dicts.reverseObjectEnumerator.allObjects lastObject];
        Torrent *torrent = [[Torrent alloc] initWithTorrentDictionary:dict];

        if (completionBlock != nil) {
            completionBlock(torrent);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

- (NSOperation *)retrieveTorrentsCompletion:(BPTorrentsBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-get",
                             @"arguments" : @{ @"fields" : @[ @"id", @"name", @"status", @"totalSize", @"uploadRatio", @"leftUntilDone", @"percentDone", @"recheckProgress", @"desiredAvailable", @"isFinished", @"error", @"errorString", @"rateDownload", @"rateUpload", @"magenetLink" ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);

        NSArray *dicts = [[JSON objectForKey:@"arguments"] objectForKey:@"torrents"];
        NSMutableArray *torrents = [NSMutableArray arrayWithCapacity:dicts.count];
        for (NSDictionary *dict in dicts) {
            Torrent *torrent = [[Torrent alloc] initWithTorrentDictionary:dict];
            [torrents addObject:torrent];
        }
        if (completionBlock != nil) {
            completionBlock(torrents);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

#pragma mark - Start / Stop / Remove

- (NSOperation *)startTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-start",
                             @"arguments" : @{ @"ids" : @[ torrentId ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);
        
        if (completionBlock != nil) {
            completionBlock();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

- (NSOperation *)stopTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-stop",
                             @"arguments" : @{ @"ids" : @[ torrentId ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);
        
        if (completionBlock != nil) {
            completionBlock();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

- (NSOperation *)removeTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-remove",
                             @"arguments" : @{ @"ids" : @[ torrentId ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);

        if (completionBlock != nil) {
            completionBlock();
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
    [self enqueueHTTPRequestOperation:op];
    return op;
}

@end
