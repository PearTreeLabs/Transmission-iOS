//
//  NSUserDefaults+Settings.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/23/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Settings)

// @default NO
@property (nonatomic, assign) BOOL bp_pauseAddedTransfers;

// @default NO
@property (nonatomic, assign) BOOL bp_deleteBackingFilesWhenRemovingTorrents;

@property (nonatomic, assign) BOOL bp_demoMode;

- (void)bp_registerDefaults;

@end
