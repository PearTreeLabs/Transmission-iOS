//
//  BPTransmissionClient.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "AFHTTPClient.h"

typedef void(^BPPlainBlock)(void);
typedef void(^BPTorrentsBlock)(NSArray *torrents);
typedef void(^BPErrorBlock)(NSError *error);

@interface BPTransmissionClient : AFHTTPClient

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port;

- (NSOperation *)connect:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (void)disconnect;

- (NSOperation *)retrieveTorrents:(NSDictionary *)options completion:(BPTorrentsBlock)completionBlock error:(BPErrorBlock)errorBlock;

@end
