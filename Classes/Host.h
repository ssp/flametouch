//
//  Host.h
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Host : NSObject {
  NSString *hostname;
  NSString *ip;
  NSMutableArray *services;
  
}

@property (nonatomic, retain) NSString *hostname;
@property (nonatomic, retain) NSString *ip;
@property (nonatomic, retain) NSMutableArray *services;

-(id)initWithHostname:(NSString*)hn ipAddress:(NSString*)ipAddress;

-(NSString*)name;
-(NSString*)details;
-(NSNetService*)serviceAtIndex:(int)i;
-(void)addService:(NSNetService*)service;
-(BOOL)hasService:(NSNetService*)service;
-(void)removeService:(NSNetService*)service;
-(int)serviceCount;
-(int)compareByName:(Host*)host;


@end
