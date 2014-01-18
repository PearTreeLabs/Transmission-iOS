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
#import "BPTransmissionTestProtocol.h"
#include <objc/runtime.h>

#define RESOLVE_TIMEOUT 10

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

    if ([NSUserDefaults standardUserDefaults].bp_demoMode) {
        [BPTransmissionTestProtocol registerProtocol];

        Method originalMethod = class_getInstanceMethod([NSNetService class], @selector(hostName));
        NSString *(^block)() = ^{
            return @"demo.local";
        };
        IMP newImpl = imp_implementationWithBlock((id)block);
        method_setImplementation(originalMethod, newImpl);

        NSNetService *service = [[NSNetService alloc] initWithDomain:kBPBonjourBrowserDomainLocal
                                                                type:kBPBonjourBrowserServiceTypeHTTP
                                                                name:@"Demo"
                                                                port:666];

        [self connectToResolvedService:service username:@"demo" password:@"demo"];
    } else {
//        [self identifyAvailableServices];
        [self connectToHost:@"anubis.local" port:9091 username:nil password:nil];
    }

    [[BPTransmissionEngine sharedEngine] addObserver:self forKeyPath:@"client" options:0 context:kvoContext];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

- (void)dealloc {
    [[BPTransmissionEngine sharedEngine] removeObserver:self forKeyPath:@"client" context:kvoContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
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
    [self connectToHost:service.hostName port:service.port username:username password:password];
}

- (void)connectToHost:(NSString *)hostName port:(NSUInteger)port username:(NSString *)username password:(NSString *)password {
    BPTransmissionClient *client = [BPTransmissionClient clientForHost:hostName port:port];
    if (![NSUserDefaults standardUserDefaults].bp_demoMode) {
        [client setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable ||
                status == AFNetworkReachabilityStatusUnknown) {
                [BPTransmissionEngine sharedEngine].client = nil;
            }
        }];
    }

    __weak BPTransmissionClient *weakClient = client;
    [client connectAsUser:username password:password completion:^{
        DLog(@"connected");
        BPTransmissionEngine *engine = [BPTransmissionEngine sharedEngine];
        engine.client = weakClient;
        BPTorrentTableViewController *vc = [[BPTorrentTableViewController alloc] initWithStyle:UITableViewStylePlain];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        nav.navigationBar.barTintColor = [UIColor colorWithRed:0.885 green:0.000 blue:0.066 alpha:1.000];
        nav.navigationBar.translucent = NO;
        nav.navigationBar.barStyle = UIBarStyleBlackTranslucent; // => UIStatusBarStyleLightContent
        [self presentViewController:nav animated:YES completion:nil];
    } error:^(NSError *error) {
        DLog(@"connection error: %@", error);
        BOOL needsAuth = NO;
        id response = [error.userInfo objectForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
            needsAuth = (((NSHTTPURLResponse *)response).statusCode == 401);
        }

        if (needsAuth) {
            NSString *displayName = hostName;
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

    BOOL animated = ([UIApplication sharedApplication].applicationState == UIApplicationStateActive);
    [self dismissViewControllerAnimated:animated completion:nil];
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

#pragma mark - App Lifecycle

- (void)didBecomeActive:(NSNotification *)note {
    if (self.presentedViewController == nil) {
        [self identifyAvailableServices];
    }
}

- (void)didEnterBackground:(NSNotification *)note {
    [[BPTransmissionEngine sharedEngine] stopUpdates];
    [[BPTransmissionEngine sharedEngine].client disconnect];
    [BPTransmissionEngine sharedEngine].client = nil;
}

@end
