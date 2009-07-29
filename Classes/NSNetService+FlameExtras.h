//
//  NSNetService+Sortable.h
//  FlameTouch
//
//  Created by Tom Insam on 26/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNetService (FlameExtras)

-(int)compareByPriority:(NSNetService*)service;
-(NSComparisonResult)compareByName:(NSNetService*)service;

@property (readonly) NSString * humanReadableType;
@property (readonly) BOOL humanReadableTypeIsDistinct;
@property (readonly) NSString * hostnamePlus;
@property (readonly) NSString * detailedPortInfo;

@end
