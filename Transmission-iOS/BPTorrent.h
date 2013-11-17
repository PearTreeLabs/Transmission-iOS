#import "_BPTorrent.h"

typedef NS_ENUM(NSInteger, BPTorrentAction) {
    BPTorrentActionPause,
    BPTorrentActionResume,
    BPTorrentActionNone
};

@interface BPTorrent : _BPTorrent {}

+ (BPTorrent *)torrentFromDictionary:(NSDictionary *)dict;

- (void)updateFromDictionary:(NSDictionary *)dict;

- (BPTorrentAction)availableAction;

- (BOOL) isMagnet;
- (CGFloat) ratio;
- (BOOL) waitingToStart;
- (uint64_t) size;
- (uint64_t) sizeLeft;
- (CGFloat) progressDone;
- (CGFloat) progressLeft;
- (CGFloat) checkingProgress;
- (CGFloat) availableDesired;
- (BOOL) isActive;
- (BOOL) isSeeding;
- (BOOL) isChecking;
- (BOOL) isCheckingWaiting;
- (BOOL) allDownloaded;
- (BOOL) isFinishedSeeding;
- (BOOL) isError;
- (BOOL) isAnyErrorOrWarning;
- (NSString *) errorMessage;
- (CGFloat) downloadRate;
- (CGFloat) uploadRate;
- (CGFloat) totalRate;
- (NSDate *) dateAdded;

@end
