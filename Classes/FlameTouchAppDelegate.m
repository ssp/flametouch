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

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
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

        // Create a new NSNetService browser looking for services of this type,
        // and start it looking. We'll have quite a lot of browsers running at
        // once by the end of this.
        NSLog(@"Found new service type %@", fullType);
        NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
        [browser setDelegate:self];
        [browser searchForServicesOfType:fullType inDomain:@""];
        [serviceBrowsers addObject:browser];
        [browser release];
        
    } else {
        // This case is coming from one of the browsers created in the other
        // branch of the conditional, and represents an actual service running
        // somewhere. Tell the service to resolve itself, we'll display it in
        // the resolver callback.
        NSLog(@"Found new service %@ :: %@", [service type], [service name]);
        [service retain];
        [service setDelegate: self];
        [service resolve];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreServicesComing {
    for (Host* host in hosts) {
        if ([host hasService: service]) {
            NSLog(@"Host %@ has removed service %@", host, service);
            [host removeService:service];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];
            return;
        }
    }
    NSLog(@"Ungrouped service %@ removed!", service);
}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
    NSLog(@"Resolved service %@ as %@", service, [service hostName] );
    Host *thehost = nil;
    for (Host* host in hosts) {
        if ( [[host hostname] isEqualToString:[service hostName]] ) {
            NSLog(@"Found existing host %@", host);
            thehost = host;
        }
    }
    if (thehost == nil) {
        thehost = [[Host alloc] initWithHostname:[service hostName] ipAddress:@"0.0.0.0"];
        [hosts addObject: thehost];
        [hosts sortUsingSelector:@selector(compareByName:)];
        [thehost release];
        NSLog(@"New host %@ created", thehost);
    }

    [thehost addService:service];
    [service release]; // we retained this before resolving it
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
