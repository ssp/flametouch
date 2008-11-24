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


@implementation RootViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
    self.title = @"Servers";
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
    NSMutableArray *hosts = [delegate hosts];
    return [hosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *hosts = [delegate hosts];
    Host *host = (Host*)[hosts objectAtIndex:indexPath.row];
    // Set up the cell...
    cell.text = [host name];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *hosts = [delegate hosts];
    Host *host = (Host*)[hosts objectAtIndex:indexPath.row];
    
    ServiceViewController *svc = [[ServiceViewController alloc] initWithHost:host];
	[self.navigationController pushViewController:svc animated:TRUE];
	[svc release];
}

- (void)dealloc {
    [super dealloc];
}


@end

