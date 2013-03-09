//
//  BPTorrentCell.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/2/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTorrentCell.h"
#import "UIColor+Progress.h"

@implementation BPTorrentCell

- (void)awakeFromNib {
    self.progressView.trackColor = [UIColor progressWhiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)actionTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(torrentCellDidTapActionButton:)]) {
        [self.delegate torrentCellDidTapActionButton:self];
    }
}

- (void)updateForTorrent:(Torrent *)torrent {
    self.nameLabel.text = [torrent name];

    NSMutableString *stats = [NSMutableString stringWithFormat:@"Ratio: %.2f", torrent.ratio];
    if (torrent.uploadRate > 0) {
        [stats appendFormat:@"  ▲ %.2f KB/s", torrent.uploadRate];
    }
    if (torrent.downloadRate > 0) {
        [stats appendFormat:@"  ▼ %.2f KB/s", torrent.downloadRate];
    }
    self.statsLabel.text = stats;

    self.progressView.progress = [torrent progressDone];
    self.progressView.progressColor = [self progressBarColorForTorrent:torrent];

    NSString *controlImageBaseName = [self controlImageBaseNameForAction:[torrent availableAction]];
    if (![NSString bp_isNilOrEmpty:controlImageBaseName]) {
        NSString *normalName = [NSString stringWithFormat:@"%@Hover", controlImageBaseName];
        NSString *highlightedName = [NSString stringWithFormat:@"%@On", controlImageBaseName];
        [self.actionButton setImage:[UIImage imageNamed:normalName] forState:UIControlStateNormal];
        [self.actionButton setImage:[UIImage imageNamed:highlightedName] forState:UIControlStateHighlighted];
    }
}

#pragma mark - Private

- (NSString *)controlImageBaseNameForAction:(BPTorrentAction)action {
    NSString *result = nil;
    switch (action) {
        case BPTorrentActionPause:
            result = @"Pause";
            break;
        case BPTorrentActionResume:
            result = @"Resume";
            break;
        default:
            break;
    }
    return result;
}

- (UIColor *)progressBarColorForTorrent:(Torrent *)torrent {
    UIColor *result = nil;
    if ([torrent isActive]) {
        if ([torrent isChecking]) {
            result = [UIColor progressYellowColor];
        } else if ([torrent isSeeding]) {
            result = [UIColor progressGreenColor];
        } else {
            result = [UIColor progressBlueColor];
        }
    } else {
        if ([torrent waitingToStart]) {
            if ([torrent allDownloaded]) {
                result = [UIColor progressDarkGreenColor];
            } else {
                result = [UIColor progressDarkBlueColor];
            }
        } else {
            result = [UIColor progressGrayColor];
        }
    }
    return result;
}

@end
