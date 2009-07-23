//
//  AboutViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 23/07/2009.
//  Copyright 2009 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface AboutViewController : UIViewController <UIWebViewDelegate> {
  IBOutlet UIWebView *theWebView;
}
@end
