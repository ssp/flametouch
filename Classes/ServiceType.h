//
//  ServiceType.h
//  FlameTouch
//
//  Created by  Sven on 29.07.09.
//  Copyright 2009 earthlingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ServiceType : NSObject {
	NSString * type;
	NSString * humanReadableType;
	
	NSMutableArray * services;
}

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * humanReadableType;
@property (nonatomic, retain) NSMutableArray * services;
@property (readonly) NSString * details;
@property (readonly) NSString * summary;

+ (id) serviceTypeForService: (NSNetService*) netService;

- (void) addService:(NSNetService*) service;
- (NSComparisonResult) compareByName:(ServiceType*) serviceType;


@end
