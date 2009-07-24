//
//  ServiceViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "ServiceViewController.h"
#import "ServiceDetailViewController.h"
#import "Utility.h"

@implementation ServiceViewController

#define LABEL_TAG 1

@synthesize host;

- (id)initWithHost:(Host*)thehost {
  if ([super initWithStyle:UITableViewStylePlain] == nil) return nil;
  
  self.host = thehost;
  
  UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 64.0)];
  
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 25.0)];
  label.font = [UIFont systemFontOfSize:16.0];
  label.textAlignment = UITextAlignmentLeft;
  label.textColor = [UIColor blackColor];
  label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  label.text = [self.host name];
  [header addSubview:label];
  [label release];
  
  label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, 300.0, 40.0)];
  label.tag = LABEL_TAG;
  label.font = [UIFont systemFontOfSize:12.0];
  label.textAlignment = UITextAlignmentLeft;
  label.textColor = [UIColor grayColor];
  label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
  label.numberOfLines = 2;
  [header addSubview:label];
  [label release];
  
  UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, header.frame.size.height - 1, 600, 1)];
  line.backgroundColor = [UIColor grayColor];
  [header addSubview:line];
  [line release];
  
  self.tableView.tableHeaderView = header;
  [header release];
  
  self.tableView.delegate = self;
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
  self.title = [self.host name];
  [self setCaption];
  
  return self;
}

-(void) setCaption {
  UILabel *label = (UILabel*)[self.view viewWithTag:LABEL_TAG];
  label.text = [NSString stringWithFormat:@"%@ (%@)\n%d services", self.host.hostname, self.host.ip, [self.host serviceCount]];
}

-(void) newServices:(id)whatever {
  [self.tableView reloadData];
  [self setCaption];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.host serviceCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"ServiceCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, tableView.frame.size.width - 30.0, 25.0)];
    label.font = [UIFont systemFontOfSize:16.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.tag = 1;
    [cell.contentView addSubview:label];
    [label release];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, tableView.frame.size.width - 30.0, 20.0)];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.tag = 2;
    [cell.contentView addSubview:label];
    [label release];
  }
  
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
  NSString *text = [[Utility sharedInstance].serviceNames objectForKey:[service type]];
  if (text == nil) {
    ((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@:%i", [service type], [service port]];
  } else {
    ((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@ (%@:%i)", text, [service type], [service port]];
  }
  ((UILabel*)[cell viewWithTag:2]).text = [service name];
  
  cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
  ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithHost:self.host service:service];
  [self.navigationController pushViewController:sdvc animated:TRUE];
  [sdvc release];
}

- (void)dealloc {
  [self.host release];
  [super dealloc];
}


@end
