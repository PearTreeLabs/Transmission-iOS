//
//  NSUserDefaults+Settings.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/23/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "NSUserDefaults+Settings.h"

static NSString * const kBPPauseAddedTransfers = @"BPPauseAddedTransfers";
static NSString * const kBPDeleteBackingFilesWhenRemovingTorrents = @"BPDeleteBackingFilesWhenRemovingTorrents";
static NSString * const kBPDemoMode = @"com.peartreelabs.transmission.demo";

@implementation NSUserDefaults (Settings)

- (BOOL)bp_pauseAddedTransfers {
    return [self boolForKey:kBPPauseAddedTransfers];
}

- (void)setBp_pauseAddedTransfers:(BOOL)bp_pauseAddedTransfers {
    [self setBool:bp_pauseAddedTransfers forKey:kBPPauseAddedTransfers];
    [self synchronize];
}

- (BOOL)bp_deleteBackingFilesWhenRemovingTorrents {
    return [self boolForKey:kBPDeleteBackingFilesWhenRemovingTorrents];
}

- (void)setBp_deleteBackingFilesWhenRemovingTorrents:(BOOL)bp_deleteBackingFilesWhenRemovingTorrents {
    [self setBool:bp_deleteBackingFilesWhenRemovingTorrents forKey:kBPDeleteBackingFilesWhenRemovingTorrents];
    [self synchronize];
}

- (BOOL)bp_demoMode {
    return [self boolForKey:kBPDemoMode];
}

- (void)setBp_demoMode:(BOOL)bp_demoMode {
    [self setBool:bp_demoMode forKey:kBPDemoMode];
    [self synchronize];
}

- (void)bp_registerDefaults {
    NSDictionary *defaults = @{
                               kBPPauseAddedTransfers : @NO,
                               kBPDeleteBackingFilesWhenRemovingTorrents : @NO,
                               kBPDemoMode : @NO,
                               };
    [self registerDefaults:defaults];
}

@end
