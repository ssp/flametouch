    //
//  ServiceSplitViewController.m
//  FlameTouch
//
//  Created by Tom Insam on 05/07/2010.
//  Copyright 2010 jerakeen.org. All rights reserved.
//

#import "rootSplitViewController.h"


@implementation RootSplitViewController

@synthesize leftPane, rightPane;

-(id)initWithLeftPane:(UINavigationController*)left;
{
  if (self = [super init]) {
    self.leftPane = left;
    UIViewController* rootView = [[UITableViewController alloc] init];
    self.rightPane = [[[UINavigationController alloc] initWithRootViewController:rootView] autorelease];
    NSLog(@"leftPane is a %@", leftPane);
    ((RootViewController*)leftPane.visibleViewController).displayThingy = self;
    self.viewControllers = [NSArray arrayWithObjects:leftPane, rightPane, nil];
    [self fudgeFrames];
  }
  return self;
}

-(void)setViewController:(UIViewController*)vc;
{
  UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
  self.rightPane = nc;
  [nc release];
  self.viewControllers = [NSArray arrayWithObjects:leftPane, rightPane, nil];
  [self fudgeFrames];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  // Overriden to allow any orientation.
  return YES;
}

// always display left pane, even in portrait mode.
// based on http://blog.blackwhale.at/2010/04/your-first-ipad-split-view-application/
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration;
{
  [self fudgeFrames];
}

- (void)fudgeFrames;
{
  
  CGRect frame;
  UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
  if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
    frame = CGRectMake(0,0,1024,768);
  } else {
    frame = CGRectMake(0,0,768,1024);
  }

  //adjust master view
  CGRect f = leftPane.view.frame;
  f.size.width = 320;
  f.size.height = frame.size.height;
  f.origin.x = 0;
  f.origin.y = 0;
  [leftPane.view setFrame:f];
  
  //adjust detail view
  f = rightPane.view.frame;
  f.size.width = frame.size.width - 320;
  f.size.height = frame.size.height;
  f.origin.x = 320;
  f.origin.y = 0;
  [rightPane.view setFrame:f];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
