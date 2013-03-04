//
//  BPTorrentCell.h
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/2/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Torrent.h"
#import "BPProgressView.h"

@protocol BPTorrentCellDelegate;

@interface BPTorrentCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *actionButton;
@property (strong, nonatomic) IBOutlet BPProgressView *progressView;
@property (nonatomic, weak) id<BPTorrentCellDelegate> delegate;

- (IBAction)actionTapped:(id)sender;

- (void)updateForTorrent:(Torrent *)torrent;

@end

@protocol BPTorrentCellDelegate <NSObject>

@optional
- (void)torrentCellDidTapActionButton:(BPTorrentCell *)cell;

@end