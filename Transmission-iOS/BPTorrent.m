#import "BPTorrent.h"
#import "transmission.h"

@implementation BPTorrent

+ (BPTorrent *)torrentFromDictionary:(NSDictionary *)dict {
    BPTorrent *torrent = [BPTorrent MR_createEntity];
    [torrent updateFromDictionary:dict];
    return torrent;
}

- (void)updateFromDictionary:(NSDictionary *)dict {
    [self setValuesForKeysWithDictionary:dict];
}

- (BPTorrentAction)availableAction {
    BPTorrentAction result = BPTorrentActionNone;
    if ([self isActive]) {
        result = BPTorrentActionPause;
    } else {
        if ([self waitingToStart]) {
            result = BPTorrentActionPause;
        } else {
            result = BPTorrentActionResume;
        }
    }
    return result;
}

- (BOOL) isMagnet {
    return (self.magenetLink != nil);
}

- (CGFloat) ratio
{
    return MAX(0, self.uploadRatioValue);
}

- (BOOL) waitingToStart
{
    tr_torrent_activity activity = self.statusValue;
    return activity == TR_STATUS_DOWNLOAD_WAIT || activity == TR_STATUS_SEED_WAIT;
}

- (uint64_t) size
{
    return self.totalSizeValue;
}

- (uint64_t) sizeLeft
{
    return self.leftUntilDoneValue;
}

- (CGFloat) progressDone
{
    return self.percentDoneValue;
}

- (CGFloat) progressLeft
{
    if ([self size] == 0) //magnet links
        return 0.0;

    return (CGFloat)[self sizeLeft] / [self size];
}

- (CGFloat) checkingProgress
{
    return self.recheckProgressValue;
}

- (CGFloat) availableDesired
{
    return (CGFloat) self.desiredAvailableValue / [self sizeLeft];
}

- (BOOL) isActive
{
    tr_torrent_activity activity = self.statusValue;
    return activity != TR_STATUS_STOPPED && activity != TR_STATUS_DOWNLOAD_WAIT && activity != TR_STATUS_SEED_WAIT;
}

- (BOOL) isSeeding
{
    tr_torrent_activity activity = self.statusValue;
    return activity == TR_STATUS_SEED;
}

- (BOOL) isChecking
{
    tr_torrent_activity activity = self.statusValue;
    return activity == TR_STATUS_CHECK || activity == TR_STATUS_CHECK_WAIT;
}

- (BOOL) isCheckingWaiting
{
    tr_torrent_activity activity = self.statusValue;
    return activity == TR_STATUS_CHECK_WAIT;
}

- (BOOL) allDownloaded
{
    return self.leftUntilDoneValue == 0 && ![self isMagnet];
}

- (BOOL) isFinishedSeeding
{
    return self.isFinishedValue;
}

- (BOOL) isError
{
    tr_stat_errtype errortype = self.errorValue;
    return errortype == TR_STAT_LOCAL_ERROR;
}

- (BOOL) isAnyErrorOrWarning
{
    tr_stat_errtype errortype = self.errorValue;
    return errortype != TR_STAT_OK;
}

- (NSString *) errorMessage
{
    if (![self isAnyErrorOrWarning])
        return @"";

    NSString * error = self.errorString;
    if (error == nil)
        error = [NSString stringWithFormat: @"(%@)", NSLocalizedString(@"unreadable error", "Torrent -> error string unreadable")];

    //libtransmission uses "Set Location", Mac client uses "Move data file to..." - very hacky!
    error = [error stringByReplacingOccurrencesOfString: @"Set Location" withString: @"Move Data File To\xE2\x80\xA6"];

    return error;
}

- (CGFloat) downloadRate
{
    return self.rateDownloadValue / 1024.0;
}

- (CGFloat) uploadRate
{
    return self.rateUploadValue / 1024.0 ;
}

- (CGFloat) totalRate
{
    return [self downloadRate] + [self uploadRate];
}

@end
