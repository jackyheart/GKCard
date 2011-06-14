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

@interface GKPlayTableViewController_iPhone (private)

- (void)sendCardToIPadWithIndex:(int)cardIdx;
- (void)swipeOpenCards;
- (void)swipeCloseCards;

@end


@implementation GKPlayTableViewController_iPhone

@synthesize numCardsLabel;
@synthesize cardNameLabel;
@synthesize cardContainerImgView;
@synthesize swipeAreaView;
@synthesize cardDictMutArray;
@synthesize currentSession;
@synthesize sbJSON;

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
    [cardNameLabel release];
    [cardContainerImgView release];
    [swipeAreaView release];
    [cardDictMutArray release];
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
    
    //=== get app delegate (iphone)
    APP_DELEGATE_IPHONE = [[UIApplication sharedApplication] delegate];
    
    
    //=== initialize SBJSON
    self.sbJSON = [[SBJSON alloc] init];
    self.sbJSON.humanReadable = YES;
    

    //=== init mutable array
    self.cardDictMutArray = [NSMutableArray array];
    
    //=== load card dictionary
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CardDeckList" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    self.cardDictMutArray = [dict objectForKey:@"Card"];
    
    [dict release];
    
    
    //=== populate card array
    for(int i=0; i < [self.cardDictMutArray count] - 2; i++)
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
        [self.cardContainerImgView addSubview:curCardImgView]; 
    
        [curCardImgView release];
    }
    
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
    
    
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

- (void)sendCardToIPadWithIndex:(int)cardIdx 
{
    if(self.currentSession)
    {  
        //=== get card facing
        //NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:cardIdx];
        //NSString *cardFacing = [cardDict objectForKey:@"isFacingUp"];
        
        NSString *cardIdxStr = [NSString stringWithFormat:@"%d", cardIdx];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  cardIdxStr, @"cardIndex",
                                  @"1", @"cardFacing", nil];   
         
        NSError *error;
        NSString *jsonString = [self.sbJSON stringWithObject:dataDict error:&error];
        
        if (! jsonString)
        {
            NSLog(@"JSON creation failed: %@", [error localizedDescription]);
        }
        else
        {
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *ipadTableArray = [NSArray arrayWithObject:@"ipad"];
            
            [self.currentSession sendData:data toPeers:ipadTableArray withDataMode:GKSendDataReliable error:nil];
        }
    }
    else
    {
        NSLog(@"current BT session not available");
    }
}

- (void)swipeOpenCards
{
    int CARD_COUNT = [self.cardContainerImgView.subviews count];
    
    float middleIndexDecimal = CARD_COUNT / 2;
    float middleIndexRounded = roundf(middleIndexDecimal);
    
    float BASE_INCR = 45.0;
    float BASE_START = -(BASE_INCR) * middleIndexRounded;//increment of 15 degrees * number of cards (converted index)
    int middleIndexInteger = (int)middleIndexRounded;
    
    //NSLog(@"middleIndexRounded: %f", middleIndexRounded);
    //NSLog(@"middleIndexInteger: %d", middleIndexInteger);
    
    BOOL IS_EVEN = !(CARD_COUNT % 2);
    BOOL PAST_MIDDLE = FALSE;
    
    NSLog(@"IS_EVEN: %d", IS_EVEN);
    
    if(CARD_COUNT > 1)
    {
        for(int i=0; i < CARD_COUNT; i++)
        {
            UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
            
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
    for(int i=0; i < [self.cardContainerImgView.subviews count]; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
        
        curCardImgView.transform = CGAffineTransformMakeRotation(RADIANS(0));
    }       
}

- (IBAction)flipBtnPressed:(id)sender
{   
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    if(IS_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
        
        for(int i=0; i < [self.cardContainerImgView.subviews count]; i++)
        {
            UIImage *backsideImage = [UIImage imageNamed:@"backside.jpg"];
            
            UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
            curCardImgView.image = backsideImage;
        }    
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
        
        for(int i=0; i < [self.cardContainerImgView.subviews count]; i++)
        {
            NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
            UIImage *curCardImage = [UIImage imageNamed:[cardDict objectForKey:@"imageName"]];
            
            UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
            curCardImgView.image = curCardImage;
        }    
    }
    
    
    [UIView transitionWithView:self.cardContainerImgView
                      duration:0.8
                       options:animationOptionIdx
                    animations:^{ 
                        
                    }
     
                    completion:^(BOOL finished) {
                        
                        if(IS_FACING_FRONT)
                        {
                            IS_FACING_FRONT = FALSE;
                            
                        }
                        else
                        {
                            IS_FACING_FRONT = TRUE;
                            
                        }   
                        
                    }];
}

- (IBAction)disconnectBtnPressed:(id)sender
{
    //disconnect bluetooth
    [self.currentSession disconnectFromAllPeers];
    [self.currentSession release];
    currentSession = nil;
    
    GKCardViewController_iPhone *rootVC_iphone = APP_DELEGATE_IPHONE.viewController;
    [APP_DELEGATE_IPHONE transitionFromView:self.view toView:rootVC_iphone.view withDirection:0];
}


@end
