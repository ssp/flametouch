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

-(id)initWithHostname:(NSString*)hn ipAddress:(NSString*)ipAddress;
-(NSString*)hostname;
-(NSString*)ip;
-(NSString*)name;
-(NSNetService*)serviceAtIndex:(int)i;
-(void)addService:(NSNetService*)service;
-(BOOL)hasService:(NSNetService*)service;
-(void)removeService:(NSNetService*)service;
-(int)serviceCount;
-(int)compareByName:(Host*)host;

@end
