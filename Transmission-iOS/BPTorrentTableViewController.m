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
        DLog(@"torrents: %@", torrents);
        torrents = [torrents sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *lhs, NSDictionary *rhs) {
            return [[lhs objectForKey:@"name"] compare:[rhs objectForKey:@"name"]];
        }];
        self.torrents = torrents;
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
    NSDictionary *torrent = [self.torrents objectAtIndex:indexPath.row];
    cell.textLabel.text = [torrent objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];

    NSString *subtitle = nil;
    tr_torrent_activity status = ((NSNumber *)[torrent objectForKey:@"status"]).intValue;
    switch (status) {
        case TR_STATUS_STOPPED:
            subtitle = @"stopped";
            break;
        case TR_STATUS_CHECK:
            subtitle = @"checking";
            break;
        case TR_STATUS_CHECK_WAIT:
            subtitle = @"check pending";
            break;
        case TR_STATUS_DOWNLOAD:
            subtitle = @"downloading";
            break;
        case TR_STATUS_DOWNLOAD_WAIT:
            subtitle = @"download pending";
            break;
        case TR_STATUS_SEED:
            subtitle = @"seeding";
            break;
        case TR_STATUS_SEED_WAIT:
            subtitle = @"seeding pending";
            break;
        default:
            break;
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
