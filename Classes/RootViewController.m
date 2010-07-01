/*
  RootViewController.m
  FlameTouch

  Created by Tom Insam on 24/11/2008.
 
  
  Copyright (c) 2009 Sven-S. Porst, Tom Insam
  
  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:
  
  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.
  
  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  Email flame@jerakeen.org or visit http://jerakeen.org/code/flame-iphone/
  for support.
*/

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

  UIButton * myAboutButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  myAboutButton.frame = CGRectMake(0.0,0.0,20.0,20.0);
  [myAboutButton addTarget:self action:@selector(showAboutPane) forControlEvents:UIControlEventTouchUpInside];
  UIBarButtonItem * aboutButton = [[[UIBarButtonItem alloc] initWithCustomView:myAboutButton] autorelease];
  [self.navigationItem setRightBarButtonItem:aboutButton];

  NSArray * segmentedControlItems = [NSArray arrayWithObjects:NSLocalizedString(@"Hosts", @"Title of Segmented Control item for selecting the Hosts list"), NSLocalizedString(@"Services", @"Title of Segmented Control item for selecting the Service list"), nil];
  UISegmentedControl * segmentedControl = [[[UISegmentedControl alloc] initWithItems:segmentedControlItems] autorelease];
  [segmentedControl addTarget:self action:@selector(changeDisplayMode:) forControlEvents:UIControlEventValueChanged];
  segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
  segmentedControl.selectedSegmentIndex = ((FlameTouchAppDelegate*)[[UIApplication sharedApplication] delegate]).displayMode;
  self.navigationItem.titleView = segmentedControl;
}


/*
 action of the Hosts / Services segmented control
 sets the display mode in the app delegate and updates the view's title accordingly 
*/
-(void) changeDisplayMode:(id) sender {
  NSInteger selection = [(UISegmentedControl*) sender selectedSegmentIndex];

  ((FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate]).displayMode = selection;

	if (selection == SHOWSERVERS) {
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Hosts", @"Title of Button to get back to the Hosts list")];
  }
  else {
    self.title = [NSString stringWithFormat:NSLocalizedString(@"Services", @"Title of Button to get back to the Services list")];		
  }
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
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
  }
  
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
	if (delegate.displayMode == SHOWSERVERS) {
		Host *host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
    cell.textLabel.text = [host name];
    cell.detailTextLabel.text = [host details];
	}
	else {
		ServiceType * serviceType = (ServiceType*) [delegate.serviceTypes objectAtIndex:indexPath.row];
    cell.textLabel.text = serviceType.humanReadableType;
    cell.detailTextLabel.text = [serviceType details];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  // Navigation logic may go here. Create and push another view controller.
  FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
  
  ServiceViewController * dlc = nil;
	if (delegate.displayMode == SHOWSERVERS) {
		Host * host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
		dlc = [[ServiceByHostViewController alloc] initWithHost:host];
	}
	else {
		ServiceType * serviceType = [delegate.serviceTypes objectAtIndex:indexPath.row];
		dlc = [[ServiceByTypeViewController alloc] initWithServiceType: serviceType];
	}

	[self.navigationController pushViewController:dlc animated:TRUE];
  [dlc release];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}

@end

