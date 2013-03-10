//
//  BPTransmissionEngine.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/10/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPTransmissionClient.h"
#import "BPTorrent.h"

@interface BPTransmissionEngine : NSObject

@property (nonatomic, strong) BPTransmissionClient *client;
@property (nonatomic, assign) NSTimeInterval updateInterval;

+ (instancetype)sharedEngine;

- (void)startUpdates;
- (void)stopUpdates;

- (void)resumeTorrent:(BPTorrent *)torrent completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (void)pauseTorrent:(BPTorrent *)torrent completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (void)removeTorrent:(BPTorrent *)torrent deleteData:(BOOL)deleteData completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;


@end
