//
//  NSNetService+Sortable.h
//  FlameTouch
//
//  Created by Tom Insam on 26/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNetService (Sortable)
-(int)sortByPriorityOrder:(NSNetService*)service;
@end
