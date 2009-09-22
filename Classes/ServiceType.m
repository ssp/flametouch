//
//  ServiceType.m
//  FlameTouch
//
//  Created by  Sven on 29.07.09.
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

#import "ServiceType.h"
#import "NSNetService+FlameExtras.h"

@implementation ServiceType
@synthesize type;
@synthesize humanReadableType;
@synthesize services;

- (id) init {
	self = [super init];
	services = [[NSMutableArray alloc] init];
	return self;
}


+ (id) serviceTypeForService: (NSNetService*) netService {
	ServiceType * newServiceType = [[[ServiceType alloc] init] autorelease];
	newServiceType.type = [netService type];
	newServiceType.humanReadableType = netService.humanReadableType;

	return newServiceType;
}


- (void) dealloc {
	self.services = nil;
	self.type = nil;
	self.humanReadableType = nil;
	[super dealloc];
}



- (void) addService:(NSNetService*) service {
	if (![self.services containsObject:service]) {
		[self.services addObject:service];
		[self.services sortUsingSelector:@selector(compareByHostAndTitle:)];
	}
}


- (NSString*) details {
	NSString * result;
	if ([self.services count] == 1) {
		NSNetService * netService = [self.services objectAtIndex:0];
		result = [NSString stringWithFormat:NSLocalizedString(@"1 Instance: “%@”", @"service information in Service Type list when a single service of that type is available. %@ is the Service name."), [netService name]];
	}
	else {
    NSMutableArray * nameArray = [NSMutableArray arrayWithCapacity:[self.services count]];
		for (NSNetService * netService in self.services) {
			[nameArray addObject:[NSString stringWithFormat:NSLocalizedString(@"“%@”" , @"String %@ in quotation marks"), [netService name]]];
		}
    NSString * nameList = [nameArray componentsJoinedByString:NSLocalizedString(@", ", @"List Item separator, e.g. comma space")];
    
		result = [NSString stringWithFormat:NSLocalizedString(@"%i Instances: %@", @"service information in Service Type list when more than one instance of the service is available. %i is the number of occurrences of the Services, %@ is a string with a list of all service names"), [self.services count], nameList];
	}
	return result;
}


- (NSString *) summary {
	NSString * result = @"";
	
	if ([self.services count] == 1) {
		result = NSLocalizedString(@"Announced once.", @"Heading for Service Type List when exactly one occurrence of the selected service is announced.");
	}
	else if ([self.services count] == 2) {
		result = NSLocalizedString(@"Announced twice.", @"Heading for Service Type List when exactly two occurrences of the selected service are announced.");
	}
	else {
		result = [NSString stringWithFormat:NSLocalizedString(@"Announced %i times.", @"Heading for Service Type List when %i occurrences of the selected service are announced. For %i > 2."), [self.services count]];
	}
	
	return result;
}


- (BOOL) isEqual: (id) otherObject {
  BOOL result = NO;
  if ([otherObject isKindOfClass:[self class]]) {
    result = [((ServiceType*)otherObject).type isEqualToString:self.type];
  }
  return result;
}


- (NSComparisonResult) compareByName:(ServiceType*) serviceType {
	NSString* myName = self.humanReadableType;
	if ([myName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		myName = [myName substringFromIndex:1];
	}
	NSString* theirName = serviceType.humanReadableType;
	if ([theirName rangeOfString:@"_" options:NSLiteralSearch | NSAnchoredSearch].location == 0) {
		theirName = [theirName substringFromIndex:1];
	}
	
	return [myName localizedCaseInsensitiveCompare:theirName];
}

@end
