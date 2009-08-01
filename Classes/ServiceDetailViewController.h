//
//  ServiceDetailViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 26/06/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Host.h"

@interface ServiceDetailViewController : UITableViewController {
  Host *host;
  NSNetService *service;
  NSArray * TXTRecordKeys;
  NSArray * TXTRecordValues;  
  NSURL * externalURL;
}

@property (nonatomic, retain) Host* host;
@property (nonatomic, retain) NSNetService* service;
@property (nonatomic, retain) NSArray* TXTRecordKeys;
@property (nonatomic, retain) NSArray* TXTRecordValues;
@property (nonatomic, retain) NSURL* externalURL;
@property (readonly) BOOL hasOpenServiceButton;

-(id)initWithHost:(Host*)host service:(NSNetService*)service;

-(UITableViewCell *)propertyCellWithLabel:(NSString*) label andValue:(NSString*) value;
-(UITableViewCell*) standardPropertyCellForRow: (int) row;
-(UITableViewCell*) TXTRecordPropertyCellForRow: (int) row;
-(UITableViewCell *)actionCellForRow:(int)r;
-(void) setupExternalURL;

@end
