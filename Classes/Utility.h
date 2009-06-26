//
//  Constants.h
//  FlameTouch
//
//  Created by Tom Insam on 26/06/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject {
  NSDictionary *serviceNames;
}

@property (nonatomic, retain) NSDictionary* serviceNames;

+(Utility*)sharedInstance;

-(NSString*)nameForService:(NSNetService*)service;
-(NSString*)hostnameForService:(NSNetService*)service;

@end
