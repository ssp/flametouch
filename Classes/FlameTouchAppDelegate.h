//
//  FlameTouchAppDelegate.h
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright jerakeen.org 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Host.h"

// to detect network reachability
#import <SystemConfiguration/SystemConfiguration.h>
#import "Reachability.h"

#define SHOWSERVERS 0
#define SHOWSERVICES 1


@interface FlameTouchAppDelegate : NSObject <UIApplicationDelegate> {
  
  UIWindow *window;
  UINavigationController *navigationController;
  
  NSNetServiceBrowser *metaBrowser;
  NSMutableArray *serviceBrowsers;
  NSMutableArray *hosts;
	NSMutableArray *serviceTypes;
}

- (void)refreshList;
- (Host*) hostForService: (NSNetService*) service;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray* hosts;
@property (nonatomic, retain) NSMutableArray* serviceTypes;
@property (nonatomic, retain) NSMutableArray* serviceBrowsers;
@property NSInteger displayMode;
@end

