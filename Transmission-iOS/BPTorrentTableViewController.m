//
//  BPTorrentTableViewController.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTorrentTableViewController.h"
#import "BPTransmissionClient.h"
#import "BPTorrentCell.h"

@interface BPTorrentTableViewController () <BPTorrentCellDelegate>

@property (nonatomic, strong) BPTransmissionClient *client;
@property (nonatomic, strong) NSArray *torrents;

@end

@implementation BPTorrentTableViewController

- (id)initWithTransmissionClient:(BPTransmissionClient *)client {
	self = [super initWithStyle:UITableViewStylePlain];
	if (!self) {
        return nil;
	}

	_client = client;
    _torrents = @[];

	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Torrents";

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTapped:)];
    self.navigationItem.rightBarButtonItem = refresh;

    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsTapped:)];
//    self.navigationItem.leftBarButtonItem = settings;

    UINib *nib = [UINib nibWithNibName:@"BPTorrentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TorrentCell"];
}

- (void)viewWillAppear:(BOOL)animated {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self refreshTorrents];
    });
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction

- (void)refreshTapped:(id)sender {
    self.torrents = @[];
    [self.tableView reloadData];
    
    [self refreshTorrents];
}

- (void)settingsTapped:(id)sender {

}

#pragma mark - Data Mgmt

- (void)refreshTorrents {
    [self.client retrieveTorrentsCompletion:^(NSArray *torrents) {
        NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
        self.torrents = [torrents sortedArrayUsingDescriptors:@[ nameDescriptor ]];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        DLog(@"retrieval error: %@", error);
    }];
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.torrents.count;
}

- (void)configureCell:(BPTorrentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Torrent *torrent = [self.torrents objectAtIndex:indexPath.row];
    [cell updateForTorrent:torrent];
    cell.delegate = self;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TorrentCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:(BPTorrentCell *)cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    Torrent *torrent = [self.torrents objectAtIndex:indexPath.row];
    NSMutableArray *mutableTorrents = [self.torrents mutableCopy];
    [mutableTorrents removeObjectAtIndex:indexPath.row];
    self.torrents = [mutableTorrents copy];

    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

    [self.client removeTorrent:torrent.identifier completion:^{
        DLog(@"removed: %@", torrent);
    } error:^(NSError *error) {
        [self displayError:error];
    }];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - BPTorrentCelLDelegate

- (void)torrentCellDidTapActionButton:(BPTorrentCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    Torrent *torrent = [self.torrents objectAtIndex:indexPath.row];
    BPTorrentAction action = [torrent availableAction];
    switch (action) {
        case BPTorrentActionPause: {
            [self.client stopTorrent:torrent.identifier completion:^{
                DLog(@"paused: %@", torrent);
                // TODO: this is a hack, refresh a single torrent after a delay so that the remote side can report the new state.
                double delayInSeconds = 0.3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.client retrieveTorrent:torrent.identifier completion:^(Torrent *newTorrent) {
                        [self updateTorrent:torrent withTorrent:newTorrent];
                    } error:^(NSError *error) {
                        [self displayError:error];
                    }];
                });
            } error:^(NSError *error) {
                [self displayError:error];
            }];
        }   break;
        case BPTorrentActionResume: {
            [self.client startTorrent:torrent.identifier completion:^{
                DLog(@"resumed: %@", torrent);
                // TODO: this is a hack, refresh a single torrent after a delay so that the remote side can report the new state.
                double delayInSeconds = 0.3;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    [self.client retrieveTorrent:torrent.identifier completion:^(Torrent *newTorrent) {
                        [self updateTorrent:torrent withTorrent:newTorrent];
                    } error:^(NSError *error) {
                        [self displayError:error];
                    }];
                });
            } error:^(NSError *error) {
                [self displayError:error];
            }];
        }   break;
        default:
            break;
    }
}

- (void)updateTorrent:(Torrent *)oldTorrent withTorrent:(Torrent *)newTorrent {
    NSMutableArray *mutableTorrents = [self.torrents mutableCopy];
    NSInteger index = [mutableTorrents indexOfObject:oldTorrent];
    [mutableTorrents replaceObjectAtIndex:index withObject:newTorrent];
    self.torrents = [mutableTorrents copy];
    [self.tableView reloadRowsAtIndexPaths:@[ [NSIndexPath indexPathForRow:index inSection:0] ]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)displayError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
