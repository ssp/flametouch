//
//  RootViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright jerakeen.org 2008. All rights reserved.
//

#import "RootViewController.h"
#import "ServiceViewController.h"
#import "FlameTouchAppDelegate.h"
#import "Host.h"
#import "ServiceType.h"
#import "AboutViewController.h"

@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
}

-(void)viewDidAppear:(BOOL)animated {
  UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshList)];
  [self.navigationItem setLeftBarButtonItem:refreshButton];
  [refreshButton release];

  UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"About", @"String in 'About' button in the top bar") style:UIBarButtonItemStylePlain target:self action:@selector(showAboutPane)];
  [self.navigationItem setRightBarButtonItem:aboutButton];
  [aboutButton release];
	
	NSArray * segmentedControlItems = [NSArray arrayWithObjects:NSLocalizedString(@"Servers", @"Title of Segmented Control item for selecting the Server list"), NSLocalizedString(@"Services", @"Title of Segmented Control item for selecting the Service list"), nil];
	UISegmentedControl * segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedControlItems] autorelease];
	[segmentedControl addTarget:self action:@selector(changeDisplayMode:) forControlEvents:UIControlEventValueChanged];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.selectedSegmentIndex = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).displayMode;
	self.navigationItem.titleView = segmentedControl;
}


-(void) changeDisplayMode:(id) sender {
	NSInteger selection = [(UISegmentedControl*) sender selectedSegmentIndex];
	((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).displayMode = selection;
}


-(void)showAboutPane {
  AboutViewController *avc = [[AboutViewController alloc] init];
  [self.navigationController pushViewController:avc animated:TRUE];
  [avc release];
}

-(void)refreshList {
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  [delegate refreshList];
}

-(void) newServices:(id)whatever {
  [self.tableView reloadData];
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (delegate.displayMode == SHOWSERVERS) {
		self.title = [NSString stringWithFormat:NSLocalizedString(@"Servers", @"Button to get back to the Servers list"), [delegate.hosts count]];
	}
	else {
		self.title = [NSString stringWithFormat:NSLocalizedString(@"Services", @"Button to get back to the Services list"), [delegate.serviceTypes count]];		
	}
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSInteger result; 

	if (delegate.displayMode == SHOWSERVERS) {
		result = [delegate.hosts count];
	}
	else {
		result = [delegate.serviceTypes count];
	}

	return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"HostCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 0.0, tableView.frame.size.width - 30.0, 25.0)];
    label.font = [UIFont boldSystemFontOfSize:16.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.tag = 1;
    [cell.contentView addSubview:label];
    [label release];
  
    label = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 22.0, tableView.frame.size.width - 30.0, 20.0)];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.tag = 2;
    [cell.contentView addSubview:label];
    [label release];
    
  }
  
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (delegate.displayMode == SHOWSERVERS) {
		Host *host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
		((UILabel*)[cell viewWithTag:1]).text = [host name];
		((UILabel*)[cell viewWithTag:2]).text = [host details];
	}
	else {
		ServiceType * serviceType = (ServiceType*) [delegate.serviceTypes objectAtIndex:indexPath.row];
		((UILabel*)[cell viewWithTag:1]).text = serviceType.humanReadableType;
		((UILabel*)[cell viewWithTag:2]).text = [serviceType details];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  
	DetailListController * dlc = nil;
	if (delegate.displayMode == SHOWSERVERS) {
		Host * host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
		dlc = [[ServiceViewController alloc] initWithHost:host];
	}
	else {
		ServiceType * serviceType = [delegate.serviceTypes objectAtIndex:indexPath.row];
		dlc = [[HostViewController alloc] initWithServiceType: serviceType];
	}

	[self.navigationController pushViewController:dlc animated:TRUE];
  [dlc release];
}


@end

