//
//  ServiceDetailViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 26/06/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import "ServiceDetailViewController.h"


@implementation ServiceDetailViewController

@synthesize host;
@synthesize service;
@synthesize other;

-(id)initWithHost:(Host*)hst service:(NSNetService*)srv {
  if ([super initWithStyle:UITableViewStyleGrouped] == nil) return nil;
  
  self.host = hst;
  self.service = srv;
  self.other = [NSNetService dictionaryFromTXTRecordData:[self.service TXTRecordData]];

  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 64.0)];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 25.0)];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textAlignment = UITextAlignmentLeft;
  label.textColor = [UIColor blackColor];
  label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  label.text = [host name];
  [header addSubview:label];
  [label release];
  
  //self.tableView.tableHeaderView = header;
  [header release];
  
  self.tableView.delegate = self;

  self.title = [[Utility sharedInstance] nameForService:self.service];
  
  return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([self externalURL])
    return 2;
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  if (section == 0) {
    return 3 + [other count];
  } else {
    return 1;
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    return [self propertyCellForRow:indexPath.row];
  } else {
    return [self actionCellForRow:indexPath.row];
  }
}

-(UITableViewCell *)propertyCellForRow:(int)row {
  static NSString *CellIdentifier = @"PropertyCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 1.0, 90.0, cell.frame.size.height - 3)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = UITextAlignmentRight;
    label.textColor = [UIColor blackColor];
    label.tag = 1;
    [cell.contentView addSubview:label];
    [label release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(100.0, 1.0, cell.frame.size.width - 130, cell.frame.size.height - 3)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    label.tag = 2;
    [cell.contentView addSubview:label];
    [label release];
  }
  
  NSString *caption;
  NSString *value;
  if (row == 0) {
    caption = @"host";
    value = [[Utility sharedInstance] hostnameForService:self.service];
  } else if (row == 1) {
    caption = @"port";
    value = [NSString stringWithFormat:@"%i", [service port]];
  } else if (row == 2) {
    caption = @"description";
    value = [[Utility sharedInstance] nameForService:self.service];
  } else {
    caption = [[other allKeys] objectAtIndex:row - 3];
    value = [[[NSString alloc] initWithData:[other objectForKey:caption] encoding:NSUTF8StringEncoding] autorelease];
  }
  
  if (caption == nil) caption = @"";
  if (value == nil) value = @"";
  ((UILabel*)[cell viewWithTag:1]).text = caption;
  ((UILabel*)[cell viewWithTag:2]).text = value;

  // try to parse the value as an url - if we can, then this cell is
  // clickable. Make it blue. I'd like it underlined as well, but that
  // seems to be lots harder.
  NSURL *url = [NSURL URLWithString:value];
  if (url && [url scheme] && [url host]) {
    [ ((UILabel*)[cell viewWithTag:2]) setTextColor:[UIColor blueColor] ];
  } else {
    [ ((UILabel*)[cell viewWithTag:2]) setTextColor:[UIColor grayColor] ];
  }

  return cell;
}

-(UITableViewCell *)actionCellForRow:(int)row {
  static NSString *CellIdentifier = @"ActionCell";
  UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 1.0, cell.frame.size.width - 60, cell.frame.size.height - 3)];
    label.font = [UIFont systemFontOfSize:14.0];
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.tag = 1;
    [cell.contentView addSubview:label];
    [label release];

  }
  ((UILabel*)[cell viewWithTag:1]).text = @"Open in browser";
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0) {
    if (indexPath.row > 3) {
      NSString *caption = [[other allKeys] objectAtIndex:indexPath.row - 3];
      NSString *value = [[[NSString alloc] initWithData:[other objectForKey:caption] encoding:NSUTF8StringEncoding] autorelease];
      NSURL *url = [NSURL URLWithString:value];
      if (url && [url scheme] && [url host]) {
        [[UIApplication sharedApplication] openURL:url];
        return;
      }
    }
  } else {
    if (indexPath.row == 0) {
      [[UIApplication sharedApplication] openURL:[self externalURL]];
      return;
    }
  }
  
}

-(NSURL*)externalURL {
  if ( [[service type] isEqualToString:@"xxx"] ) { // TODO - sven's thing
    return [NSURL URLWithString:[service name]];
    
  } else if ( [[service type] isEqualToString:@"_http._tcp."] ) {
    NSString *url;
    if ([service port] == 80) {
      url = [NSString stringWithFormat:@"http://%@/", host.ip];
    } else {
      url = [NSString stringWithFormat:@"http://%@:%i/", host.ip, [service port]];
    }
    return [NSURL URLWithString:url];
  }
  return nil;
}



- (void)dealloc {
  [self.host release];
  [self.service release];
  [super dealloc];
}


@end
