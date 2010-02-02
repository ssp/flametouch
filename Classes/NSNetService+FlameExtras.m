/*
  NSNetService+FlameExtras.m
  FlameTouch

  Created by Tom Insam on 26/11/2008.
 
  
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

#import "NSNetService+FlameExtras.h"
#import "FlameTouchAppDelegate.h"
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NSNetService (FlameExtras)

-(NSComparisonResult) compareByType:(NSNetService*)service {
	NSString* myName = self.humanReadableType;
	if ([myName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		myName = [myName substringFromIndex:1];
	}
	NSString* theirName = service.humanReadableType;
	if ([theirName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		theirName = [theirName substringFromIndex:1];
	}
	
	return [myName localizedCaseInsensitiveCompare:theirName];
}


-(NSComparisonResult) compareByTypeAndName:(NSNetService*)service {
  NSComparisonResult result = [self compareByType:service];
  if (result == NSOrderedSame) {
    result = [[self name] localizedCaseInsensitiveCompare:[service name]];
  }
  return result;
}


-(NSComparisonResult) compareByHostAndTitle: (NSNetService*) service {
  NSComparisonResult result = [self.hostnamePlus compare:service.hostnamePlus options:NSLiteralSearch];
  if (result == NSOrderedSame) {
    result = [self.name localizedCaseInsensitiveCompare:service.name];
  }
  return result;
}


-(NSString*) humanReadableType {
	NSString * result = [[NSBundle mainBundle] localizedStringForKey:[self type] value:nil table:@"ServiceNames"];
	return result;
}


-(BOOL) humanReadableTypeIsDistinct {
	return ![self.humanReadableType isEqualToString: [self type]];
}


-(NSString*) hostIPString {
  if ( [[self addresses] count] > 0 ) {
	  NSData *address = ((NSData*)[[self addresses] objectAtIndex:0]);
	  // I've seen this be nil. But I can't reproduce any more..
	  if (address) {
		  struct sockaddr_in* sock = (struct sockaddr_in*)[address bytes];
		  NSString *ip = [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
		  return ip;
	  } else {
		  return @"-";
	  }
  }
}


-(NSString*) hostnamePlus {
	NSString * result = [self hostName];
	if (result == nil) {
    NSData *address = ((NSData*)[[self addresses] objectAtIndex:0]);
    // I've seen this be nil. But I can't reproduce any more..
    if (address) {
      struct sockaddr_in* sock = (struct sockaddr_in*)[address bytes];
  		result = [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
    } else {
      result = @"-";
    }
	}
	return result;
}


/*
 Returns all-caps protocol type, e.g. TCP in most cases.
*/
- (NSString*) protocolType {
  NSRange protocolRange = NSMakeRange([self.type length] - 4 , 3);
	NSString* protocolType = [[self.type substringWithRange:protocolRange] uppercaseString];
  return protocolType;
}


/*
 Returns a string with the port number for TCP ports.
 Returns a string with the protocol and the port number for non-TCP ports.
*/
- (NSString*) portInfo {
	NSString* portInfo;
  if ([self.protocolType isEqualToString:@"TCP"]) {
    // don't mention the TCP protocol
    portInfo = [NSString stringWithFormat:NSLocalizedString(@"%i", @"format for printing the port number"), [self port]];
  }
  else {
    portInfo = [NSString stringWithFormat:NSLocalizedString(@"%@ %i", @"format for printing the protocol type and port number"), self.protocolType, [self port]];
  }
	return portInfo;
}



/*
 Determines external URL of this service and returns it.
 Returns nil if there is no URL
*/ 
-(NSURL*) externalURL {
  NSString * URLString = nil;
  NSString * myType = [self type];
  
  id protocol = [((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).serviceURLs objectForKey:myType];
  
  if (protocol != nil) {
    /* 
     There could be several protocols for a service type. Choose the one to use as follows:
     1. Use the first service type that can be opened by an application if possible or
     2. Use the first service type in the list.
    */
    NSArray * protocols = nil;
    if ([protocol isKindOfClass:[NSArray class]]) {
      protocols = protocol;
    }
    else if ([protocol isKindOfClass:[NSString class]]) {
      protocols = [NSArray arrayWithObject:protocol];
    }
    
    NSString * protocolName = nil;
    NSInteger defaultPort = 0;
    for (NSString * myProtocol in protocols) {
      NSArray * protocolAndPort = [myProtocol componentsSeparatedByString:@":"];
      NSString * myProtocol;
      NSInteger myPort = 0;
      myProtocol = [protocolAndPort objectAtIndex:0];
      if ( [protocolAndPort count] > 1 ) {
        myPort = [[protocolAndPort objectAtIndex:1] integerValue];
      }
      NSURL * URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@://localhost", myProtocol]];
      if ([[UIApplication sharedApplication] canOpenURL:URL]) {
        protocolName = myProtocol;
        defaultPort = myPort;
        break;
      }
    }
    if (protocolName == nil) {
      NSArray * protocolAndPort = [[protocols objectAtIndex:0] componentsSeparatedByString:@":"];
      protocolName = [protocolAndPort objectAtIndex:0];
      if ( [protocolAndPort count] > 1 ) {
        defaultPort = [[protocolAndPort objectAtIndex:1] integerValue];
      }
    }
    
        
    /* Create URL with:
     1. protocol name
     2. user name and password if available
     3. host name if possible, otherwise use IP address
     4. port number if it differs from the default port number for the protocol
     5. path if available
    */
    NSDictionary * TXTRecordDict = [NSNetService dictionaryFromTXTRecordData:[self TXTRecordData]];

    NSString * userAndPassword = @"";
    NSData * TXTData = [TXTRecordDict objectForKey:@"u"];
    if (TXTData != nil) {
      NSString * userName = [[[NSString alloc] initWithData:TXTData encoding:NSUTF8StringEncoding] autorelease];
      NSString * password = nil;
      if (userName != nil) {
        TXTData = [TXTRecordDict objectForKey:@"p"];
        if (TXTData != nil) {
          password = [[[NSString alloc] initWithData:TXTData encoding:NSUTF8StringEncoding] autorelease];
        }
        if (password != nil) {
          userAndPassword = [NSString stringWithFormat:@"%@:%@@", userName, password];
        }
        else {
          userAndPassword = [NSString stringWithFormat:@"%@@", userName];
        }
      }
    }

    NSString * hostName = [self hostName];
    if (hostName == nil) {
      hostName = self.hostIPString;
    }
    
    NSString * portNumber = @"";
    if ([self port] != defaultPort) {
      portNumber = [NSString stringWithFormat:@":%i", [self port]];
    }
    
    NSString * path = @"";
    TXTData = [TXTRecordDict objectForKey:@"path"];
    if (TXTData != nil) {
      NSString * thePath = [[[NSString alloc] initWithData:TXTData encoding:NSUTF8StringEncoding] autorelease];
      if (thePath != nil) {
        path = [NSString stringWithFormat:@"/%@", thePath];
      }
    }
    
    URLString = [NSString stringWithFormat:@"%@://%@%@%@%@", protocolName, userAndPassword, hostName, portNumber, path];
    
  }
  else if ( [myType isEqualToString:@"_urlbookmark._tcp."] ) {
    NSDictionary * TXTRecordDict = [NSNetService dictionaryFromTXTRecordData:[self TXTRecordData]];
    NSData * URLData = [TXTRecordDict objectForKey:@"URL"];
    if (URLData != nil) {
      URLString = [[[NSString alloc] initWithData:URLData encoding:NSUTF8StringEncoding] autorelease];
    }
  }
    
  NSURL * result = nil;
  if (URLString != nil) {
    result = [NSURL URLWithString:URLString];
  }
  
  return result;
}



/*
 Determines external URL of this service and returns it if there is an application that can open it.
 nil is returned otherwise
 */ 
-(NSURL*) openableExternalURL {
  NSURL * URL = self.externalURL;
  if (URL != nil) {
    if (![[UIApplication sharedApplication] canOpenURL:URL]) {
      URL = nil;
    }
  }
  return URL;
}


@end
