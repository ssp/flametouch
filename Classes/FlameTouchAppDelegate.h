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

@interface FlameTouchAppDelegate : NSObject <UIApplicationDelegate> {
  
  UIWindow *window;
  UINavigationController *navigationController;
  
  NSNetServiceBrowser *metaBrowser;
  NSMutableArray *serviceBrowsers;
  NSMutableArray *hosts;

}

- (NSMutableArray*)hosts;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) NSMutableArray* hosts;
@property (nonatomic, retain) NSMutableArray* serviceBrowsers;

@end

