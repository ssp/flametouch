//
//  NSNetService+FlameExtras.m
//  FlameTouch
//
//  Created by Tom Insam on 26/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "NSNetService+FlameExtras.h"
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NSNetService (FlameExtras)

-(NSComparisonResult) compareByName:(NSNetService*)service {
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


-(NSComparisonResult) compareByHostAndTitle: (NSNetService*) service {
  NSComparisonResult result = [self.hostnamePlus compare:service.hostnamePlus options:NSLiteralSearch];
  if (result == NSOrderedSame) {
    result = [self.name compare:service.name options:NSCaseInsensitiveSearch];
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


-(NSString*) hostnamePlus {
	NSString * result = [self hostName];
	if (result == nil) {
		struct sockaddr_in* sock = (struct sockaddr_in*)[((NSData*)[[self addresses] objectAtIndex:0]) bytes];
		result = [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
	}
	return result;
}


- (NSString*) detailedPortInfo {
	NSRange protocolRange = NSMakeRange([self.type length] - 4 , 3);
	NSString* protocolType = [[self.type substringWithRange:protocolRange] uppercaseString];
	NSString* portInfo = [NSString stringWithFormat:NSLocalizedString(@"%@ port %i", @"format for strings like 'TCP port 80'"), protocolType, [self port]];
	return portInfo;
}

@end
