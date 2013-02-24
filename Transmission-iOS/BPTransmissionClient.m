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

static NSString * const kBPTransmissionSessionIdHeader = @"X-Transmission-Session-Id";

@interface BPTransmissionClient ()

@property (nonatomic, copy) NSString *sessionId;

@end

@implementation BPTransmissionClient

- (void)setSessionId:(NSString *)sessionId {
    [self setDefaultHeader:kBPTransmissionSessionIdHeader value:sessionId];
}

- (NSString *)sessionId {
    return [self defaultValueForHeader:kBPTransmissionSessionIdHeader];
}

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port {
    NSString *scheme = @"http";
    NSString *path = @"/transmission/rpc";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@:%d%@", scheme, hostAddress, port, path]];
    BPTransmissionClient *client = [self clientWithBaseURL:url];
    return client;
}

- (NSOperation *)connect:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    return [self retrieveSessionId:completionBlock error:errorBlock];
}

- (void)disconnect {
    self.sessionId = nil;
}

- (NSOperation *)retrieveSessionId:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    [AFHTTPRequestOperation addAcceptableStatusCodes:[NSIndexSet indexSetWithIndex:409]];
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

- (NSOperation *)retrieveTorrents:(NSDictionary *)options completion:(BPTorrentsBlock)completionBlock error:(BPErrorBlock)errorBlock {
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:nil
                                                parameters:nil];
    NSDictionary *params = @{
                             @"method" : @"torrent-get",
                             @"arguments" : @{ @"fields" : @[ @"id", @"name", @"status" ] }
                             };
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *torrents = [[JSON objectForKey:@"arguments"] objectForKey:@"torrents"];
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
    return nil;
}

@end
