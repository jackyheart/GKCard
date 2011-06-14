//
//  GKCardViewController_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GKCardAppDelegate.h"
#import "GKCardViewController_iPhone.h"
#import "GKPlayTableViewController_iPhone.h"

@implementation GKCardViewController_iPhone
@synthesize gkTableIphoneVC;

//private variables
GKCardAppDelegate *APP_DELEGATE;

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
    [gkTableIphoneVC release];
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
    APP_DELEGATE = [[UIApplication sharedApplication] delegate];
    
    //=== initialize view controllers
    self.gkTableIphoneVC = [[GKPlayTableViewController_iPhone alloc]
                            initWithNibName:@"GKPlayTableViewController_iPhone" bundle:nil];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Application logic

- (IBAction)startBtnPressed:(id)sender
{
    [APP_DELEGATE transitionFromView:self.view toView:self.gkTableIphoneVC.view withDirection:1 fromDevice:@"iPhone"];
    
    //[self.gkTableIphoneVC startBluetooth];
}

- (IBAction)quitBtnPressed:(id)sender
{
    exit(0);
}


@end
