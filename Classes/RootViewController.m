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
    return [delegate.hosts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"HostCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 25.0)];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = UITextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.tag = 1;
        [cell.contentView addSubview:label];
        [label release];
      
        label = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, 300.0, 20.0)];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = UITextAlignmentLeft;
        label.textColor = [UIColor grayColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.tag = 2;
        [cell.contentView addSubview:label];
        [label release];
        
    }
    
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    Host *host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
    ((UILabel*)[cell viewWithTag:1]).text = [host name];
    ((UILabel*)[cell viewWithTag:2]).text = [NSString stringWithFormat:@"%@ (%@)", host.hostname, host.ip];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    Host *host = (Host*)[delegate.hosts objectAtIndex:indexPath.row];
    
    ServiceViewController *svc = [[ServiceViewController alloc] initWithHost:host];
    [self.navigationController pushViewController:svc animated:TRUE];
    [svc release];
}

- (void)dealloc {
    [super dealloc];
}


@end

