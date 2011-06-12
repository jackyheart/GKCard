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
@synthesize currentSession;

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
    [currentSession release];
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

#pragma mark - Bluetooth delegates
- (void)peerPickerController:(GKPeerPickerController *)pk didConnectPeer:(NSString *)peerID toSession:(GKSession *)session
{
    self.currentSession = session;
    self.currentSession.delegate = self;
    [self.currentSession setDataReceiveHandler:self withContext:nil];
    
    picker.delegate = nil;
    [picker dismiss];
    [picker autorelease];
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)pk
{
    picker.delegate = nil;
    [picker autorelease];
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    switch (state) {
        case GKPeerStateConnected:
            NSLog(@"peer is connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"peer is DISconnected");
            break;
        case GKPeerStateAvailable:
            NSLog(@"peer is available");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"peer is UNavailable");
            break;
            
        default:
            break;
    }
}

#pragma mark - App logic

- (void)startBluetooth
{
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];   
}

- (void)sendCardToIPhoneWithIndex:(int)cardIdx
{
    if(self.currentSession)
    {  
        NSData *data;
        
        NSString *cardIdxStr = [NSString stringWithFormat:@"%d", cardIdx];
        data = [cardIdxStr dataUsingEncoding:NSASCIIStringEncoding];
        
        NSArray *ipadTableArray = [NSArray arrayWithObject:@"ipad"];
        
        [self.currentSession sendData:data toPeers:ipadTableArray withDataMode:GKSendDataReliable error:nil];
    }
    else
    {
        NSLog(@"current BT session not available");
    }    
}

- (IBAction)disconnectBtnPressed:(id)sender
{
    //disconnect bluetooth
    [self.currentSession disconnectFromAllPeers];
    [self.currentSession release];
    currentSession = nil;
    
    GKCardViewController_iPad *rootVC_ipad = APP_DELEGATE_IPAD.viewController;
    [APP_DELEGATE_IPAD transitionFromView:self.view toView:rootVC_ipad.view];
}

@end
