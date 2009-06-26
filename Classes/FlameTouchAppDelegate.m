//
//  FlameTouchAppDelegate.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright jerakeen.org 2008. All rights reserved.
//

#import "FlameTouchAppDelegate.h"
#import "RootViewController.h"

// socket resolving/nasty C-level things
#include <netinet/in.h>
#include <arpa/inet.h>


@implementation FlameTouchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize hosts;
@synthesize serviceBrowsers;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
  
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  self.serviceBrowsers = [[[NSMutableArray alloc] initWithCapacity: 40] autorelease];
  self.hosts = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];
  
  // meta-discovery
  metaBrowser = [[NSNetServiceBrowser alloc] init];
  [metaBrowser setDelegate:self];
  [metaBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
  
  // Configure and show the window
  [window addSubview:[navigationController view]];
  [window makeKeyAndVisible];
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
    [service resolve];
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
  [service release]; // we retained this before resolving it
  [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
  NSLog(@"Did not resolve service %@: %@", service, errorDict);
  //[service release]; // we retained this before resolving it
}

- (void)dealloc {
  [navigationController release];
  [window release];
  [metaBrowser release];
  [self.serviceBrowsers release];
  [self.hosts release];
  [super dealloc];
}

@end
