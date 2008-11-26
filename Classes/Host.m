//
//  Host.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "Host.h"


@implementation Host

-(id)initWithHostname:(NSString*)hn {
    if ([super init] == nil) return nil;
    
    hostname = [hn retain];
    services = [[NSMutableArray alloc] initWithCapacity:10];

    return self;
}

-(NSString*)hostname {
    return hostname;
}

-(NSMutableArray*)services {
    return services;
}

-(int)serviceCount {
    return [services count];
}

-(NSString*)name {
    if ( [services count] > 0 )
        return [[self serviceAtIndex:0] name];
    return hostname;
}

-(NSNetService*)serviceAtIndex:(int)i {
    return (NSNetService*)[services objectAtIndex:i];
}

-(BOOL)hasService:(NSNetService*)service {
    return [services containsObject:service];
}

-(void)addService:(NSNetService*)service {
    [services addObject:service];
    [services sortUsingSelector:@selector(compareWithType:)];
}

-(void)removeService:(NSNetService*)service {
    NSLog(@"removing %@ from %@", service, services);
    [services removeObject:service];
}

-(void)dealloc {
    [hostname release];
    [super dealloc];
}

@end


@interface NSNetService (MySortingMethods)
-(int)compareWithType:(NSNetService*)service;
@end

@implementation NSNetService (MySortingMethods)
-(int)compareWithType:(NSNetService*)service {

        // should not be here.
        NSArray *serviceOrder = [[[NSArray alloc]initWithObjects:
                        @"_presence._tcp.", // ichat 1
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

@end
