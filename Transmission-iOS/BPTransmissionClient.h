//
//  BPTransmissionClient.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "AFHTTPClient.h"
#import "transmission.h"

typedef void(^BPPlainBlock)(void);
typedef void(^BPTorrentBlock)(NSDictionary *torrent);
typedef void(^BPTorrentsBlock)(NSArray *torrents);
typedef void(^BPErrorBlock)(NSError *error);

extern NSString * const kBPTransmissionClientErrorDomain;
extern NSString * const kBPTransmissionSessionIdHeader;

@interface BPTransmissionClient : AFHTTPClient

@property (nonatomic, assign, readonly, getter = isConnected) BOOL connected;

+ (instancetype)clientForHost:(NSString *)hostAddress port:(NSInteger)port;

- (NSOperation *)connectAsUser:(NSString *)username password:(NSString *)password completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (void)disconnect;

- (NSOperation *)retrieveTorrent:(NSInteger)identifier completion:(BPTorrentBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)retrieveTorrentsCompletion:(BPTorrentsBlock)completionBlock error:(BPErrorBlock)errorBlock;

- (NSOperation *)startTorrent:(NSInteger)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)stopTorrent:(NSInteger)torrentId completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;
- (NSOperation *)removeTorrent:(NSInteger)torrentId deleteData:(BOOL)deleteData completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;

- (NSOperation *)addTorrentFromURL:(NSURL *)url completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock;

@end
