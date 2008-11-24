//
//  ServiceViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import "ServiceViewController.h"


@implementation ServiceViewController

- (id)initWithHost:(Host*)thehost {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        host = thehost;
        self.tableView.delegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
        self.title = [host name];
        [self.tableView reloadData];
    }
    return self;
}

-(void) newServices:(id)whatever {
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [host serviceCount];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ServiceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSNetService *service = [host serviceAtIndex:indexPath.row];
    // Set up the cell...
    cell.text = [NSString stringWithFormat:@"%@ / %@", [service type], [service name]];
    //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   NSNetService *service = [host serviceAtIndex:indexPath.row];

   // Navigation logic may go here. Create and push another view controller.
    FlameTouchAppDelegate *delegate = (FlameTouchAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSMutableArray *hosts = [delegate hosts];
    Host *host = (Host*)[hosts objectAtIndex:indexPath.row];
    
    ServiceViewController *svc = [[ServiceViewController alloc] initWithHost:host];
	[self.navigationController pushViewController:svc animated:TRUE];
	[svc release];
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
