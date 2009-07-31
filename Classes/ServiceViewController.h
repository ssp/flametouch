//
//  ServiceViewController.h
//  FlameTouch
//
//  Created by Tom Insam on 24/11/2008.
//  Copyright 2008 jerakeen.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#define LABEL_TAG 1

@interface ServiceViewController : UITableViewController {
}

- (void) setCaption;
- (void) newServices: (id) sender;

@end


@class Host;
@interface ServiceByHostViewController : ServiceViewController {
  Host *host;
}
@property (nonatomic, retain) Host* host;
- (id)initWithHost:(Host*)thehost;
@end


@class ServiceType;
@interface ServiceByTypeViewController : ServiceViewController {
	ServiceType * serviceType;
}
@property (nonatomic, retain) ServiceType * serviceType;
- (id)initWithServiceType:(ServiceType*) theServiceType;
@end

