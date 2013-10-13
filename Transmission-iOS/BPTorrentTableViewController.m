//
//  BPTorrentTableViewController.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/24/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPTorrentTableViewController.h"
#import "BPTransmissionEngine.h"
#import "BPTorrentCell.h"

@interface BPTorrentTableViewController () <BPTorrentCellDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResults;

@end

@implementation BPTorrentTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = [[BPTransmissionEngine sharedEngine].client.baseURL.host stringByReplacingOccurrencesOfString:@".local." withString:@""];

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

//    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(settingsTapped:)];
//    self.navigationItem.leftBarButtonItem = settings;

    UINib *nib = [UINib nibWithNibName:@"BPTorrentCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TorrentCell"];


    self.fetchedResults = [BPTorrent MR_fetchAllGroupedBy:nil
                                            withPredicate:[NSPredicate predicateWithFormat:@"%K == %@", BPTorrentAttributes.isPendingDeletion, @NO]
                                                 sortedBy:BPTorrentAttributes.sortName
                                                ascending:YES
                                                 delegate:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [[BPTransmissionEngine sharedEngine] startUpdates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - User Interaction

- (void)settingsTapped:(id)sender {

}

#pragma mark - UITableViewDatasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fetchedResults.fetchedObjects.count;
}

- (void)configureCell:(BPTorrentCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    BPTorrent *torrent = [self.fetchedResults objectAtIndexPath:indexPath];
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

    BPTorrent *torrent = [self.fetchedResults objectAtIndexPath:indexPath];
    [[BPTransmissionEngine sharedEngine] removeTorrent:torrent deleteData:NO completion:^{
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
    BPTorrent *torrent = [self.fetchedResults objectAtIndexPath:indexPath];
    BPTorrentAction action = [torrent availableAction];
    switch (action) {
        case BPTorrentActionPause: {
            [[BPTransmissionEngine sharedEngine] pauseTorrent:torrent completion:^{
                DLog(@"paused: %@", torrent);
            } error:^(NSError *error) {
                [self displayError:error];
            }];
        }   break;
        case BPTorrentActionResume: {
            [[BPTransmissionEngine sharedEngine] resumeTorrent:torrent completion:^{
                DLog(@"resumed: %@", torrent);
            } error:^(NSError *error) {
                [self displayError:error];
            }];
        }   break;
        default:
            break;
    }
}

- (void)displayError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:error.localizedDescription
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {

    UITableView *tableView = self.tableView;

    switch(type) {

        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeUpdate:
            // As suggested by oleb: http://oleb.net/blog/2013/02/nsfetchedresultscontroller-documentation-bug/
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;

        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}


@end
