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
#import "Card.h"

#define RADIANS( degrees ) ( degrees * M_PI / 180 )

typedef enum { 
    
    CARD_FULLY_STACKED = 0,
    CARD_EXPANDED_LEFT,
    CARD_EXPANDED_RIGHT
    
} CARD_STACK_STATUS;

// GameKit Session ID for app
#define kSessionID @"GKCard"

#define kALERT_CONNECT_TO_MASTER_CONFIRMATION 0
#define kALERT_DISCONNECT_CONFIRMATION 1

@interface GKPlayTableViewController_iPhone (private)

- (void)invalidateSession:(GKSession *)session;
- (void)startBluetooth;
- (void)printOutDescriptionAndSolutionOfError:(NSError *)error;
- (void)sendCardToIPadWithIndex:(int)cardIdx;
- (void)swipeOpenCardsWithDirection:(int)dir;
- (void)swipeCloseCards;
- (BOOL)isOnBluetoothArrow:(CGPoint)touchPoint;
- (void)updateNumOfCards;
- (void)processReceivedCardWithCardIdx:(int)cardIdx andCardFacing:(BOOL)cardFacing;

@end

@implementation GKPlayTableViewController_iPhone

@synthesize numCardsLabel;
@synthesize cardNameLabel;
@synthesize cardContainerImgView;
@synthesize swipeAreaView;
@synthesize bluetoothSendView;
@synthesize bluetoothOverlayImgView;
@synthesize backsideImage;
@synthesize cardDictMutArray;
@synthesize cardObjectMutArray;
@synthesize peerIdMutArray;
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
    [bluetoothSendView release];
    [bluetoothOverlayImgView release];
    [backsideImage release];
    [cardDictMutArray release];
    [cardObjectMutArray release];
    [peerIdMutArray release];
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
    
    
    //=== backside image
    self.backsideImage = [UIImage imageNamed:@"card_backside_red.png"];
    
    
    //=== populate card array
    
    self.cardObjectMutArray = [NSMutableArray array];
     
    for(int i=0; i < [self.cardDictMutArray count]; i++)
    {
        NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
        
        NSString *imageNameString = [cardDict objectForKey:@"file"];
        
        
        //insert Card to the mutable array
        Card *newCard = [[Card alloc] init];
        
        newCard.cardImage = [UIImage imageNamed:imageNameString];
        newCard.cardName = [cardDict objectForKey:@"name"];
        newCard.isFacingUp = TRUE;
        newCard.value = 0.0;
        
        [self.cardObjectMutArray addObject:newCard];
    
        
        [newCard release];
        
        
        //create UIImageView
        /*
        UIImage *curCardImage = [UIImage imageNamed:imageNameString];
        UIImageView *curCardImgView = [[UIImageView alloc] initWithImage:curCardImage];
        curCardImgView.userInteractionEnabled = YES;
        curCardImgView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        curCardImgView.frame = CGRectMake(67.0, 15.0, 187.0, 261.0);
        curCardImgView.tag = i;//tag the card
        
        
        //=== single tap gesture
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureHandler:)];
        
        singleTapRecognizer.numberOfTouchesRequired = 1;
        singleTapRecognizer.numberOfTapsRequired = 1;
        
        [curCardImgView addGestureRecognizer:singleTapRecognizer];
        
        [singleTapRecognizer release];
        
        
        //=== double tap gesture
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
        
        //double tap
        doubleTapRecognizer.numberOfTouchesRequired = 1;
        doubleTapRecognizer.numberOfTapsRequired = 2;
        
        [curCardImgView addGestureRecognizer:doubleTapRecognizer];
        
        [doubleTapRecognizer release];  
        
    
        //add pan gesture recognizer
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
        
        [curCardImgView addGestureRecognizer:panRecognizer]; 
        
        [panRecognizer release];    
        
        
      
        //add to the array
        [self.cardContainerImgView addSubview:curCardImgView]; 
    
        [curCardImgView release];
         */
    }
        
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
    self.cardContainerImgView.userInteractionEnabled = YES;
    //self.cardContainerImgView.clipsToBounds = YES;  
    
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
    IS_CARD_CONTAINER_FACING_FRONT = YES;
    CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
    MASTER_PEER_ID = @"";
    
    //=== initialize peer id mutable array
    self.peerIdMutArray = [NSMutableArray array];
    
    self.cardNameLabel.text = @"Card: cardName";
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
    //return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeLeft;
}

#pragma mark - Gesture handers

- (void)singleTapGestureHandler:(UITapGestureRecognizer *)recognizer
{
    Card *cardObject = (Card*)[self.cardObjectMutArray objectAtIndex:recognizer.view.tag];
    self.cardNameLabel.text = [NSString stringWithFormat:@"Card: %@", cardObject.cardName];
}

- (void)doubleTapGestureHandler:(UITapGestureRecognizer *)recognizer
{
    UIImageView *cardImgView = (UIImageView *)recognizer.view;
    
    int cardIdx = recognizer.view.tag;
    
    Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
    
    if(theCard.isFacingUp)
    {
        theCard.isFacingUp = FALSE;
        cardImgView.image = self.backsideImage;
    }
    else
    {
        theCard.isFacingUp = TRUE;
        cardImgView.image = theCard.cardImage;
    }
    
    NSLog(@"Card: %@", theCard);
    NSLog(@"theCard value:%f", theCard.value);
    NSLog(@"theCard facing: %d", theCard.isFacingUp);   
}

- (void)panGestureHandler:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint touchPoint = [recognizer locationInView:self.view];
    
    CGPoint translation = [recognizer translationInView:self.view];
    
    //self.cardNameLabel.text = [NSString stringWithFormat:@"idx: %d", recognizer.view.tag];
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        CARD_INITIAL_TRANSFORM = recognizer.view.transform;
        
        Card *cardObject = (Card*)[self.cardObjectMutArray objectAtIndex:recognizer.view.tag];
        self.cardNameLabel.text = [NSString stringWithFormat:@"Card: %@", cardObject.cardName];
    }
    
    CGAffineTransform newTranslation = CGAffineTransformMakeTranslation(translation.x, translation.y);
    //CGAffineTransform rotateToStraight = CGAffineTransformMakeRotation(RADIANS(0));
    
    //CGAffineTransform newTransform = CGAffineTransformConcat(newTranslation, rotateToStraight);
    //CGAffineTransform combinedTransform = CGAffineTransformConcat(newTransform, CARD_INITIAL_TRANSFORM);
    
    recognizer.view.transform = newTranslation;
    
    //recognizer.view.transform = CGAffineTransformMakeTranslation(translation.x, translation.y);

    [self isOnBluetoothArrow:touchPoint];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        BOOL isOnBTArrow = [self isOnBluetoothArrow:touchPoint];
        
        if(isOnBTArrow)
        {
            NSLog(@"send out card to ipad");
            
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionCurveLinear 
                             animations:^(void) {
                                 
                                 self.bluetoothOverlayImgView.alpha = 0.0;
                                 
                                 recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, 0.0, -300.0);                                 
                                 
                             } completion:^(BOOL finished) {
                                 
                                 for(UIView *v in self.cardContainerImgView.subviews)
                                 {
                                     if(v.tag == recognizer.view.tag)
                                     {
                                         [v removeFromSuperview];
                                     }
                                 }
                                 
                                 [self updateNumOfCards];   
                                 
                                 [self sendCardToIPadWithIndex:recognizer.view.tag];
                                 
                             }];
        }
        else
        {        
            [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                
                recognizer.view.transform = CARD_INITIAL_TRANSFORM;
                
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

- (void)swipeGestureHandler:(UISwipeGestureRecognizer *)recognizer {
    
    //CGPoint location = [recognizer locationInView:self.view];
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"left swipe detected");
        
        if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
        {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                
                [self swipeOpenCardsWithDirection:1];
                
            } completion:NULL];
        }
        else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_RIGHT)
        {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                
                [self swipeCloseCards];
                
            } completion:NULL];         
        }
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right swipe detected");
        
        if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
        {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                
                [self swipeOpenCardsWithDirection:0];
                
            } completion:NULL];          
        }
        else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_LEFT)
        {
            [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                
                [self swipeCloseCards];
                
            } completion:NULL];    
        }
    }
    else
    {
        NSLog(@"other direction detected");
    }
}

#pragma mark - Bluetooth delegates

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    NSString *peerDisplayName = [session displayNameForPeer:peerID];
    
    switch (state) {
        case GKPeerStateConnected:
            
            NSLog(@"[in iPhone] peer %@ is connected", peerDisplayName);
            
            {
                
                //add peerID to the mut array
                if(self.peerIdMutArray.count == 0)
                {
                    [self.peerIdMutArray addObject:peerID]; 
                }
                
                NSLog(@"[in iPhone] peer count: %d", [self.peerIdMutArray count]);
                
                NSLog(@"[in iPhone] list of peers:");
                
                for(int i=0; i < [self.peerIdMutArray count]; i++)
                {
                    NSString *str = [self.peerIdMutArray objectAtIndex:i];
                    NSLog(@"[in iPhone] peer %d: %@", i, str);
                }      
            }
            
            break;
            
        case GKPeerStateDisconnected:
            NSLog(@"[in iPhone] peer %@ is DISconnected", peerDisplayName);
            
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnected" message:[NSString stringWithFormat:@"Server %@ is disconnected", peerDisplayName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                [alert release];    
                
                
                //invalidate current session
                if(self.currentSession)
                {
                    [self invalidateSession:self.currentSession];
                    self.currentSession = nil;
                    
                    MASTER_PEER_ID = @"";
                }
            }
            
            break;
            
        case GKPeerStateAvailable:
            NSLog(@"[in iPhone] peer %@ is available", peerDisplayName);
            
            {
                MASTER_PEER_ID = peerID;
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Server found" message:[NSString stringWithFormat:@"Connect to server %@ ?", peerDisplayName] delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
                alert.tag = kALERT_CONNECT_TO_MASTER_CONFIRMATION;
                [alert show];
                [alert release];     
            }
            
            break;
            
        case GKPeerStateUnavailable:
            NSLog(@"[in iPhone] peer %@ is UNavailable", peerDisplayName);
            break;
            
        default:
            break;
    }
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"connection with peer %@ failed !", peerID);
    
    [self printOutDescriptionAndSolutionOfError:error];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"fatal error");
    
    [session disconnectFromAllPeers];
    session.available = NO;
    [session setDataReceiveHandler: nil withContext: NULL]; 
    session.delegate = nil;
    
    [self printOutDescriptionAndSolutionOfError:error];
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
        
        NSDictionary *objectDict = [sbJSON objectWithString:dataStr error:nil];
        
        NSString *type = [objectDict objectForKey:@"TYPE"];
        
        if([type isEqualToString:@"FIRST_CONNECTED"])
        {
            NSLog(@"first connected peer role: %@", [objectDict objectForKey:@"ROLE"]);
            NSLog(@"first connected peer id: %@", [objectDict objectForKey:@"peerID"]);
        }
        else if([type isEqualToString:@"CARD"])
        {
            int cardIdx = [[objectDict objectForKey:@"cardIndex"] intValue];
            BOOL cardFacing = [[objectDict objectForKey:@"cardFacing"] boolValue];

            [self processReceivedCardWithCardIdx:cardIdx andCardFacing:cardFacing];
        }
    }
    
    [dataStr release];    
}


#pragma mark - Alert view delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == kALERT_CONNECT_TO_MASTER_CONFIRMATION)
    {
        if(buttonIndex == 0)
        {
            //YES
            
            if(! [MASTER_PEER_ID isEqualToString:@""] && self.currentSession)
            {
                [self.currentSession connectToPeer:MASTER_PEER_ID withTimeout:0];
            }
        }
        else if(buttonIndex == 1)
        {
            //NO
            
            //do nothing
        }
    }
    else if(alertView.tag == kALERT_DISCONNECT_CONFIRMATION)
    {
        if(buttonIndex == 0)
        {
            //YES
            
            if(self.currentSession)
            {
                [self invalidateSession:self.currentSession];
                self.currentSession = nil;
            }
        }
    }
}

#pragma mark - Application logic

- (IBAction)flipBtnPressed:(id)sender
{   
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    int CARD_COUNT = [self.cardContainerImgView.subviews count];
    
    if(IS_CARD_CONTAINER_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    
    
    NSMutableArray *tempCurCardTagArray = [NSMutableArray array];
    NSMutableArray *tempCurCardFrameArray = [NSMutableArray array];
    
    for(int i=0; i < CARD_COUNT; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
        [tempCurCardTagArray addObject:[NSNumber numberWithInt:curCardImgView.tag]];
        [tempCurCardFrameArray addObject:[NSValue valueWithCGRect:curCardImgView.frame]];
    }
    
    
    for(int i=0; i < [self.cardContainerImgView.subviews count]; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
        
        NSNumber *storedTagNumber = (NSNumber *)[tempCurCardTagArray objectAtIndex:(CARD_COUNT - 1) - i];
        int storedCardTag = [storedTagNumber intValue];
        
        Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:storedCardTag];
        curCardImgView.tag = storedCardTag;
        
        if(theCard.isFacingUp)
        {
            curCardImgView.image = self.backsideImage;
            theCard.isFacingUp = FALSE;
        }
        else
        {
            curCardImgView.image = theCard.cardImage;
            theCard.isFacingUp = TRUE;
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

- (IBAction)connectDisconnectBtnPressed:(id)sender
{
    /*
     //disconnect bluetooth
     [self.currentSession disconnectFromAllPeers];
     [self.currentSession release];
     currentSession = nil;
     
     GKCardViewController_iPhone *rootVC_iphone = APP_DELEGATE_IPHONE.viewController;
     [APP_DELEGATE_IPHONE transitionFromView:self.view toView:rootVC_iphone.view withDirection:0 fromDevice:@"iPhone"];
     */
    
    if(! self.currentSession)
    {
        [self startBluetooth];
    }
    else
    {
        NSString *serverName = @"";
        
        if(! [MASTER_PEER_ID isEqualToString:@""])
        {
            serverName = [self.currentSession displayNameForPeer:MASTER_PEER_ID];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Disconnect Confirmation" message:[NSString stringWithFormat:@"Do you want to disconnect from the server %@ ?", serverName] delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
        alert.tag = kALERT_DISCONNECT_CONFIRMATION;
        [alert show];
        [alert release];        
    }
}

- (IBAction)testBtnPressed:(id)sender
{
    int cardIdx = arc4random() % 52;
    
    NSLog(@"rand cardIdx:%d", cardIdx);
    
    [self processReceivedCardWithCardIdx:cardIdx andCardFacing:TRUE];
    
    if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_RIGHT)
    {
        [self swipeOpenCardsWithDirection:0];
    }
    else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_LEFT)
    {
        [self swipeOpenCardsWithDirection:1];
    }
}

#pragma mark - private method implementation

- (void)invalidateSession:(GKSession *)session {
    
	if(session != nil) {
        
        [session disconnectFromAllPeers]; 
		session.available = NO; 
		[session setDataReceiveHandler: nil withContext: NULL]; 
		session.delegate = nil; 
	}
}

- (void)startBluetooth
{
    /*
     picker = [[GKPeerPickerController alloc] init];
     picker.delegate = self;
     picker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
     
     [picker show];
     */
    
    if(! self.currentSession)
    {
         NSString *deviceName = [[UIDevice currentDevice] name];
        
        GKSession *tempSession = [[GKSession alloc] initWithSessionID:kSessionID displayName:deviceName sessionMode:GKSessionModeClient];
        
        self.currentSession = tempSession;
        self.currentSession.delegate = self;
        self.currentSession.available = YES;
        self.currentSession.disconnectTimeout = 0;
        [self.currentSession setDataReceiveHandler:self withContext:nil];
        
        [tempSession release];   
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session started" message:@"Client Session started !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        [alert release];   
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session running" message:[NSString stringWithFormat:@"Server session id %@ and sessionName %@ is running", self.currentSession.sessionID, self.currentSession.displayName] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        [alert release];        
    }
}

- (void)printOutDescriptionAndSolutionOfError:(NSError *)error
{
    NSLog(@"================");
    
    NSLog(@"error code: %d", error.code);
    NSLog(@"description: %@", error.localizedDescription);
    NSLog(@"failure reason: %@", error.localizedFailureReason);
    
    NSLog(@"recovery options:");
    
    for(int i=0; i < error.localizedRecoveryOptions.count; i++)
    {
        NSLog(@"- %@", [error.localizedRecoveryOptions objectAtIndex:i]);
    }
    
    NSLog(@"recovery suggestion: %@", error.localizedRecoverySuggestion);
    
    NSLog(@"================");
}

- (void)sendCardToIPadWithIndex:(int)cardIdx 
{
    if(self.currentSession)
    {          
        Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
        
        NSString *cardIdxStr = [NSString stringWithFormat:@"%d", cardIdx];
        NSString *cardUpStr = [NSString stringWithFormat:@"%d", theCard.isFacingUp];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"CARD", @"TYPE",
                                  cardIdxStr, @"cardIndex",
                                  cardUpStr, @"cardFacing", nil];   
        
        NSError *error;
        NSString *jsonString = [self.sbJSON stringWithObject:dataDict error:&error];
        
        
        if (! jsonString)
        {
            NSLog(@"JSON creation failed: %@", [error localizedDescription]);
        }
        else
        {
            NSLog(@"json string to send out: %@", jsonString);
            
            NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            
            //make sure only send to the first one (and only one - the master)
            NSArray *ipadTableArray = [NSArray arrayWithObject:[self.peerIdMutArray objectAtIndex:0]];
            
            [self.currentSession sendData:data toPeers:ipadTableArray withDataMode:GKSendDataReliable error:nil];
        }
    }
    else
    {
        NSLog(@"current BT session not available");
    }
}

- (void)swipeOpenCardsWithDirection:(int)dir
{
    int CARD_COUNT = [self.cardContainerImgView.subviews count];
    
    float middleIndexDecimal = CARD_COUNT / 2;
    float middleIndexRounded = roundf(middleIndexDecimal);
    
    float BASE_INCR = 5.0;
    
    if(dir == 0)
    {
        //left
        BASE_INCR = 5.0;
        CUR_CARD_STACK_STATUS = CARD_EXPANDED_RIGHT;
    }
    else
    {
        //right
        BASE_INCR = -5.0;
        CUR_CARD_STACK_STATUS = CARD_EXPANDED_LEFT;
    }

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
    
    CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
}

- (BOOL)isOnBluetoothArrow:(CGPoint)touchPoint
{
    if(CGRectContainsPoint(self.bluetoothSendView.frame, touchPoint))
    {
        self.bluetoothOverlayImgView.alpha = 0.5;
        return TRUE;
    }
    else
    {
        [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            self.bluetoothOverlayImgView.alpha = 0.0;
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
    return FALSE;
}

- (void)updateNumOfCards
{
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
}

- (void)processReceivedCardWithCardIdx:(int)cardIdx andCardFacing:(BOOL)cardFacing
{
    Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
    theCard.isFacingUp = cardFacing;
    UIImage *cardImage = theCard.cardImage;
    
    if(! cardFacing)
    {
        cardImage = self.backsideImage;
    }
    
    
    UIImageView *cardImgView = [[UIImageView alloc] initWithImage:cardImage];
    
    cardImgView.userInteractionEnabled = YES;
    cardImgView.layer.anchorPoint = CGPointMake(0.5, 1.0);
    cardImgView.frame = CGRectMake(0, 
                                   -20, 
                                   cardImage.size.width, 
                                   cardImage.size.height); 
    
    cardImgView.tag = cardIdx;//tag the card
    
    
    //=== single tap gesture
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureHandler:)];
    
    singleTapRecognizer.numberOfTouchesRequired = 1;
    singleTapRecognizer.numberOfTapsRequired = 1;
    
    [cardImgView addGestureRecognizer:singleTapRecognizer];
    
    [singleTapRecognizer release];
    
    
    //=== double tap gesture
    UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureHandler:)];
    
    //double tap
    doubleTapRecognizer.numberOfTouchesRequired = 1;
    doubleTapRecognizer.numberOfTapsRequired = 2;
    
    [cardImgView addGestureRecognizer:doubleTapRecognizer];
    
    [doubleTapRecognizer release];  
    
    
    //add pan gesture recognizer
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    
    [cardImgView addGestureRecognizer:panRecognizer]; 
    
    [panRecognizer release];    
    
    
    //add to the array
    [self.cardContainerImgView addSubview:cardImgView]; 
    
    cardImgView.center = CGPointMake(self.cardContainerImgView.center.x, 
                                     self.cardContainerImgView.center.y - 300);
    
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
        
        cardImgView.center = CGPointMake(self.cardContainerImgView.center.x,
                                         self.cardContainerImgView.center.y + 65);
        
    } completion:^(BOOL finished) {
        
        
        if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
        {
            //swipe open right by default
            [self swipeOpenCardsWithDirection:0];
        }
        else
        {
            if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_RIGHT)
            {
                [self swipeOpenCardsWithDirection:0];
            }
            else if(CUR_CARD_STACK_STATUS == CARD_EXPANDED_LEFT)
            {
                [self swipeOpenCardsWithDirection:1];
            }   
        }
        
    }];
    
    
    [cardImgView release];
    
    [self updateNumOfCards];
    
}

@end
