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
                       @"iChat 2 presence", @"_presence._tcp.",
                       @"iChat 1 presence", @"_ichat._tcp.", 
                       @"Remote login", @"_ssh._tcp.", 
                       @"SFTP server", @"_sftp._tcp.", 
                       @"Personal file sharing", @"_afpovertcp._tcp.", 
                       @"SubEthaEdit document", @"_hydra._tcp.", 
                       @"Workgroup Manager", @"_workstation._tcp.", 
                       @"FTP server", @"_ftp._tcp.", 
                       @"Xcode distributed compiler", @"_distcc._tcp.", 
                       @"iConquer game server", @"_iconquer._tcp.", 
                       @"AirTunes speaker", @"_raop._tcp.", 
                       @"Airport base station", @"_airport._tcp.", 
                       @"LPR printer sharing", @"_printer._tcp.", 
                       @"Internet Printing Protocol", @"_ipp._tcp.", 
                       @"Remote AppleEvents", @"_eppc._tcp.", 
                       @"Windows file sharing", @"_smb._tcp.", 
                       @"Shared clipboard", @"_clipboard._tcp.", 
                       @"Teleport server", @"_teleport._tcp.", 
                       @"NFS server", @"_nfs._tcp.", 
                       @"OmniWeb shared bookmarks", @"_omni-bookmark._tcp.",
                       @"WebDav server", @"_webdav._tcp.", 
                       @"iPhoto shared photos", @"_dpap._tcp.", 
                       @"Web server", @"_http._tcp.", 
                       @"iTunes shared music", @"_daap._tcp.", 
                       @"iTunes remote control", @"_dacp._tcp.", 
                       @"Spike shared clipboard", @"_spike._tcp.", 
                       @"Xgrid distributed computing", @"_beep._tcp.", 
                       @"NetNewsWire shared feed list", @"_feed-sharing._tcp.", 
                       @"Airport Express printer sharing", @"_riousbprint._tcp.", 
                       @"Safari Web page", @"_webbookmark._tcp.",
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
