//
//  FlameTouchAppDelegate.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright jerakeen.org 2008. All rights reserved.
//

#import "FlameTouchAppDelegate.h"
#import "RootViewController.h"

@implementation FlameTouchAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
    services = [[NSMutableArray alloc] initWithCapacity: 100];
    serviceBrowsers = [[NSMutableArray alloc] initWithCapacity: 20];
    hosts = [[NSMutableArray alloc] initWithCapacity: 20];
    
    // meta-discovery
    metaBrowser = [[NSNetServiceBrowser alloc]init];
    [metaBrowser setDelegate:self];
    [metaBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];

	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}

- (NSMutableArray*)services {
    return services;
}

- (NSMutableArray*)hosts {
    return hosts;
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo {
    NSLog(@"Did not search: %@", errorInfo);
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser {
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreServicesComing {
    if ( [[service type] isEqualToString:@"_tcp.local."] || [[service type] isEqualToString:@"_udp.local."] ) {
        // new meta-service
        NSString *fullType;
        if ( [[service type] isEqualToString:@"_tcp.local."] )
            fullType = [NSString stringWithFormat:@"%@._tcp", [service name] ];
        else
            fullType = [NSString stringWithFormat:@"%@._udp", [service name] ];

        NSLog(@"Found new service type %@", fullType);

        NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
        [browser setDelegate:self];
        [browser searchForServicesOfType:fullType inDomain:@""];
        [serviceBrowsers addObject:[browser autorelease]];
        
    } else {
        NSLog(@"Found new service %@ :: %@", [service type], [service name]);
        [service setDelegate: self];
        [service resolve];
        [services addObject:service];
    }
    if (!moreServicesComing) {
        // we're done with this batch, signal the front end that it should update
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:nil];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreServicesComing {
    NSLog(@"removed service %@", netService);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)netServiceBrowser {
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"Resolved service %@ as %@", service, [service hostName] );
    for (Host* host in hosts) {
        if ( [[host hostname] isEqualToString:[service hostName]] ) {
            NSLog(@"Found existing host %@", host);
            [ host addService:service ];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];
            return;
        }
    }
    Host *host = [[Host alloc] initWithHostname:[service hostName]];
    NSLog(@"New host %@ created", host);
    [host addService:service];
    [hosts addObject: host];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
    NSLog(@"Did not resolve service %@: %@", service, errorDict);
}

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
