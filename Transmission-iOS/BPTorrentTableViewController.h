//
//  BPTorrentTableViewController.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPTransmissionClient.h"

@interface BPTorrentTableViewController : UITableViewController

- (id)initWithTransmissionClient:(BPTransmissionClient *)client;

@end
