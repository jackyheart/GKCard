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
#import "PeerIphoneViewController.h"
#import "Card.h"

typedef enum { 
    
    CARD_FULLY_STACKED = 0,
    CARD_EXPANDED_LEFT,
    CARD_EXPANDED_RIGHT

} CARD_STACK_STATUS;


@interface GKPlayTableViewController_iPad (private)

- (void)sendCardToIPhoneWithIndex:(int)cardIdx;
- (void)swipeOpenCardsWithDirection:(int)dir;
- (void)swipeCloseCards;
- (BOOL)isOnPeerIphone:(CGPoint)touchPoint;
- (void)updateNumOfCards;

@end

@implementation GKPlayTableViewController_iPad

@synthesize numCardsLabel;
@synthesize cardNameLabel;
@synthesize cardContainerImgView;
@synthesize swipeAreaView;
@synthesize backsideImage;
@synthesize cardDictMutArray;
@synthesize cardObjectMutArray;
@synthesize peerIphoneVCMutArray;
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
    [numCardsLabel release];
    [cardNameLabel release];
    [cardContainerImgView release];
    [swipeAreaView release];
    [backsideImage release];
    [cardDictMutArray release];
    [cardObjectMutArray release];  
    [peerIphoneVCMutArray release];
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
    
    //=== backside image
    self.backsideImage = [UIImage imageNamed:@"backside.jpg"];  
    
    //=== populate card array
    
    self.cardObjectMutArray = [NSMutableArray array];   
    
    for(int i=0; i < [self.cardDictMutArray count]; i++)
    {
        NSDictionary *cardDict = [self.cardDictMutArray objectAtIndex:i];
        
        NSString *imageNameString = [cardDict objectForKey:@"imageName"];
        
        
        //insert Card to the mutable array
        Card *newCard = [[Card alloc] init];
        
        newCard.cardImage = [UIImage imageNamed:imageNameString];
        newCard.isFacingUp = TRUE;
        newCard.value = 0.0;
        
        [self.cardObjectMutArray addObject:newCard];
        
        
        [newCard release];
        
        
        UIImage *curCardImage = [UIImage imageNamed:imageNameString];
        UIImageView *curCardImgView = [[UIImageView alloc] initWithImage:curCardImage];
        curCardImgView.userInteractionEnabled = YES;
        
        curCardImgView.frame = CGRectMake(0, 0, 187.0, 261.0);
        curCardImgView.center = CGPointMake(self.cardContainerImgView.frame.size.width * 0.5, 
                                            self.cardContainerImgView.frame.size.height * 0.5);
        
        curCardImgView.tag = i;//tag the card
    
        //add gesture recognizer
        
        
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
        
        
        
        //=== pan gesture
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
    
    
    //=== allocate peerIphoneVC
    self.peerIphoneVCMutArray = [NSMutableArray array];
    
    for(int i=0; i < 4; i++)
    {
        PeerIphoneViewController *peerIphoneVC = [[PeerIphoneViewController alloc]
                                                  initWithNibName:@"PeerIphoneViewController" bundle:nil];
        
        peerIphoneVC.view.frame = CGRectMake(i * 200 + 150, 50, peerIphoneVC.view.frame.size.width, peerIphoneVC.view.frame.size.height);
        peerIphoneVC.view.alpha = 0.6;
        
        [self.peerIphoneVCMutArray addObject:peerIphoneVC];
        [self.view addSubview:peerIphoneVC.view];
        
        [peerIphoneVC release];
    }
    
    //=== set variables
    IS_CARD_CONTAINER_FACING_FRONT = TRUE;
    CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
    
    
    /*
    
     With UIKit Apple added support for CGPoint to NSValue, so you can do:
     
     NSArray *points = [NSArray arrayWithObjects:
     [NSValue valueWithCGPoint:CGPointMake(5.5, 6.6)],
     [NSValue valueWithCGPoint:CGPointMake(7.7, 8.8)],
     nil];
     List as many [NSValue] instances as you have CGPoint, and end the list in nil. All objects in this structure are auto-released.
     
     On the flip side, when you're pulling the values out of the array:
     
     NSValue *val = [points objectAtIndex:0];
     CGPoint p = [val CGPointValue];
     
     */
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

- (void)singleTapGestureHandler:(UITapGestureRecognizer *)recognizer
{
    self.cardNameLabel.text = [NSString stringWithFormat:@"cardIdx: %d", recognizer.view.tag];
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
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {   
        netTranslation = CGPointMake(recognizer.view.transform.tx, recognizer.view.transform.ty);
    }
    
    recognizer.view.transform = CGAffineTransformMakeTranslation(netTranslation.x + translation.x, netTranslation.y + translation.y);
          
    [self isOnPeerIphone:touchPoint];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {        
        BOOL isOnIphone = [self isOnPeerIphone:touchPoint];
        
        if(isOnIphone)
        {
            NSLog(@"send out card to iphone");
            
            [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveLinear 
                             animations:^(void) {
                                 
                                 recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, 0.0, -200.0);                                 
                                 
                             } completion:^(BOOL finished) {
                                 
                                 for(UIView *v in self.cardContainerImgView.subviews)
                                 {
                                     if(v.tag == recognizer.view.tag)
                                     {
                                         [v removeFromSuperview];
                                     }
                                 }
                                 
                                 [self updateNumOfCards];   
                                 
                                 [self sendCardToIPhoneWithIndex:recognizer.view.tag];
                                 
                             }];
        }
        
    }
}

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
        Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
        
        NSString *cardIdxStr = [NSString stringWithFormat:@"%d", cardIdx];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  cardIdxStr, @"cardIndex",
                                  theCard.isFacingUp, @"cardFacing", nil];   
        
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
            NSArray *iphoneTableArray = [NSArray arrayWithObject:@"iphone"];
            
            [self.currentSession sendData:data toPeers:iphoneTableArray withDataMode:GKSendDataReliable error:nil];
        }     
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

- (BOOL)isOnPeerIphone:(CGPoint)touchPoint
{
    BOOL isOnIphone = FALSE;
    
    for(int i=0; i < [self.peerIphoneVCMutArray count]; i++)
    {
        PeerIphoneViewController *peerIphoneVC = (PeerIphoneViewController *)[self.peerIphoneVCMutArray objectAtIndex:i];
        
        if(CGRectContainsPoint(peerIphoneVC.view.frame, touchPoint))
        {
            isOnIphone = TRUE;
            peerIphoneVC.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
            break;
        }
        else
        {
            peerIphoneVC.view.backgroundColor = [UIColor clearColor];
        }
    }
    
    return isOnIphone;
}

- (void)updateNumOfCards
{
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
}

- (IBAction)flipBtnPressed:(id)sender
{
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    int CARD_COUNT = [self.cardContainerImgView.subviews count];
    
    
    NSMutableArray *cardTransformMutArray = [NSMutableArray array];
    
    for(int i=0; i < CARD_COUNT; i++)
    {
        UIImageView *imgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
        CGPoint cardTranslationPoint = CGPointMake(imgView.transform.tx, imgView.transform.ty);
        
        NSValue *cgPointValue = [NSValue valueWithCGPoint:cardTranslationPoint];
        [cardTransformMutArray addObject:cgPointValue];
    }    
    
    
    if(IS_CARD_CONTAINER_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    
    
    for(int i=0; i < [self.cardContainerImgView.subviews count]; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
                
        curCardImgView.transform = CGAffineTransformMakeTranslation(-curCardImgView.transform.tx, curCardImgView.transform.ty);
        
        
        Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:curCardImgView.tag];
        
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
