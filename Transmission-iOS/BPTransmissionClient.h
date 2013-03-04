//
//  BPTransmissionClient.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "AFHTTPClient.h"
#import "transmission.h"
#import "Torrent.h"

typedef void(^BPPlainBlock)(void);
typedef void(^BPTorrentBlock)(Torrent *torrent);
typedef void(^BPTorrentsBlock)(NSArray *torrents);
typedef void(^BPErrorBlock)(NSError *error);

extern NSString * const kBPTransmissionClientErrorDomain;

@interface BPTransmissionClient : AFHTTPClient

@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port;

- (NSOperation *)connectAsUser:(NSString *)username password:(NSString *)password completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (void)disconnect;

- (NSOperation *)retrieveTorrent:(NSString *)identifier completion:(BPTorrentBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)retrieveTorrentsCompletion:(BPTorrentsBlock)completionBlock error:(BPErrorBlock)errorBlock;

- (NSOperation *)startTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)stopTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)removeTorrent:(NSString *)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;

@end
