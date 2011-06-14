//
//  GKCardAppDelegate.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GKCardAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

-(void)transitionFromView:(UIView *)fromView toView:(UIView *)toView withDirection:(int)dir fromDevice:(NSString*)deviceString;

@end
