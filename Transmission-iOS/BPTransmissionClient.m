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
#import "NSData+Base64.h"
#import "AFNetworkActivityIndicatorManager.h"

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
//    NSInteger sessionNeededStatusCode = 409;
//    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:sessionNeededStatusCode]];
//    [AFJSONRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:sessionNeededStatusCode]];
}

#pragma mark - Properties

- (void)setSessionId:(NSString *)sessionId {
    [self setDefaultHeader:kBPTransmissionSessionIdHeader value:sessionId];
}

- (NSString *)sessionId {
    [self willChangeValueForKey:@"sessionId"];
    [self willChangeValueForKey:@"connected"];
    return [self defaultValueForHeader:kBPTransmissionSessionIdHeader];
    [self didChangeValueForKey:@"sessionId"];
    [self didChangeValueForKey:@"connected"];
}

- (BOOL)isConnected {
    return (self.sessionId != nil);
}

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
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
        if (operation.response.statusCode == 409) {
            self.sessionId = [operation.response.allHeaderFields objectForKey:kBPTransmissionSessionIdHeader];
            if (completionBlock != nil) {
                completionBlock();
            }
            return;
        }
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

- (NSOperation *)retrieveTorrent:(NSInteger)torrentId completion:(BPTorrentBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-get",
                             @"arguments" : @{ @"ids" : @[ @(torrentId) ],
                                               @"fields" : @[ @"id", @"name", @"status", @"totalSize", @"uploadRatio", @"leftUntilDone", @"percentDone", @"recheckProgress", @"desiredAvailable", @"isFinished", @"error", @"errorString", @"rateDownload", @"rateUpload", @"magenetLink" ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        handleErrorInResult(JSON);

        NSArray *dicts = [[JSON objectForKey:@"arguments"] objectForKey:@"torrents"];
        NSDictionary *dict = [dicts.reverseObjectEnumerator.allObjects lastObject];

        if (completionBlock != nil) {
            completionBlock(dict);
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
        if (completionBlock != nil) {
            completionBlock(dicts);
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

- (NSOperation *)startTorrent:(NSInteger)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-start",
                             @"arguments" : @{ @"ids" : @[ @(torrentId) ] }
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

- (NSOperation *)stopTorrent:(NSInteger)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-stop",
                             @"arguments" : @{ @"ids" : @[ @(torrentId) ] }
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

- (NSOperation *)removeTorrent:(NSInteger)torrentId deleteData:(BOOL)deleteData completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSMutableDictionary *params = [@{
                                   @"method" : @"torrent-remove",
                                   @"arguments" : @{ @"ids" : @[ @(torrentId) ] }
                                   } mutableCopy];
    if ([NSUserDefaults standardUserDefaults].bp_deleteBackingFilesWhenRemovingTorrents) {
        [params setObject:@YES forKey:@"delete-local-data"];
    }
    
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

#pragma mark - Add 

- (NSOperation *)addTorrentFromURL:(NSURL *)url completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *args = nil;
    BOOL pause = [NSUserDefaults standardUserDefaults].bp_pauseAddedTransfers;
    if (url.isFileURL) {
        NSData *data = [NSData dataWithContentsOfURL:url];
        NSString *encodedData = [data base64EncodedString];
        args = @{ @"metainfo" : encodedData,
                  @"paused" : @(pause)
                  };
    } else if ([url.scheme isEqualToString:@"magnet"]) {
        args = @{ @"filename" : url.absoluteString,
                  @"paused" : @(pause)
                  };
    } else {
        if (errorBlock != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:kBPTransmissionClientErrorDomain
                                                     code:0
                                                 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"Unsupported URL", nil) }];
                errorBlock(error);
            });
        }
        return nil;
    }
    NSDictionary *params = @{
                             @"method" : @"torrent-add",
                             @"arguments" : args
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
