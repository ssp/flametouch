/*
  FlameTouchAppDelegate.m
  FlameTouch

  Created by Tom Insam on 24/11/2008.
 
  
  Copyright (c) 2009 Sven-S. Porst, Tom Insam
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
  for support.
*/

#import "FlameTouchAppDelegate.h"
#import "RootViewController.h"
#import "ServiceType.h"
#import "NSNetService+FlameExtras.h"
// socket resolving/nasty C-level things
#include <netinet/in.h>
#include <arpa/inet.h>
#include "RootSplitViewController.h"


@implementation FlameTouchAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize hosts;
@synthesize serviceTypes;
@synthesize serviceBrowsers;
@synthesize serviceURLs;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
{
  // Start the spinner on a blank app screen to indicate that we're thinking..
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
  
  self.serviceBrowsers = [[[NSMutableArray alloc] initWithCapacity: 40] autorelease];
  self.hosts = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];
  self.serviceTypes = [[[NSMutableArray alloc] initWithCapacity: 20] autorelease];

  // Configure and show the window
  
  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    RootSplitViewController* split = [[RootSplitViewController alloc] initWithLeftPane:navigationController];
    [window addSubview:split.view];
  } else {
    [window addSubview:[navigationController view]];
  }
  [window makeKeyAndVisible];
  
  // meta-discovery
  metaBrowser = [[NSNetServiceBrowser alloc] init];
  [metaBrowser setDelegate:self];
  [metaBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@""];
  
  // set up serviceURLs dictionary
  self.serviceURLs = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ServiceURLs" ofType:@"plist"]];
  
  // in a couple of seconds, report if we have no wifi
  [self performSelector:@selector(checkWifi) withObject:nil afterDelay:5.0];
  
	return YES; // happy days are here again
}

-(void)refreshList;
{

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

- (void)checkWifi
{
  if (![[Reachability sharedReachability] localWiFiConnectionStatus]) {
    NSString * title = NSLocalizedString(@"No WiFi connection", @"Title of No WiFi Connection error message");
    NSString * message = NSLocalizedString(@"We're not connected to a WiFi network here. Flame can only find services on the local network, so without WiFi, it's not going to be very useful.", @"Message of No WiFi Connection error message");
    NSString * button = NSLocalizedString(@"OK", @"");
    [[[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:button otherButtonTitles:nil] autorelease] show];
  }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser didNotSearch:(NSDictionary *)errorInfo;
{
  // NSLog(@"Did not search: %@", errorInfo);
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)netServiceBrowser;
{
  // dummy delegate method, we don't care.
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
    // NSLog(@"No services remaining on host %@, removing", host);
    [self.hosts removeObject:host];
  }
  [toRemove release];
  

	ServiceType * serviceType;
	for (serviceType in self.serviceTypes) {
		NSUInteger index = [serviceType.services indexOfObject:service];
		if (index != NSNotFound) {
			[serviceType.services removeObjectAtIndex:index];
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
  
  for (Host* host in self.hosts) {
    if ( [host.hostname isEqualToString:[service hostName]] ) {
      thehost = host;
    }
  }
  if (thehost == nil) {
    thehost = [[Host alloc] initWithHostname:[service hostName] ipAddress:service.hostIPString];
    [self.hosts addObject: thehost];
    [self.hosts sortUsingSelector:@selector(compareByName:)];
    [thehost release];
  }
  
  [thehost addService:service];

	ServiceType * theServiceType = nil;
	for (ServiceType * serviceType in self.serviceTypes) {
		if ([serviceType.type isEqualToString:[service type]]) {
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

  [service stop];
  [service setDelegate:nil]; // avoid circular memory loops
  [service autorelease]; // we retained this before resolving it, but I don't want to release it in its own callback
  [[NSNotificationCenter defaultCenter] postNotificationName:@"newServices" object:self];

	
  // We're now displaying at least one thing. Stop the spinner, as there's now
  // other activity to indicate that we did something.
  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}


- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict {
  //  NSLog(@"Did not resolve service %@: %@", service, errorDict);
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


/*
 Description forthcoming.
*/
- (void) bringDownWestCoastNetworkWithDelay: (NSTimeInterval) delay {

}


- (void)dealloc {
  [navigationController release];
  [window release];
  [metaBrowser release];
  self.serviceBrowsers = nil;
  self.hosts = nil;
  self.serviceTypes = nil;
  self.serviceURLs = nil;
  [super dealloc];
}

@end
