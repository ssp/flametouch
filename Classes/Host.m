//
//  Host.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "Host.h"
#import "NSNetService+Sortable.h"

@implementation Host

@synthesize hostname;
@synthesize ip;
@synthesize services;

-(id)initWithHostname:(NSString*)hn ipAddress:(NSString*)ipAddress {
  if ([super init] == nil) return nil;
  self.hostname = hn;
  self.ip = ipAddress;
  self.services = [NSMutableArray arrayWithCapacity:10];
  return self;
}

-(int)serviceCount {
  return [self.services count];
}

-(NSString*)name {
  // TODO - strip everything after the last apostrophe to get username
  if ( [self.services count] > 0 )
    return [[self serviceAtIndex:0] name];
  return self.hostname;
}

-(NSNetService*)serviceAtIndex:(int)i {
  return (NSNetService*)[self.services objectAtIndex:i];
}

-(BOOL)hasService:(NSNetService*)service {
  return [self.services containsObject:service];
}

-(void)addService:(NSNetService*)service {
  // TODO - if we have more than one active interface, you'll tend to see
  // services appearing twice. This is not going to happen in the Real World,
  // as iPhones only have one interface, but it makes the siulator confuing
  [self.services addObject:service];
  [self.services sortUsingSelector:@selector(compareByPriority:)];
}

-(void)removeService:(NSNetService*)service {
  NSLog(@"removing %@ from %@", service, self.services);
  [self.services removeObject:service];
}

-(int)compareByName:(Host*)host {
  return [[self name] localizedCaseInsensitiveCompare:[host name]];
}

-(void)dealloc {
  [hostname release];
  [ip release];
  [services release];
  [super dealloc];
}

@end
