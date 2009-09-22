//
//  Host.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
// 
//  
//  Copyright (c) 2009 Sven-S. Porst, Tom Insam
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//
//  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
//  for support.
//

#import "Host.h"
#import "NSNetService+FlameExtras.h"
#import "ServiceType.h"

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
  NSString * result;
  if (self.services.count == 1) {
    NSString * serviceName = ((ServiceType*)[self.services objectAtIndex:0]).humanReadableType;
    result = [NSString stringWithFormat:@"%@ (%@) – %@", self.hostname, self.ip, serviceName];
  }
  else {
    result = [self detailsWithCount];
  }
  
  return result;
  
}

-(NSString*) detailsWithCount {
	NSUInteger serviceCount = self.services.count;
	NSString * serviceCountString = @"";
  if (serviceCount == 0) {
    serviceCountString = NSLocalizedString(@"No Services", @"String indicating that no service is advertised on the Host");
  }
	if (serviceCount == 1) {
		serviceCountString = NSLocalizedString(@"1 Service", @"String indicating that single service is advertised on the Host");
	}
	else if (serviceCount > 1) {
		serviceCountString = [NSString stringWithFormat:NSLocalizedString(@"%i Services", @"String indicating that %i (with %i > 1) services are advertised on Host"), serviceCount];
	}
	NSString* details = [NSString stringWithFormat:@"%@ (%@) – %@", self.hostname, self.ip, serviceCountString];
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
		[self.services sortUsingSelector:@selector(compareByTypeAndName:)];
	}
}

-(void)removeService:(NSNetService*)service {
  // NSLog(@"removing %@ from %@", service, self.services);
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
