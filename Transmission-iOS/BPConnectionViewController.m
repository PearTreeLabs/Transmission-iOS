//
//  BPConnectionViewController.m
//  Transmission-iOS
//
//  Created by Brian Partridge on 2/28/13.
//  Copyright (c) 2013 Brian Partridge. All rights reserved.
//

#import "BPConnectionViewController.h"
#import "BPBonjourBrowser.h"
#import "BPTransmissionEngine.h"
#import "BPTorrentTableViewController.h"

#define RESOLVE_TIMEOUT 10

extern NSString *AFNetworkingOperationFailingURLResponseErrorKey;

static void *kvoContext = &kvoContext;

@interface BPConnectionViewController () <NSNetServiceDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) BPBonjourBrowser *browser;
@property (nonatomic, strong) NSNetService *currentService;

@end

@implementation BPConnectionViewController

#pragma mark - Properties

- (void)setCurrentService:(NSNetService *)currentService {
    _currentService.delegate = nil;
    [_currentService stop];

    _currentService = currentService;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.spinner.hidesWhenStopped = YES;
    self.activityLabel.text = @"";
    self.retryButton.hidden = YES;
    
    self.browser = [[BPBonjourBrowser alloc] init];

    [self identifyAvailableServices];

    [[BPTransmissionEngine sharedEngine] addObserver:self forKeyPath:@"client" options:0 context:kvoContext];
}

- (void)dealloc {
    [[BPTransmissionEngine sharedEngine] removeObserver:self forKeyPath:@"client" context:kvoContext];
}

#pragma mark - Services

- (void)identifyAvailableServices {
    [self setRunningStateWithText:NSLocalizedString(@"Searching...", nil)];
    __weak BPBonjourBrowser *weakBrowser = self.browser;
    [self.browser searchForServicesOfType:kBPBonjourBrowserServiceTypeHTTP inDomain:kBPBonjourBrowserDomainLocal updateBlock:^(NSArray *services) {
        DLog(@"services = %@", services);
        [services enumerateObjectsUsingBlock:^(NSNetService *service, NSUInteger idx, BOOL *stop) {
            if ([service.name hasPrefix:@"Transmission"]) {
                *stop = YES;
                [weakBrowser stopSearching];
                self.currentService = service;
                self.currentService.delegate = self;
                [self.currentService resolveWithTimeout:RESOLVE_TIMEOUT];
            }
        }];
    }];
}

- (void)connectToResolvedService:(NSNetService *)service username:(NSString *)username password:(NSString *)password {
    __weak BPConnectionViewController *weakSelf = self;
    BPTransmissionClient *client = [BPTransmissionClient clientForHost:service.hostName port:service.port];
    [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusNotReachable ||
            status == AFNetworkReachabilityStatusUnknown) {
            [BPTransmissionEngine sharedEngine].client = nil;
        }
    }];
    
    __weak BPTransmissionClient *weakClient = client;
    [client connectAsUser:username password:password completion:^{
        DLog(@"connected");
        BPTransmissionEngine *engine = [BPTransmissionEngine sharedEngine];
        engine.client = weakClient;
        BPTorrentTableViewController *vc = [[BPTorrentTableViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    } error:^(NSError *error) {
        DLog(@"connection error: %@", error);
        BOOL needsAuth = NO;
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            needsAuth = (((NSHTTPURLResponse *)response).statusCode == 401);
        }

        if (needsAuth) {
            NSString *displayName = service.hostName;
            if ([displayName hasSuffix:@"."]) {
                displayName = [displayName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:displayName
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Login", nil];
            alert.alertViewStyle = UIAlertViewStyleLoginAndPasswordInput;
            [alert show];
        } else {
            self.currentService = nil;
            [self setErrorStateWithText:NSLocalizedString(@"Connection Error", nil)];
        }
    }];
}

- (void)handleDisconnect {
    self.currentService = nil;
    [self setErrorStateWithText:NSLocalizedString(@"Transmission Lost", nil)];
    [self dismissViewControllerAnimated:YES completion:^{
        [self identifyAvailableServices];
    }];
}

#pragma mark - UI State Management

- (void)setRunningStateWithText:(NSString *)status {
    [self.spinner startAnimating];
    self.activityLabel.text = status;
    self.retryButton.hidden = YES;
}

- (void)setSuccessStateWithText:(NSString *)status {
    [self.spinner stopAnimating];
    self.activityLabel.text = status;
    self.retryButton.hidden = YES;
}

- (void)setErrorStateWithText:(NSString *)status {
    [self.spinner stopAnimating];
    self.activityLabel.text = status;
    self.retryButton.hidden = NO;
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceWillResolve:(NSNetService *)service {
    DLog(@"will resolve: %@", service);
    [self setRunningStateWithText:NSLocalizedString(@"Incomming Transmission...", nil)];
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    if (service.hostName == nil) {
        // Resolved, but no hostname. Wait for another resolution status update.
        return;
    }
    DLog(@"resolved: %@", service);
    [self setSuccessStateWithText:NSLocalizedString(@"Transmission Received", nil)];
    [self connectToResolvedService:self.currentService username:nil password:nil];
    self.currentService = nil;
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    DLog(@"unable to resolve: %@: %@", service, errorDict);
    self.currentService = nil;
    [self setErrorStateWithText:NSLocalizedString(@"Resolve Error", nil)];
}

- (void)netServiceDidStop:(NSNetService *)service {
    DLog(@"resolution did stop: %@", service);
    [self handleDisconnect];
}

#pragma mark - User Interaction

- (IBAction)retryTapped:(id)sender {
    [self identifyAvailableServices];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        DLog(@"login again");

        NSString *username = [alertView textFieldAtIndex:0].text;
        NSString *password = [alertView textFieldAtIndex:1].text;

        [self connectToResolvedService:self.currentService username:username password:password];
    } else {
        [self setErrorStateWithText:NSLocalizedString(@"Connection Error", nil)];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context != kvoContext) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }

    // If possible, verify that there actually was a change
    id old = [change objectForKey:NSKeyValueChangeOldKey];
    id new = [change objectForKey:NSKeyValueChangeNewKey];
    if (old != nil &&
        new != nil &&
        [old isEqual:new]) {
        return;
    }

    // Handle observation
    if (object == [BPTransmissionEngine sharedEngine] &&
        [keyPath isEqualToString:@"client"]) {
        if ([BPTransmissionEngine sharedEngine].client == nil) {
            [self handleDisconnect];
        }
    }
}

@end
