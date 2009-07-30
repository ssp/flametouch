//
//  FlameTouchAppDelegate.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright jerakeen.org 2008. All rights reserved.
//

#import "FlameTouchAppDelegate.h"
#import "RootViewController.h"
#import "ServiceType.h"
// socket resolving/nasty C-level things
#include <netinet/in.h>
#include <arpa/inet.h>



@implementation FlameTouchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize hosts;
@synthesize serviceTypes;
@synthesize serviceBrowsers;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  // Start the spinner on a blank app screen to indicate that we're thinking..
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  self.serviceBrowsers = [[[NSMutableArray alloc] initWithCapacity: 40] autorelease];
  self.hosts = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];
  self.serviceTypes = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];

  // Configure and show the window
  [window addSubview:[navigationController view]];
  [window makeKeyAndVisible];
  
  // meta-discovery
  metaBrowser = [[NSNetServiceBrowser alloc] init];
  [metaBrowser setDelegate:self];
  [metaBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
  
  // in a couple of seconds, report if we have no wifi
  [self performSelector:@selector(checkWifi) withObject:nil afterDelay:5.0];
  
}

-(void)refreshList {

  // destroy arrays and discovery services
  for (NSNetServiceBrowser* browser in self.serviceBrowsers) {
    [browser setDelegate:nil];
  }
  self.serviceBrowsers = nil;
  self.hosts = nil;
	self.serviceTypes = nil;
  [metaBrowser setDelegate:nil];
  [metaBrowser release];

  // rebuild arrays
  self.serviceBrowsers = [[[NSMutableArray alloc] initWithCapacity: 40] autorelease];
  self.hosts = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];
	self.serviceTypes = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];

  // report blank lists.
  [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];

  // restart metabrowser
  metaBrowser = [[NSNetServiceBrowser alloc] init];
  [metaBrowser setDelegate:self];
  [metaBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];

}

- (void)checkWifi {
  if (![[Reachability sharedReachability] localWiFiConnectionStatus]) {
    [[[[UIAlertView alloc] initWithTitle:@"No WiFi connection" message:@"We're not connected to a WiFi network here. Flame can only find services on the local network, so without WiFi, it's not going to be very useful." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease] show];
  }
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
    NSNetServiceBrowser *browser = [[NSNetServiceBrowser alloc] init];
    [browser setDelegate:self];
    [browser searchForServicesOfType:fullType inDomain:@""];
    [self.serviceBrowsers addObject:browser];
    [browser release];
    
  } else {
    // This case is coming from one of the browsers created in the other
    // branch of the conditional, and represents an actual service running
    // somewhere. Tell the service to resolve itself, we'll display it in
    // the resolver callback.
    [service retain]; // released in didResolveAddress / didNotResolve
    [service setDelegate:self];
    [service resolveWithTimeout:20]; // in seconds
  }
  
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreServicesComing {
  NSMutableArray *toRemove = [[NSMutableArray alloc] init];
  for (Host* host in self.hosts) {
    if ([host hasService:service]) {
      [host removeService:service];
      if ([host serviceCount] == 0) {
        [toRemove addObject:host];
      }
      break; // found it
    }
  }
  // Can't mutate while iterating
  for (Host *host in toRemove) {
    NSLog(@"No services remaining on host %@, removing", host);
    [self.hosts removeObject:host];
  }
  [toRemove release];
  

	ServiceType * serviceType;
	for (serviceType in self.serviceTypes) {
		NSUInteger index = [self.serviceTypes indexOfObject:service];
		if (index != NSNotFound) {
			[self.serviceTypes removeObjectAtIndex:index];
			break;
		}
	}
	
	if ([serviceType.services count] == 0) {
		[self.serviceTypes removeObject:serviceType];
	}
	
  
  [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];

}

- (void)netServiceDidResolveAddress:(NSNetService *)service {
  Host *thehost = nil;
  struct sockaddr_in* sock = (struct sockaddr_in*)[((NSData*)[[service addresses] objectAtIndex:0]) bytes];
  NSString *ip = [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
  
  for (Host* host in self.hosts) {
    if ( [host.hostname isEqualToString:[service hostName]] ) {
      thehost = host;
    }
  }
  if (thehost == nil) {
    thehost = [[Host alloc] initWithHostname:[service hostName] ipAddress:ip];
    [self.hosts addObject: thehost];
    [self.hosts sortUsingSelector:@selector(compareByName:)];
    [thehost release];
  }
  
  [thehost addService:service];

	ServiceType * theServiceType = nil;
	for (ServiceType * serviceType in self.serviceTypes) {
		if ([serviceType.name isEqualToString:[service type]]) {
			theServiceType = serviceType;
			break;
		}
	}
	if (theServiceType == nil) {
		theServiceType = [ServiceType serviceTypeForService:service];
		[self.serviceTypes addObject:theServiceType];
		[self.serviceTypes sortUsingSelector:@selector(compareByName:)];
	}
	[theServiceType addService:service];	
	
	[service setDelegate:nil]; // avoid circular memory loops
	[service autorelease]; // we retained this before resolving it, but I don't want to release it in its own callback

  [service stop];
  [service setDelegate:nil]; // avoid circular memory loops
  [service autorelease]; // we retained this before resolving it, but I don't want to release it in its own callback
  [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];

	
  // We're now displaying at least one thing. Stop the spinner, as there's now
  // other activity to indicate that we did something.
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
  NSLog(@"Did not resolve service %@: %@", service, errorDict);
  //[service release]; // we retained this before resolving it
}


- (Host*) hostForService: (NSNetService*) service {
	Host * result = nil;
	for (Host * host in self.hosts) {
		if ([host.services containsObject:service]) {
			result = host;
			break;
		}
	}
	return result;
}


- (NSInteger) displayMode {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"display mode"];
}

- (void) setDisplayMode: (NSInteger) newDisplayMode {
	if (self.displayMode != newDisplayMode) {
		[[NSUserDefaults standardUserDefaults] setInteger:newDisplayMode forKey:@"display mode"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];
	}
}




- (void)dealloc {
  [navigationController release];
  [window release];
  [metaBrowser release];
  self.serviceBrowsers = nil;
  self.hosts = nil;
  self.serviceTypes = nil;
  [super dealloc];
}

@end
