//
//  ServiceViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Host.h"

@interface ServiceViewController : UITableViewController {
    Host *host;
    NSDictionary *serviceNames;
}

- (id)initWithHost:(Host*)thehost;

@end
