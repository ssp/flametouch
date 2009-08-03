//
//  AboutViewController.m
//  Spitfire
//
//  Created by Tom Taylor on 20/04/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

-(id)init {
  self = [super init];
  if (!self) return nil;
  self.title = NSLocalizedString(@"Flame for iPhone", @"Full application name");

  theWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
  [theWebView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
  [self.view addSubview:theWebView];
  [theWebView setDelegate:self];
  
  NSString *htmlString = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"] encoding:NSUTF8StringEncoding error:NULL];
  [theWebView loadHTMLString: htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
  
  return self;
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  if (navigationType == UIWebViewNavigationTypeLinkClicked) {
    [[UIApplication sharedApplication] openURL:request.URL];
    return false;
  }
  return true;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}


- (void)dealloc {
  [theWebView setDelegate:nil];
  [theWebView release];
  [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES; 
}

@end
