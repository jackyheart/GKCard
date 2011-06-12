//
//  GKPlayTableViewController_iPad.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GKCardAppDelegate_iPad.h"
#import "GKCardViewController_iPad.h"
#import "GKPlayTableViewController_iPad.h"

@implementation GKPlayTableViewController_iPad

//private variables
GKCardAppDelegate_iPad *APP_DELEGATE_IPAD;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //=== get app delegate
    APP_DELEGATE_IPAD = [[UIApplication sharedApplication] delegate];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (IBAction)disconnectBtnPressed:(id)sender
{
    GKCardViewController_iPad *rootVC_ipad = APP_DELEGATE_IPAD.viewController;
    [APP_DELEGATE_IPAD transitionFromView:self.view toView:rootVC_ipad.view];
}

@end
