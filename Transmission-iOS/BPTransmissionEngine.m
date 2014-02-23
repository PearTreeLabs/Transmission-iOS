//
//  BPTransmissionEngine.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/10/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTransmissionEngine.h"
#import "SVProgressHUD.h"

static void *kvoContext = &kvoContext;

@interface BPTransmissionEngine ()

@property (nonatomic, strong) NSTimer *updateTimer;
@property (nonatomic, strong) NSMutableArray *queuedTransferURLs;

@end

@implementation BPTransmissionEngine

#pragma mark - Properties

- (void)setClient:(BPTransmissionClient *)client {
    if (_client == client) {
        return;
    }

    [_client removeObserver:self forKeyPath:@"connected" context:kvoContext];
    [self willChangeValueForKey:@"client"];
    _client = client;
    [self didChangeValueForKey:@"client"];
    [_client addObserver:self forKeyPath:@"connected" options:0 context:kvoContext];

    [BPTorrent MR_truncateAll];
    [self processQueuedTransferURLs];
}

#pragma mark - Lifecycle

+ (instancetype)sharedEngine {
    static BPTransmissionEngine *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BPTransmissionEngine alloc] init];
    });
    return sharedInstance;
}

- (id)init {
	self = [super init];
	if (!self) {
        return nil;
	}

	_updateInterval = 10.0;
    _queuedTransferURLs = [NSMutableArray array];

    [MagicalRecord setupCoreDataStackWithInMemoryStore];

	return self;
}

#pragma mark - Update Scheduling

- (void)startUpdates {
    [self stopUpdates];
    [self update];
}

- (void)stopUpdates {
    [self.updateTimer invalidate];
}

#pragma mark - Updating

- (void)update {
    __weak BPTransmissionEngine *weakSelf = self;
    [self.client retrieveTorrentsCompletion:^(NSArray *torrents) {
        [weakSelf applyTorrentUpdates:torrents];

        weakSelf.updateTimer = [NSTimer scheduledTimerWithTimeInterval:weakSelf.updateInterval
                                                                target:weakSelf
                                                              selector:@selector(update)
                                                              userInfo:nil
                                                               repeats:NO];
    } error:^(NSError *error) {
        DLog(@"Update error: %@", error);
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            weakSelf.client = nil;
        }
    }];
}

- (void)applyTorrentUpdates:(NSArray *)torrents {
    for (NSDictionary *torrentDict in torrents) {
        // TODO: If a torrent is removed by the desktop client, it will not be removed from core data.
        // Since this array is all the known torrents, we may as well truncate any torrents in core data that are not in this array.

        NSString *identifier = [torrentDict objectForKey:BPTorrentAttributes.id];
        BPTorrent *torrent = [BPTorrent MR_findFirstByAttribute:BPTorrentAttributes.id
                                                      withValue:identifier];
        if (torrent == nil) {
            torrent = [BPTorrent torrentFromDictionary:torrentDict];
        } else {
            [torrent updateFromDictionary:torrentDict];
        }
    }
    NSError *error = nil;
    if (![[NSManagedObjectContext MR_contextForCurrentThread] save:&error]) {
        DLog(@"Update save error: %@", error);
    }
}

#pragma mark - Mutation

- (void)resumeTorrent:(BPTorrent *)torrent completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    [self.client startTorrent:torrent.idValue completion:^{
        [_client retrieveTorrent:torrent.idValue completion:^(NSDictionary *torrentDict) {
            [torrent updateFromDictionary:torrentDict];
            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

            if (completionBlock != nil) {
                completionBlock();
            }
        } error:errorBlock];
    } error:errorBlock];
}

- (void)pauseTorrent:(BPTorrent *)torrent completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    [self.client stopTorrent:torrent.idValue completion:^{
        [_client retrieveTorrent:torrent.idValue completion:^(NSDictionary *torrentDict) {
            [torrent updateFromDictionary:torrentDict];
            [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

            if (completionBlock != nil) {
                completionBlock();
            }
        } error:errorBlock];
    } error:errorBlock];
}

- (void)removeTorrent:(BPTorrent *)torrent deleteData:(BOOL)deleteData completion:(BPPlainBlock)completionBlock error:(BPErrorBlock)errorBlock {
    torrent.isPendingDeletionValue = YES;
    [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];
    
    [self.client removeTorrent:torrent.idValue deleteData:deleteData completion:^{
        [torrent MR_deleteEntity];
        [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

        if (completionBlock != nil) {
            completionBlock();
        }
    } error:^(NSError *error) {
        torrent.isPendingDeletion = NO;
        [[NSManagedObjectContext MR_contextForCurrentThread] save:nil];

        if (errorBlock != nil) {
            errorBlock(error);
        }
    }];
}

#pragma mark - Add Torrents

- (void)enqueueTransferForURL:(NSURL *)url {
    [self.queuedTransferURLs addObject:url];
    [self processQueuedTransferURLs];
}

- (void)processQueuedTransferURLs {
    if (self.client == nil ||
        !self.client.isConnected) {
        return;
    }
    
    NSArray *urlsToProcess = [self.queuedTransferURLs copy];
    for (NSURL *url in urlsToProcess) {
        [self.client addTorrentFromURL:url completion:^{
            [SVProgressHUD showSuccessWithStatus:@"Added Torrent"];
        } error:^(NSError *error) {
            DLog(@"Error adding torrent: %@", error);
            [SVProgressHUD showErrorWithStatus:error.localizedDescription];
        }];

        // Cleanup
        [self.queuedTransferURLs removeObject:url];
        if (url.isFileURL) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
                DLog(@"Error removing torrent file: %@", error);
            }
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != kvoContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    if ([keyPath isEqualToString:@"connected"]) {
        [self processQueuedTransferURLs];
    }
}

@end
