//
//  GKPlayTableViewController_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GKCardAppDelegate_iPhone.h"
#import "GKCardViewController_iPhone.h"
#import "GKPlayTableViewController_iPhone.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation GKPlayTableViewController_iPhone

@synthesize numCardsLabel;
@synthesize cardContainerView;
@synthesize swipeAreaView;
@synthesize cardDictMutArray;
@synthesize cardDeckImgViewMutArray;
@synthesize currentSession;

//private variables
GKCardAppDelegate_iPhone *APP_DELEGATE_IPHONE;

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
    [numCardsLabel release];
    [cardContainerView release];
    [swipeAreaView release];
    [cardDictMutArray release];
    [cardDeckImgViewMutArray release];
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
    
    //=== get app delegate (iphone)
    APP_DELEGATE_IPHONE = [[UIApplication sharedApplication] delegate];
    

    //=== init mutable array
    self.cardDictMutArray = [NSMutableArray array];
    self.cardDeckImgViewMutArray = [NSMutableArray array];
    
    //=== load card dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CardDeckList" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    self.cardDictMutArray = [dict objectForKey:@"Card"];
    
    [dict release];
    
    
    //=== populate card array
    for(int i=0; i < [self.cardDictMutArray count]; i++)
    {
        NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
        
        UIImage *curCardImage = [UIImage imageNamed:[cardDict objectForKey:@"imageName"]];
        UIImageView *curCardImgView = [[UIImageView alloc] initWithImage:curCardImage];
        curCardImgView.userInteractionEnabled = YES;
        curCardImgView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        curCardImgView.frame = CGRectMake(67.0, 15.0, 187.0, 261.0);
        curCardImgView.tag = i;//tag the card
    
        //add gesture recognizer
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        
        [curCardImgView addGestureRecognizer:panRecognizer]; 
        
        [panRecognizer release];    
        
        //add to the array
        [self.cardDeckImgViewMutArray addObject:curCardImgView];
        [self.cardContainerView addSubview:curCardImgView]; 
    
        [curCardImgView release];
    }
    
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardDeckImgViewMutArray count]];
    
    
    //=== swipe gesture
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.swipeAreaView addGestureRecognizer:swipeLeftGesture];
    
    [swipeLeftGesture release];
    
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.swipeAreaView addGestureRecognizer:swipeRightGesture];
    
    [swipeRightGesture release];    
    
    
    //=== set variables
    IS_FACING_FRONT = YES;
   
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

#pragma mark - Gesture handers

- (void)swipeGestureHandler:(UISwipeGestureRecognizer *)recognizer {
    
    //CGPoint location = [recognizer locationInView:self.view];
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"left swipe detected");
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            [self swipeOpenCards];
            
        } completion:NULL];
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right swipe detected");
        
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            [self swipeCloseCards];
            
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
        CARD_INITIAL_TRANSFORM = recognizer.view.transform;
    }
    
    recognizer.view.transform = CGAffineTransformMakeTranslation(translation.x, translation.y);
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        recognizer.view.transform = CARD_INITIAL_TRANSFORM;
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


#pragma mark - App logic

- (void)startBluetooth
{
    /*
    picker = [[GKPeerPickerController alloc] init];
    picker.delegate = self;
    picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
    
    [picker show];
     */
}

- (void)sendCardToIPadWithIndex:(int)cardIdx 
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

- (void)swipeOpenCards
{
    float middleIndexDecimal = [self.cardDeckImgViewMutArray count] / 2;
    float middleIndexRounded = roundf(middleIndexDecimal);
    
    float BASE_INCR = 5.0;
    float BASE_START = -(BASE_INCR) * middleIndexRounded;//increment of 15 degrees * number of cards (converted index)
    int middleIndexInteger = (int)middleIndexRounded;
    
    //NSLog(@"middleIndexRounded: %f", middleIndexRounded);
    //NSLog(@"middleIndexInteger: %d", middleIndexInteger);
    
    BOOL IS_EVEN = !([self.cardDeckImgViewMutArray count] % 2);
    BOOL PAST_MIDDLE = FALSE;
    
    NSLog(@"IS_EVEN: %d", IS_EVEN);
    
    if([self.cardDeckImgViewMutArray count] > 1)
    {
        for(int i=0; i < [self.cardDeckImgViewMutArray count]; i++)
        {
            UIImageView *curCardImgView = (UIImageView *)[self.cardDeckImgViewMutArray objectAtIndex:i];
            
            curCardImgView.transform = CGAffineTransformMakeRotation(RADIANS(BASE_START));
            
            if(! PAST_MIDDLE)
            {                
                if((i + 1) >= middleIndexInteger)
                {
                    PAST_MIDDLE = TRUE;
                    
                    if(IS_EVEN)
                    {
                        //past the middle position, set the BASE_START to 0
                        BASE_START = 0;
                    }     
                }
            }
            
            
            BASE_START += BASE_INCR;
        }
    }
    
}

- (void)swipeCloseCards
{
    for(int i=0; i < [self.cardDeckImgViewMutArray count]; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardDeckImgViewMutArray objectAtIndex:i];
        
        curCardImgView.transform = CGAffineTransformMakeRotation(RADIANS(0));
    }       
}

- (IBAction)flipBtnPressed:(id)sender
{   
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    if(IS_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
        
        for(int i=0; i < [self.cardDeckImgViewMutArray count]; i++)
        {
            UIImage *backsideImage = [UIImage imageNamed:@"backside.jpg"];
            
            UIImageView *curCardImgView = (UIImageView *)[self.cardDeckImgViewMutArray objectAtIndex:i];
            curCardImgView.image = backsideImage;
        }    
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
        
        for(int i=0; i < [self.cardDeckImgViewMutArray count]; i++)
        {
            NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
            UIImage *curCardImage = [UIImage imageNamed:[cardDict objectForKey:@"imageName"]];
            
            UIImageView *curCardImgView = (UIImageView *)[self.cardDeckImgViewMutArray objectAtIndex:i];
            curCardImgView.image = curCardImage;
        }    
    }
    
    
    [UIView transitionWithView:self.cardContainerView
                      duration:0.8
                       options:animationOptionIdx
                    animations:^{ 
                        
                        if(IS_FACING_FRONT)
                        {
                            IS_FACING_FRONT = FALSE;
                            
                        }
                        else
                        {
                            IS_FACING_FRONT = TRUE;
                                                    
                        }
                    }
     
                    completion:^(BOOL finished) {
                        
                    }];
}

- (IBAction)disconnectBtnPressed:(id)sender
{
    //disconnect bluetooth
    [self.currentSession disconnectFromAllPeers];
    [self.currentSession release];
    currentSession = nil;
    
    GKCardViewController_iPhone *rootVC_iphone = APP_DELEGATE_IPHONE.viewController;
    [APP_DELEGATE_IPHONE transitionFromView:self.view toView:rootVC_iphone.view];
}


@end
