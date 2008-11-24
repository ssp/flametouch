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
    NSMutableArray *services;

}

-(id)initWithHostname:(NSString*)hn;

-(NSString*)hostname;
-(NSString*)name;
-(NSNetService*)serviceAtIndex:(int)i;
-(void)addService:(NSNetService*)service;
-(int)serviceCount;

@end