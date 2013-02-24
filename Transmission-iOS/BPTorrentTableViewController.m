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

@property (nonatomic, retain) NSArray *torrents;

@end

@implementation BPTorrentTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"Torrents";
}

- (void)viewDidAppear:(BOOL)animated {
    // TODO: specify connection details
    BPTransmissionClient *client = [BPTransmissionClient clientForHost:@"" port:0];
    [client connect:^{
        [client retrieveTorrents:nil completion:^(NSArray *torrents) {
            DLog(@"torrents: %@", torrents);
            self.torrents = torrents;
            [self.tableView reloadData];
        } error:^(NSError *error) {
            DLog(@"retrieval error: %@", error);
        }];
    } error:^(NSError *error) {
        DLog(@"connection error: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.torrents.count;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.textLabel.text = [[self.torrents objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
