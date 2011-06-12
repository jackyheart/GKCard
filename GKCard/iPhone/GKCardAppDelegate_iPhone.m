//
//  GKCardAppDelegate_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GKCardAppDelegate_iPhone.h"
#import "GKCardAppDelegate_iPhone.h"

@implementation GKCardAppDelegate_iPhone
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.window.rootViewController = (UIViewController *)viewController;
    
    return YES;
}

/*
-(void)transitionFromView:(UIView *)fromView toView:(UIView *)toView
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	[UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromRight forView:self.window cache:YES];
	[fromView removeFromSuperview];
	[self.window addSubview:toView];
	[UIView commitAnimations];
}
 */

- (void)dealloc
{
    [viewController release];
	[super dealloc];
}

@end
