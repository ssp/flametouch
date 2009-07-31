//
//  Host.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "Host.h"
#import "NSNetService+FlameExtras.h"

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
  NSString* result = self.hostname;
  NSRange dotLocalRange = [self.hostname rangeOfString:@".local." options:NSAnchoredSearch | NSBackwardsSearch];
  if (dotLocalRange.location != NSNotFound) {
    result = [self.hostname substringToIndex:dotLocalRange.location];
  }
  return result;
}

-(NSString*) details {
	NSUInteger serviceCount = self.services.count;
	NSString * serviceCountString = @"";
	if (serviceCount == 1) {
		serviceCountString = NSLocalizedString(@"1 service", @"String appended to Host description when a single service is present on the Host");
	}
	else if (serviceCount > 1) {
		serviceCountString = [NSString stringWithFormat:NSLocalizedString(@"%i Services", @"String appended to Host description when %i (with %i > 1) services are present on Host"), serviceCount];
	}
	NSString* details = [NSString stringWithFormat:@"%@ (%@) – %@.", self.hostname, self.ip, serviceCountString];
	return details;
}

-(NSNetService*)serviceAtIndex:(int)i {
  return (NSNetService*)[self.services objectAtIndex:i];
}

-(BOOL)hasService:(NSNetService*)service {
  return [self.services containsObject:service];
}

-(void)addService:(NSNetService*)service {
	if (![self hasService:service]) {
		[self.services addObject:service];
		[self.services sortUsingSelector:@selector(compareByName:)];
	}
}

-(void)removeService:(NSNetService*)service {
  NSLog(@"removing %@ from %@", service, self.services);
  [self.services removeObject:service];
}


- (BOOL) isEqual: (id) otherObject {
  BOOL result = NO;
  if ([otherObject isKindOfClass:[self class]]) {
    result = [((Host*)otherObject).hostname isEqualToString:self.hostname];
  }
  return result;
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
