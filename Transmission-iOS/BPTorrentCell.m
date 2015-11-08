//
//  BPTorrentCell.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 3/2/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPFoundation.h"
#import "BPTorrentCell.h"
#import "UIColor+Progress.h"
#import "TTTTimeIntervalFormatter.h"

@interface BPTorrentCell ()

@property (nonatomic, copy) NSString *statsText;
@property (nonatomic, copy) NSString *ageText;

@end

@implementation BPTorrentCell

#pragma mark - Shared

+ (TTTTimeIntervalFormatter *)addedDeltaFormatter {
    static TTTTimeIntervalFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[TTTTimeIntervalFormatter alloc] init];
    });
    return formatter;
}

#pragma mark - Properties

- (void)setStyle:(BPTorrentCellStyle)style {
    if (style == _style) {
        return;
    }

    _style = style;

    [self updateSubtitle];
}

#pragma mark - Lifecycle

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];

    [self.actionButton setHighlighted:highlighted];
}

- (void)awakeFromNib {
    self.progressView.trackColor = [UIColor progressWhiteColor];
    self.style = BPTorrentCellStyleStats;
}

- (void)prepareForReuse {
    [super prepareForReuse];

    self.style = BPTorrentCellStyleStats;
}

#pragma mark - Actions

- (IBAction)actionTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(torrentCellDidTapActionButton:)]) {
        [self.delegate torrentCellDidTapActionButton:self];
    }
}

#pragma mark - Content

- (void)updateSubtitle {
    switch (self.style) {
        case BPTorrentCellStyleStats:
            self.subtitleLabel.text = self.statsText;
            break;
        case BPTorrentCellStyleAge:
            self.subtitleLabel.text = self.ageText;
            break;
        default:
            break;
    }
}

- (void)updateForTorrent:(BPTorrent *)torrent {
    self.nameLabel.text = [torrent name];

    if (![NSString bp_isNilOrEmpty:torrent.errorMessage]) {
        self.subtitleLabel.text = torrent.errorMessage;
        self.subtitleLabel.textColor = [UIColor redColor];
    } else {
        NSMutableString *stats = [NSMutableString stringWithFormat:@"Ratio: %.2f", torrent.ratio];
        if (torrent.uploadRate > 0) {
            [stats appendFormat:@"  ▲ %.2f KB/s", torrent.uploadRate];
        }
        if (torrent.downloadRate > 0) {
            [stats appendFormat:@"  ▼ %.2f KB/s", torrent.downloadRate];
        }
        self.statsText = stats;

        NSTimeInterval interval = [torrent.dateAdded timeIntervalSinceNow];
        NSString *formattedAddedDelta = [[[self class] addedDeltaFormatter] stringForTimeInterval:interval];
        self.ageText = [NSString stringWithFormat:@"Added %@", formattedAddedDelta];

        self.subtitleLabel.textColor = [UIColor lightGrayColor];

        [self updateSubtitle];
    }

    self.progressView.progress = [torrent progressDone];
    self.progressView.progressColor = [self progressBarColorForTorrent:torrent];

    NSString *controlImageBaseName = [self controlImageBaseNameForAction:[torrent availableAction]];
    if (![NSString bp_isNilOrEmpty:controlImageBaseName]) {
        NSString *normalName = [NSString stringWithFormat:@"%@", controlImageBaseName];
        NSString *highlightedName = [NSString stringWithFormat:@"%@Highlight", controlImageBaseName];
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

- (UIColor *)progressBarColorForTorrent:(BPTorrent *)torrent {
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
