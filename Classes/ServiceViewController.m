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
    if ([super initWithStyle:UITableViewStylePlain] == nil) return nil;
    
    // this UTTERLY does not belong here.
    serviceNames = [[NSDictionary alloc] initWithObjectsAndKeys:
        @"iChat 2 presence", @"_presence._tcp.",
        @"iChat 1 presence", @"_ichat._tcp.", 
        @"Remote login", @"_ssh._tcp.", 
        @"SFTP server", @"_sftp._tcp.", 
        @"Personal file sharing", @"_afpovertcp._tcp.", 
        @"SubEthaEdit document", @"_hydra._tcp.", 
        @"Workgroup Manager", @"_workstation._tcp.", 
        @"FTP server", @"_ftp._tcp.", 
        @"Xcode distributed compiler", @"_distcc._tcp.", 
        @"iConquer game server", @"_iconquer._tcp.", 
        @"AirTunes speaker", @"_raop._tcp.", 
        @"Airport base station", @"_airport._tcp.", 
        @"LPR printer sharing", @"_printer._tcp.", 
        @"Internet Printing Protocol", @"_ipp._tcp.", 
        @"Remote AppleEvents", @"_eppc._tcp.", 
        @"Windows file sharing", @"_smb._tcp.", 
        @"Shared clipboard", @"_clipboard._tcp.", 
        @"Teleport server", @"_teleport._tcp.", 
        @"NFS server", @"_nfs._tcp.", 
        @"OmniWeb shared bookmarks", @"_omni-bookmark._tcp.",
        @"WebDav server", @"_webdav._tcp.", 
        @"iPhoto shared photos", @"_dpap._tcp.", 
        @"Web server", @"_http._tcp.", 
        @"iTunes shared music", @"_daap._tcp.", 
        @"iTunes remote control", @"_dacp._tcp.", 
        @"Spike shared clipboard", @"_spike._tcp.", 
        @"Xgrid distributed computing", @"_beep._tcp.", 
        @"NetNewsWire shared feed list", @"_feed-sharing._tcp.", 
        @"Airport Express printer sharing", @"_riousbprint._tcp.", 
        nil
        ];
    
    host = thehost;

    self.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 600.0, 64.0)] autorelease];

    UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 25.0)] autorelease];
    label.font = [UIFont systemFontOfSize:16.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor blackColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.text = [host name];
    [self.tableView.tableHeaderView addSubview:label];
    
    label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, 300.0, 40.0)] autorelease];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = UITextAlignmentLeft;
    label.textColor = [UIColor grayColor];
    label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    label.numberOfLines = 2;
    label.text = [NSString stringWithFormat:@"%@ (%@)\n%d services", [host hostname], [host ip], [host serviceCount]];
    [self.tableView.tableHeaderView addSubview:label];
    
    UIView *line = [[[UIView alloc] initWithFrame:CGRectMake(0, self.tableView.tableHeaderView.frame.size.height - 1, 600, 1)] autorelease];
    line.backgroundColor = [UIColor grayColor];
    [self.tableView.tableHeaderView addSubview:line];
    
    self.tableView.delegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newServices:) name:@"newServices" object:nil ];
    self.title = [host name];
    [self.tableView reloadData];

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

        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 300.0, 25.0)] autorelease];
        label.font = [UIFont systemFontOfSize:16.0];
        label.textAlignment = UITextAlignmentLeft;
        label.textColor = [UIColor blackColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.tag = 1;
        [cell.contentView addSubview:label];
        
        label = [[[UILabel alloc] initWithFrame:CGRectMake(5.0, 22.0, 300.0, 20.0)] autorelease];
        label.font = [UIFont systemFontOfSize:12.0];
        label.textAlignment = UITextAlignmentLeft;
        label.textColor = [UIColor grayColor];
        label.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        label.tag = 2;
        [cell.contentView addSubview:label];
    }
    
    NSNetService *service = [host serviceAtIndex:indexPath.row];
    // Set up the cell...
    NSString *text = [serviceNames objectForKey:[service type]];
    if (text == nil)
        ((UILabel*)[cell viewWithTag:1]).text = [service type];
    else
        ((UILabel*)[cell viewWithTag:1]).text = [NSString stringWithFormat:@"%@ (%@)", text, [service type]];
    ((UILabel*)[cell viewWithTag:2]).text = [service name];

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
    [serviceNames release];
    [super dealloc];
}


@end
