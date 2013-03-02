//
//  BPTorrentTableViewController.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTorrentTableViewController.h"
#import "BPTransmissionClient.h"

@interface BPTorrentTableViewController ()

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

    UIBarButtonItem *refresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshTapped:)];
    self.navigationItem.rightBarButtonItem = refresh;

    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsTapped:)];
    self.navigationItem.leftBarButtonItem = settings;
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
    [self.client retrieveTorrents:nil completion:^(NSArray *torrents) {
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

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Torrent *torrent = [self.torrents objectAtIndex:indexPath.row];
    cell.textLabel.text = torrent.name;
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    NSString *state = nil;
    CGFloat uploadRate = -1;
    CGFloat downloadRate = -1;
    if (torrent.isSeeding) {
        state = @"seeding";
        uploadRate = torrent.uploadRate;
    } else if (torrent.isChecking) {
        state = @"checking";
    } else if (torrent.isFinishedSeeding) {
        state = @"done";
    } else if (torrent.isActive) {
        state = @"active";
        uploadRate = torrent.uploadRate;
        downloadRate = torrent.downloadRate;
    } else {
        state = @"inactive";
    }

    NSMutableString *subtitle = [NSMutableString stringWithString:state];
    if (uploadRate != -1) {
        [subtitle appendFormat:@" ▲ %.0f KB/s", uploadRate];
    }
    if (downloadRate != -1) {
        [subtitle appendFormat:@" ▼ %.0f KB/s", downloadRate];
    }

    cell.detailTextLabel.text = subtitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) {
        return;
    }

    NSMutableArray *mutableTorrents = [self.torrents mutableCopy];
    [mutableTorrents removeObjectAtIndex:indexPath.row];
    self.torrents = [mutableTorrents copy];

    [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];

    // TODO: actually remove the torrent from the server
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

@end
