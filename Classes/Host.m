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
    self = [super init];
    if (self != nil) {
        hostname = [hn retain];
        services = [[NSMutableArray alloc] initWithCapacity:10];
    }
    return self;
}

-(NSString*)hostname {
    return hostname;
}

-(int)serviceCount {
    return [services count];
}

-(NSString*)name {
    return hostname;
    if ( [services count] > 0 )
        return [[self serviceAtIndex:0] name];
    return @"NO SERVICES (can't happen)";
}

-(NSNetService*)serviceAtIndex:(int)i {
    return (NSNetService*)[services objectAtIndex:i];
}

-(void)addService:(NSNetService*)service {
    [services addObject:service];
}
    

@end
