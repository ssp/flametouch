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
    [services sortUsingSelector:@selector(sortByPriorityOrder:)];
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
