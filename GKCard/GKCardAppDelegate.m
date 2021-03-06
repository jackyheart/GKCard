//
//  GKCardAppDelegate.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GKCardAppDelegate.h"

@implementation GKCardAppDelegate


@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

#pragma mark - view transition

-(void)transitionFromView:(UIView *)fromView toView:(UIView *)toView withDirection:(int)dir fromDevice:(NSString*)deviceString
{
 	CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionPush];
    
    if(dir == 0)
    {
        //slide from left
        if([deviceString isEqualToString:@"iPhone"])
        {
            [animation setSubtype:kCATransitionFromLeft];
        }
        else if([deviceString isEqualToString:@"iPad"])
        {
            [animation setSubtype:kCATransitionFromBottom];
        }
    }
    else if(dir == 1)
    {
        //slide from right
        if([deviceString isEqualToString:@"iPhone"])
        {
            [animation setSubtype:kCATransitionFromRight];   
        }
        else if([deviceString isEqualToString:@"iPad"])
        {
            [animation setSubtype:kCATransitionFromTop];
        }  
    }
    
	[animation setDuration:0.5];
	[animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
	[[fromView.superview layer] addAnimation:animation forKey:nil];
	
	[fromView removeFromSuperview];
	
	[self.window addSubview:toView];
     
    
    NSLog(@"window num subviews: %d", [self.window.subviews count]);
}

@end
