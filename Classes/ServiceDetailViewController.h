//
//  ServiceDetailViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 26/06/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Host.h"
#import "Utility.h"

@interface ServiceDetailViewController : UITableViewController {
  Host *host;
  NSNetService *service;
  NSDictionary *other;
}

@property (nonatomic, retain) Host* host;
@property (nonatomic, retain) NSNetService* service;
@property (nonatomic, retain) NSDictionary *other;

-(id)initWithHost:(Host*)host service:(NSNetService*)service;
-(UITableViewCell *)propertyCellForRow:(int)r;
-(UITableViewCell *)actionCellForRow:(int)r;
-(NSURL*)externalURL;

@end
