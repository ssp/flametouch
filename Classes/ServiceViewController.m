//
//  ServiceViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "ServiceViewController.h"
#import "ServiceDetailViewController.h"
#import "NSNetService+FlameExtras.h"
#import "Host.h"
#import "ServiceType.h"
#import "FlameTouchAppDelegate.h"

@implementation ServiceViewController

- (id) init {
	if ([super initWithStyle:UITableViewStylePlain] == nil) return nil;

	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.tableView.frame.size.width, 25.0)];
  header.autoresizingMask = UIViewAutoresizingFlexibleWidth;

	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 3.0, self.tableView.frame.size.width -16.0, 18.0)];
	label.tag = LABEL_TAG;
	label.font = [UIFont systemFontOfSize:12.0];
	label.textAlignment = UITextAlignmentCenter;
	label.textColor = [UIColor grayColor];
	label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	label.numberOfLines = 2;
	[header addSubview:label];
	[label release];
	
	UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0.0, header.frame.size.height - 1.0, self.tableView.frame.size.width, 1.0)];
	line.backgroundColor = [UIColor grayColor];
  line.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[header addSubview:line];
	[line release];
	
	self.tableView.tableHeaderView = header;
	[header release];
  
	self.tableView.delegate = self;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
	
	return self;
}


- (void) setCaption {}


- (void) newServices:(id) sender {
  [self.tableView reloadData];
	[self setCaption];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"ServiceCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 0.0, tableView.frame.size.width - 8.0, 25.0)];
		label.font = [UIFont boldSystemFontOfSize:16.0];
		label.textAlignment = UITextAlignmentLeft;
		label.textColor = [UIColor blackColor];
		label.highlightedTextColor = [UIColor whiteColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.tag = 1;
		[cell.contentView addSubview:label];
		[label release];
		
		label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 22.0, tableView.frame.size.width - 8.0, 20.0)];
		label.font = [UIFont systemFontOfSize:12.0];
		label.textAlignment = UITextAlignmentLeft;
		label.textColor = [UIColor grayColor];
		label.highlightedTextColor = [UIColor whiteColor];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.tag = 2;
		[cell.contentView addSubview:label];
		[label release];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	return cell;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}

@end




@implementation ServiceByHostViewController

@synthesize host;

- (id)initWithHost:(Host*)thehost {
	self = [super init];
	if (self) {
		self.host = thehost;
		self.title = [self.host name];
		[self setCaption];
	}
	
	return self;
}


-(void) setCaption {
	UILabel *label = (UILabel*)[self.view viewWithTag:LABEL_TAG];
	label.text = host.details;
}


-(void) newServices:(id) sender {
  if ([self.host.services count] == 0) {
    // this Host stopped existing, check whether new services of the same kind appeared and, if so, replace our ServiceType with the new instance
    FlameTouchAppDelegate * delegate = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    for (Host * h in delegate.hosts) {
      if ([h isEqual:self.host]) {
        self.host = h;
        break;
      }
    }
    
  }
  
  [super newServices:sender];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [self.host serviceCount];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	NSNetService *service = [self.host serviceAtIndex:indexPath.row];
	NSString *text = service.humanReadableType;
	if ([text isEqualToString:service.type]) {
		((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@", [service type]];
	} else {
		NSRange firstDot = [service.type rangeOfString:@"." options:NSLiteralSearch];
		NSString * protocolName;
		if (firstDot.location != NSNotFound && firstDot.location > 0) {
			protocolName = [service.type substringWithRange:NSMakeRange(1, firstDot.location - 1)];
		}
		else {
			protocolName = service.type;
		}
		
		((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@ [%@]", text, protocolName];
	}
	NSString* portInfo = service.detailedPortInfo;
	((UILabel*)[cell viewWithTag:2]).text = [NSString stringWithFormat:@"%@ – %@", [service name], portInfo];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  NSNetService *service = [self.host serviceAtIndex:indexPath.row];
  ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithHost:self.host service:service];
  [self.navigationController pushViewController:sdvc animated:TRUE];
  [sdvc release];
}


- (void)dealloc {
  self.host = nil;
  [super dealloc];
}

@end






@implementation ServiceByTypeViewController

@synthesize serviceType;

- (id)initWithServiceType:(ServiceType*) theServiceType {
	self = [super init];
	if (self) {
		self.serviceType = theServiceType;
		self.title = self.serviceType.humanReadableType;
		[self setCaption];
	}
	
	return self;
}


-(void) setCaption {
	UILabel *label = (UILabel*)[self.view viewWithTag:LABEL_TAG];
	label.text = serviceType.summary;
}


-(void) newServices:(id) sender {
  if ([self.serviceType.services count] == 0) {
    // this ServiceType stopped existing, check whether new services of the same kind appeared and, if so, replace our ServiceType with the new instance
    FlameTouchAppDelegate * delegate = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]);
    
    for (ServiceType * sT in delegate.serviceTypes) {
      if ([sT isEqual:self.serviceType]) {
        self.serviceType = sT;
        break;
      }
    }
    
  }
  
  [super newServices:sender];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.serviceType.services count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell * cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	NSNetService *service = [self.serviceType.services objectAtIndex:indexPath.row];
	((UILabel*)[cell viewWithTag:1]).text = [service name];

	NSString * details = [NSString stringWithFormat:@"%@, %@", service.hostnamePlus, service.detailedPortInfo];
	((UILabel*)[cell viewWithTag:2]).text = details;
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSNetService *service = [self.serviceType.services objectAtIndex:indexPath.row];
	Host * host = [((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]) hostForService:service];
	ServiceDetailViewController *sdvc = [[ServiceDetailViewController alloc] initWithHost:host service:service];
	[self.navigationController pushViewController:sdvc animated:TRUE];
	[sdvc release];
}


- (void)dealloc {
	self.serviceType = nil;
	[super dealloc];
}

@end