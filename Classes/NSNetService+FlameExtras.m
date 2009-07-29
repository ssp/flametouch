//
//  NSNetService+Sortable.m
//  FlameTouch
//
//  Created by Tom Insam on 26/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "NSNetService+FlameExtras.h"
#include <netinet/in.h>
#include <arpa/inet.h>

@implementation NSNetService (FlameExtras)

-(int)compareByPriority:(NSNetService*)service {
  
  // should not be here.
  NSArray *serviceOrder = [[[NSArray alloc]initWithObjects:
                            @"_presence._tcp.", // ichat 2
                            @"_ichat._tcp.", 
                            @"_ssh._tcp.", 
                            @"_sftp._tcp.", 
                            @"_afpovertcp._tcp.", 
                            @"_hydra._tcp.", 
                            @"_workstation._tcp.", 
                            @"_ftp._tcp.", 
                            @"_distcc._tcp.", 
                            @"_iconquer._tcp.", 
                            @"_raop._tcp.", 
                            @"_airport._tcp.", 
                            @"_printer._tcp.", 
                            @"_ipp._tcp.", 
                            @"_eppc._tcp.", 
                            @"_smb._tcp.", 
                            @"_clipboard._tcp.", 
                            @"_teleport._tcp.", 
                            @"_nfs._tcp.", 
                            @"_omni-bookmark._tcp.",
                            @"_webdav._tcp.", 
                            @"_dpap._tcp.", 
                            @"_http._tcp.", 
                            @"_daap._tcp.", 
                            @"_dacp._tcp.", 
                            @"_spike._tcp.", 
                            @"_beep._tcp.", 
                            @"_feed-sharing._tcp.", 
                            @"_riousbprint._tcp.", 
                            nil
                            ] autorelease];
  
  int i1 = [serviceOrder indexOfObject:[self type]];
  int i2 = [serviceOrder indexOfObject:[service type]];
  
  if (i1 < i2)
    return NSOrderedAscending;
  else if (i1 == i2)
    return NSOrderedSame;
  else
    return NSOrderedDescending;
}


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
