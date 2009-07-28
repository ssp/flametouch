//
//  Constants.m
//  FlameTouch
//
//  Created by Tom Insam on 26/06/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import "Utility.h"

#include <netinet/in.h>
#include <arpa/inet.h>


@implementation Utility

@synthesize serviceNames;

static Utility* sharedConstantsInstance = nil;
+(Utility*)sharedInstance {
  if (!sharedConstantsInstance) {
    sharedConstantsInstance = [[Utility alloc] init];
  }
  return sharedConstantsInstance;
}

-(id)init {
  self = [super init];
  
  self.serviceNames = [NSDictionary dictionaryWithObjectsAndKeys:
                       @"iChat 2 Presence", @"_presence._tcp.",
                       @"iChat 1 Presence", @"_ichat._tcp.", 
                       @"Secure Login", @"_ssh._tcp.", 
                       @"Secure File Sharing", @"_sftp._tcp.", 
                       @"Secure File Sharing (SSH)", @"_sftp-ssh._tcp.", 
                       @"Apple File Server", @"_afpovertcp._tcp.", 
                       @"SubEthaEdit Document", @"_hydra._tcp.", 
                       @"SubEthaEdit Document", @"_see._tcp.", 
                       @"Workgroup Manager", @"_workstation._tcp.", 
                       @"FTP Server", @"_ftp._tcp.", 
                       @"Xcode Distributed Compiler", @"_distcc._tcp.", 
                       @"iConquer Game Server", @"_iconquer._tcp.", 
                       @"AirTunes Speaker", @"_raop._tcp.", 
                       @"Airport Base Station", @"_airport._tcp.", 
                       @"LPR Printer Sharing", @"_printer._tcp.", 
                       @"Internet Printing Protocol", @"_ipp._tcp.", 
                       @"Remote AppleEvents", @"_eppc._tcp.", 
                       @"Windows File Sharing", @"_smb._tcp.", 
                       @"Shared Clipboard", @"_clipboard._tcp.", 
                       @"Teleport Server", @"_teleport._tcp.", 
                       @"NFS Server", @"_nfs._tcp.", 
                       @"OmniWeb Shared Bookmarks", @"_omni-bookmark._tcp.",
                       @"WebDAV Server", @"_webdav._tcp.", 
                       @"iPhoto Shared Photos", @"_dpap._tcp.", 
                       @"Web Server", @"_http._tcp.", 
                       @"iTunes Shared Music", @"_daap._tcp.", 
                       @"iTunes Remote Control", @"_dacp._tcp.", 
                       @"Spike Shared Clipboard", @"_spike._tcp.", 
                       @"Xgrid Distributed Computing", @"_beep._tcp.", 
                       @"NetNewsWire Shared Feed List", @"_feed-sharing._tcp.", 
                       @"Airport Express Printer Sharing", @"_riousbprint._tcp.", 
                       @"Safari Web Page", @"_webbookmark._tcp.",
                       @"iTunes Remote Controllable", @"_touch-able._tcp.",
                       @"Screen Sharing", @"_rfb._tcp.",
                       @"Remote Management", @"_net-assistant._udp.",
                       @"DVD or CD Sharing", @"_odisk._tcp.",
                       @"BibDesk Bibliography", @"_bdsk._tcp.",
                       nil
                       ];
  
  return self;
}

-(NSString*)nameForService:(NSNetService*)service {
  NSString *s = [self.serviceNames objectForKey:[service type]];
  if (s) return s;
  return [service type];
}


-(NSString*)hostnameForService:(NSNetService*)service {
  if ([service hostName])
    return [service hostName];
  struct sockaddr_in* sock = (struct sockaddr_in*)[((NSData*)[[service addresses] objectAtIndex:0]) bytes];
  return [NSString stringWithFormat:@"%s", inet_ntoa(sock->sin_addr)];
}

@end
