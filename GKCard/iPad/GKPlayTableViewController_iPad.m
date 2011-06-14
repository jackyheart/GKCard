//
//  GKPlayTableViewController_iPad.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GKCardAppDelegate_iPad.h"
#import "GKCardViewController_iPad.h"
#import "GKPlayTableViewController_iPad.h"

typedef enum { 
    
    CARD_FULLY_STACKED = 0,
    CARD_EXPANDED_LEFT,
    CARD_EXPANDED_RIGHT

} CARD_STACK_STATUS;



@interface GKPlayTableViewController_iPad (private)

- (void)swipeOpenCardsWithDirection:(int)dir;
- (void)swipeCloseCards;

@end

@implementation GKPlayTableViewController_iPad
@synthesize cardDictMutArray;
@synthesize numCardsLabel;
@synthesize cardContainerImgView;
@synthesize swipeAreaView;
@synthesize currentSession;
@synthesize sbJSON;

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
    [cardDictMutArray release];
    [numCardsLabel release];
    [cardContainerImgView release];
    [swipeAreaView release];
    [currentSession release];
    [sbJSON release];
    
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
    
    //=== initialize SBJSON
    self.sbJSON = [[SBJSON alloc] init];
    self.sbJSON.humanReadable = YES;
    
    //=== init mutable array
    self.cardDictMutArray = [NSMutableArray array];  
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CardDeckList" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    self.cardDictMutArray = [dict objectForKey:@"Card"];
    
    [dict release];
    
    
    for(int i=0; i < [self.cardDictMutArray count]; i++)
    {
        NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
        
        UIImage *curCardImage = [UIImage imageNamed:[cardDict objectForKey:@"imageName"]];
        UIImageView *curCardImgView = [[UIImageView alloc] initWithImage:curCardImage];
        curCardImgView.userInteractionEnabled = YES;
        
        curCardImgView.frame = CGRectMake(0, 0, 187.0, 261.0);
        curCardImgView.center = CGPointMake(self.cardContainerImgView.frame.size.width * 0.5, 
                                            self.cardContainerImgView.frame.size.height * 0.5);
        
        curCardImgView.tag = i;//tag the card
    
        //add gesture recognizer
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        
        [curCardImgView addGestureRecognizer:panRecognizer]; 
        
        [panRecognizer release];    
        
        //add to the array
        [self.cardContainerImgView addSubview:curCardImgView]; 
        
        [curCardImgView release];
    } 
    
    //set number of cards label
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
    self.cardContainerImgView.userInteractionEnabled = YES;
    self.cardContainerImgView.clipsToBounds = YES;
    
    //swipe gesture
    
    //=== swipe gesture
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
     
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
   // swipeLeftGesture.numberOfTouchesRequired = 2;
    [self.cardContainerImgView addGestureRecognizer:swipeLeftGesture];
    
    [swipeLeftGesture release];
    
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    //swipeRightGesture.numberOfTouchesRequired = 2;
    [self.cardContainerImgView addGestureRecognizer:swipeRightGesture];
    
    [swipeRightGesture release];     
    
    //=== set variables
    CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
    IS_CARD_CONTAINER_FACING_FRONT = TRUE;
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

#pragma mark - Gesture handers

- (void)swipeGestureHandler:(UISwipeGestureRecognizer *)recognizer {
    
    //CGPoint location = [recognizer locationInView:self.view];
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"left swipe detected");
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
            {
                [self swipeOpenCardsWithDirection:0];
            }
            else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_RIGHT)
            {
                [self swipeCloseCards];
            }
            
        } completion:NULL];   
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right swipe detected");
        
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
            {
                [self swipeOpenCardsWithDirection:1];
            }
            else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_LEFT)
            {
                [self swipeCloseCards];
            }
            
        } completion:NULL]; 
        
    }
    else
    {
        NSLog(@"other direction detected");
    }
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)recognizer {
    
    NSLog(@"panGestureHandler executed");
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        
    }
    
    recognizer.view.transform = CGAffineTransformMakeTranslation(netTranslation.x + translation.x, netTranslation.y + translation.y);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        netTranslation = translation;
    }
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

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    
}

- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *dataDictionary = [self.sbJSON objectWithString:dataStr error:&error];
    
    if(! dataDictionary)
    {
        NSLog(@"JSON parsing failed: %@", [error localizedDescription]);
    }
    else
    {
        NSLog(@"JSON parsing success");
        
        
    }
    
    [dataStr release];
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

- (void)swipeOpenCardsWithDirection:(int)dir
{
    float separationVal = 30.0;
    
    int i=0;
    
    if(dir == 0)
    {
        //left        
        CUR_CARD_STACK_STATUS = CARD_EXPANDED_LEFT;
        
        separationVal *= -1;
    }
    else if(dir == 1)
    {
        //right
         CUR_CARD_STACK_STATUS = CARD_EXPANDED_RIGHT;
    }
    
    for(UIView *v in self.cardContainerImgView.subviews)
    {
        v.transform = CGAffineTransformMakeTranslation(separationVal * i, 0.0);
        
        i++;
    }
}

- (void)swipeCloseCards
{
    for(UIView *v in self.cardContainerImgView.subviews)
    {
        v.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
    }    
    
    CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
}

- (IBAction)flipBtnPressed:(id)sender
{
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    if(IS_CARD_CONTAINER_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
        
        for(UIImageView *cardImgView in self.cardContainerImgView.subviews)
        {
            UIImage *backsideImage = [UIImage imageNamed:@"backside.jpg"];
            
            cardImgView.image = backsideImage;
        }
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
        
        int i=0;
        for(UIImageView *cardImgView in self.cardContainerImgView.subviews)
        {
            NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
            UIImage *curCardImage = [UIImage imageNamed:[cardDict objectForKey:@"imageName"]];
            
            cardImgView.image = curCardImage;
            
            i++;
        }
    }
    
    
    [UIView transitionWithView:self.cardContainerImgView
                      duration:0.8
                       options:animationOptionIdx
                    animations:^{ 

                    }
     
                    completion:^(BOOL finished) {
                        
                        if(IS_CARD_CONTAINER_FACING_FRONT)
                        {
                            IS_CARD_CONTAINER_FACING_FRONT = FALSE;
                            
                        }
                        else
                        {
                            IS_CARD_CONTAINER_FACING_FRONT = TRUE;
                        }   
                    }];    
}

- (IBAction)disconnectBtnPressed:(id)sender
{
    //disconnect bluetooth
    [self.currentSession disconnectFromAllPeers];
    [self.currentSession release];
    currentSession = nil;
    
    GKCardViewController_iPad *rootVC_ipad = APP_DELEGATE_IPAD.viewController;
    [APP_DELEGATE_IPAD transitionFromView:self.view toView:rootVC_ipad.view withDirection:0 fromDevice:@"iPad"];
}

@end
