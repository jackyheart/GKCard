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
    CARD_EXPANDED_RIGHT,
    CARD_STACK_UNDEFINED

} CARD_STACK_STATUS;


@interface GKPlayTableViewController_iPad (private)

- (void)sendCardToIPhoneWithIndex:(int)cardIdx;
- (void)swipeOpenCardsWithDirection:(int)dir;
- (void)swipeCloseCardsWithDirection:(int)dir;
- (BOOL)isOnPeerIphone:(CGPoint)touchPoint;
- (void)updateNumOfCards;
- (int)getPannedCardIdxWithCardTag:(int)cardTag;
- (void)hoverSmallCardsWithTouchPoint:(CGPoint)touchPoint;

@end

@implementation GKPlayTableViewController_iPad

@synthesize numCardsLabel;
@synthesize cardNameLabel;
@synthesize cardContainerImgView;
@synthesize swipeAreaView;
@synthesize cardOrderView;
@synthesize smallCardContainerImgView;
@synthesize backsideImage;
@synthesize cardDictMutArray;
@synthesize cardObjectMutArray;
@synthesize peerIphoneVCMutArray;
@synthesize peerIdMutArray;
@synthesize currentSession;
@synthesize sbJSON;

//private variables
GKCardAppDelegate_iPad *APP_DELEGATE_IPAD;
float CARD_WIDTH = 187.0;
float CARD_HEIGHT = 261.0;

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
    [cardOrderView release];
    [smallCardContainerImgView release];
    [backsideImage release];
    [cardDictMutArray release];
    [cardObjectMutArray release];  
    [peerIphoneVCMutArray release];
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
        
        
        UIImage *curCardImage = [UIImage imageNamed:imageNameString];
        UIImageView *curCardImgView = [[UIImageView alloc] initWithImage:curCardImage];
        curCardImgView.userInteractionEnabled = YES;
        
        curCardImgView.frame = CGRectMake(0, 0, CARD_WIDTH, CARD_HEIGHT);
        curCardImgView.center = CGPointMake(self.cardContainerImgView.center.x, 
                                            self.cardContainerImgView.center.y);

        
        curCardImgView.tag = i;//tag the card
    
        //add gesture recognizers
        
        
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
        
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.maximumNumberOfTouches = 1;
        [curCardImgView addGestureRecognizer:panRecognizer]; 
        
        [panRecognizer release];    
        
        
        //add to the array
        [self.cardContainerImgView addSubview:curCardImgView]; 
        
        [curCardImgView release];
    }
    
    
    //=== pan gesture (3 fingers)

    UIPanGestureRecognizer *panRecognizerFullStack = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureFullStackHandler:)];
    
    panRecognizerFullStack.minimumNumberOfTouches = 3;
    panRecognizerFullStack.maximumNumberOfTouches = 3;
    [self.cardContainerImgView addGestureRecognizer:panRecognizerFullStack]; 
    
    [panRecognizerFullStack release];    
    
    
    //set number of cards label
    self.numCardsLabel.text = [NSString stringWithFormat:@"%d", [self.cardContainerImgView.subviews count]];
    self.cardContainerImgView.userInteractionEnabled = YES;
    self.cardContainerImgView.clipsToBounds = YES;
    
    //swipe gesture
    
    //=== swipe gesture
    UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
     
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.numberOfTouchesRequired = 2;
    [self.cardContainerImgView addGestureRecognizer:swipeLeftGesture];
    
    [swipeLeftGesture release];
    
    
    UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureHandler:)];
    
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.numberOfTouchesRequired = 2;
    [self.cardContainerImgView addGestureRecognizer:swipeRightGesture];
    
    [swipeRightGesture release];     
    
    
    //=== allocate peerIphoneVC
    self.peerIphoneVCMutArray = [NSMutableArray array];
    
    for(int i=0; i < 4; i++)
    {
        PeerIphoneViewController *peerIphoneVC = [[PeerIphoneViewController alloc]
                                                  initWithNibName:@"PeerIphoneViewController" bundle:nil];
        
        peerIphoneVC.view.frame = CGRectMake(i * 200 + 150, 30, peerIphoneVC.view.frame.size.width, peerIphoneVC.view.frame.size.height);
        peerIphoneVC.view.alpha = 0.6;
        
        [self.peerIphoneVCMutArray addObject:peerIphoneVC];
        [self.view addSubview:peerIphoneVC.view];
        
        [peerIphoneVC release];
    }
    
    
    //=== populate the card order view
    int itemCounter = [self.cardContainerImgView.subviews count] - 1;
    float smallCardWidth = 50;
    float smallCardHeight = 70;
    float widthOffset = 10;
    float heightOffset = 10;
    
    for(int i=0; i < 4; i++)
    {
        for(int j=0; j < 13; j++)
        {
            UIImageView *curCardImgView = [self.cardContainerImgView.subviews objectAtIndex:itemCounter];
            UIImage *cardImage = curCardImgView.image;
            
            
            UIImageView *smallCardImgView = [[UIImageView alloc] 
                                             initWithImage:cardImage];
            
            smallCardImgView.frame = CGRectMake(j * (smallCardWidth + widthOffset) + 20, i * (smallCardHeight + heightOffset) + 20, smallCardWidth, smallCardHeight);
            
            smallCardImgView.contentMode = UIViewContentModeScaleAspectFill;
            smallCardImgView.userInteractionEnabled = YES;
            smallCardImgView.tag = itemCounter;//tag the small card
            
            
            //=== pan gesture
            
            UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSmallCardGestureHandler:)];
            
            [smallCardImgView addGestureRecognizer:panRecognizer]; 
            
            [panRecognizer release];   
             
            
            [self.smallCardContainerImgView addSubview:smallCardImgView];

            
            [smallCardImgView release];
            
            
            itemCounter--;
        }
    }
    
    
    self.cardOrderView.frame = CGRectMake(self.cardOrderView.frame.origin.x, 
                                          768, 
                                          self.cardOrderView.frame.size.width, 
                                          self.cardOrderView.frame.size.height);
    
    
    
    //=== initialize peerID mut array
    self.peerIdMutArray = [NSMutableArray array];
    
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
    Card *cardObject = (Card*)[self.cardObjectMutArray objectAtIndex:recognizer.view.tag];
    self.cardNameLabel.text = cardObject.cardName; 
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
    NSLog(@"card ImgView tag: %d", cardImgView.tag);
}

CGPoint touchDelta;

- (void)panGestureHandler:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint touchPoint = [recognizer locationInView:self.view];    
    //CGPoint translation = [recognizer translationInView:self.view];
        
    //NSLog(@"panHandler minimumNum touches: %d", recognizer.minimumNumberOfTouches);
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {   
        Card *cardObject = (Card*)[self.cardObjectMutArray objectAtIndex:recognizer.view.tag];
        self.cardNameLabel.text = cardObject.cardName;
        
        //netTranslation = CGPointMake(recognizer.view.transform.tx, recognizer.view.transform.ty);
    
        touchDelta = CGPointMake(touchPoint.x - recognizer.view.frame.origin.x, 
                                 touchPoint.y - recognizer.view.frame.origin.y);
    }
    
   // recognizer.view.transform = CGAffineTransformMakeTranslation(netTranslation.x + translation.x, netTranslation.y + translation.y);
     

    recognizer.view.frame = CGRectMake(touchPoint.x - touchDelta.x, 
                                       touchPoint.y - touchDelta.y, 
                                       recognizer.view.frame.size.width, 
                                       recognizer.view.frame.size.height);
    
    
    
    [self isOnPeerIphone:touchPoint];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {   
        CUR_CARD_STACK_STATUS = CARD_STACK_UNDEFINED;
        
        BOOL isOnIphone = [self isOnPeerIphone:touchPoint];
        
        if(isOnIphone)
        {
            NSLog(@"send out card to iphone");
            
            [UIView animateWithDuration:0.6 delay:0.0 options:UIViewAnimationOptionCurveLinear 
                             animations:^(void) {
                                 
                                 recognizer.view.transform = CGAffineTransformTranslate(recognizer.view.transform, 0.0, -200.0);                                 
                                 
                             } completion:^(BOOL finished) {
                                 
                                 //for main card stack
                                 for(UIView *v in self.cardContainerImgView.subviews)
                                 {
                                     if(v.tag == recognizer.view.tag)
                                     {
                                         [v removeFromSuperview];
                                     }
                                 }
                                 
                                 //for card order view
                                 for(UIView *v in self.smallCardContainerImgView.subviews)
                                 {
                                     if(v.tag == recognizer.view.tag)
                                     {
                                         //v.tag = -1;
                                         //UIImageView *imgView = (UIImageView *)v;
                                         //imgView.image = nil;
                                         
                                         [v removeFromSuperview];
                                     }
                                 }  
                                 
                                 [self updateNumOfCards];   
                                 
                                 [self sendCardToIPhoneWithIndex:recognizer.view.tag];
                                 
                             }];
        }
        
    }
}

- (void)panGestureFullStackHandler:(UIPanGestureRecognizer *)recognizer
{
    if(CUR_CARD_STACK_STATUS == CARD_FULLY_STACKED)
    {
        CGPoint touchPoint = [recognizer locationInView:self.view];    
        //CGPoint translation = [recognizer translationInView:self.view];   
        
        [UIView animateWithDuration:0.5 delay:0.0 
                            options:UIViewAnimationCurveEaseInOut |   
                                    UIViewAnimationOptionAllowUserInteraction 
                         animations:^(void) {
            
                             for(UIView *v in self.cardContainerImgView.subviews)
                             {
                                 v.center = touchPoint;
                             }             
            
        } completion:^(BOOL finished) {
            
        }];
        
    }
}


CGPoint touchDeltaSmallCard;
CGRect oriRectSmallCard;
CGRect destRectSmallCard;
int PANNED_CARD_IDX = -1;

- (void)panSmallCardGestureHandler:(UIPanGestureRecognizer *)recognizer
{
    CGPoint touchPoint = [recognizer locationInView:self.view];
    
    
    if(recognizer.state == UIGestureRecognizerStateBegan)
    {
        recognizer.view.alpha = 0.8;
        
        touchDeltaSmallCard = CGPointMake(touchPoint.x - recognizer.view.frame.origin.x, 
                                 touchPoint.y - recognizer.view.frame.origin.y);  
        
        oriRectSmallCard = recognizer.view.frame;
        
        PANNED_CARD_IDX = [self getPannedCardIdxWithCardTag:recognizer.view.tag];
    }
    
    
    recognizer.view.frame = CGRectMake(touchPoint.x - touchDeltaSmallCard.x, 
                                       touchPoint.y - touchDeltaSmallCard.y, 
                                       recognizer.view.frame.size.width, 
                                       recognizer.view.frame.size.height);
    
    //highlight effect on hover
    [self hoverSmallCardsWithTouchPoint:touchPoint];
    
   
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        //swapping logic here
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            int CARD_COUNT = [self.cardContainerImgView.subviews count] - 1;
            
            for(int i=0; i < [self.smallCardContainerImgView.subviews count]; i++)
            {
                UIImageView *curSmallCardImgView = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:i];
                
                if(curSmallCardImgView.tag != recognizer.view.tag)
                {
                    CGPoint adjustedTouchPoint = CGPointMake(touchPoint.x - self.cardOrderView.frame.origin.x, 
                                                             touchPoint.y - self.cardOrderView.frame.origin.y);
                    
                    
                    if(CGRectContainsPoint(curSmallCardImgView.frame, adjustedTouchPoint))
                    {
                        //swap frames
                        destRectSmallCard = curSmallCardImgView.frame;
                        curSmallCardImgView.frame = oriRectSmallCard;
                        recognizer.view.frame = destRectSmallCard;
                        
                        
                        [self.smallCardContainerImgView exchangeSubviewAtIndex:PANNED_CARD_IDX withSubviewAtIndex:i];
                        
                        ///=== re-arrange the original card deck
                        int ORI_CARD_IDX_1 = CARD_COUNT - PANNED_CARD_IDX;
                        int ORI_CARD_IDX_2 = CARD_COUNT - i;
                                                
                        [self.cardContainerImgView exchangeSubviewAtIndex:ORI_CARD_IDX_1 withSubviewAtIndex:ORI_CARD_IDX_2];
                        
                        
                        break;
                    }
                }
                else if(curSmallCardImgView.tag == recognizer.view.tag)
                {
                    recognizer.view.frame = oriRectSmallCard;
                }
            }            
        
        } completion:^(BOOL finished) {
            
        }];  
        
        
        //set back all alpha to 1.0
        for(int i=0; i < [self.smallCardContainerImgView.subviews count]; i++)
        {
            UIImageView *curSmallCardImgView = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:i];
            curSmallCardImgView.alpha = 1.0;
        }
    }  
}

- (int)getPannedCardIdxWithCardTag:(int)cardTag
{
    int cardIdx = 0;
    
    for(int i=0; i < [self.smallCardContainerImgView.subviews count]; i++)
    {
        UIImageView *curSmallCardImgView = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:i];
        
        if(curSmallCardImgView.tag == cardTag)
        {
            cardIdx = i;
            
            break;
        }
    }
    
    return cardIdx;
}

- (void)hoverSmallCardsWithTouchPoint:(CGPoint)touchPoint
{
    for(int i=0; i < [self.smallCardContainerImgView.subviews count]; i++)
    {
        UIImageView *curSmallCardImgView = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:i];
        
        CGPoint adjustedTouchPoint = CGPointMake(touchPoint.x - self.cardOrderView.frame.origin.x, 
                                                 touchPoint.y - self.cardOrderView.frame.origin.y);
        
        if(CGRectContainsPoint(curSmallCardImgView.frame, adjustedTouchPoint))   
        {
            curSmallCardImgView.alpha = 0.8;
        }
        else
        {
            curSmallCardImgView.alpha = 1.0;
        }
    }
}


- (void)swipeGestureHandler:(UISwipeGestureRecognizer *)recognizer {
    
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
                [self swipeCloseCardsWithDirection:0];
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
                [self swipeCloseCardsWithDirection:1];
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
    
    //add peerID to the mut array
    [self.peerIdMutArray addObject:peerID];
    
    NSLog(@"[in iPad] peer connected, my session mode: %d, session id:%@, session name:%@", session.sessionMode, session.sessionID, session.displayName);
    
    NSLog(@"[in iPad], newly connected peer id:%@, name:%@", peerID, [session displayNameForPeer:peerID]);
    
    
    for(int i=0; i < [self.peerIdMutArray count]; i++)
    {
        NSString *curPeerID = [self.peerIdMutArray objectAtIndex:i];
        
        PeerIphoneViewController *peerVC = (PeerIphoneViewController *)[self.peerIphoneVCMutArray objectAtIndex:i];
        peerVC.peerNameLabel.text = [session displayNameForPeer:curPeerID];
        
        peerVC.view.alpha = 1.0;
    }
    
    
    if(self.currentSession)
    {                  
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"FIRST_CONNECTED", @"TYPE",
                                  @"MASTER", @"ROLE",
                                  session.sessionID, @"peerID", nil];   
        
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
            NSArray *iphoneTableArray = [NSArray arrayWithObject:peerID];//send the first data back to the newly connected peer
            
            [self.currentSession sendData:data toPeers:iphoneTableArray withDataMode:GKSendDataReliable error:nil];
        }     
    }
    else
    {
        NSLog(@"current BT session not available");
    }    
    
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
            NSLog(@"[in iPad] peer is connected");
            break;
        case GKPeerStateDisconnected:
            NSLog(@"[in iPad] peer is DISconnected");
            break;
        case GKPeerStateAvailable:
            NSLog(@"[in iPad] peer is available");
            break;
        case GKPeerStateUnavailable:
            NSLog(@"[in iPad] peer is UNavailable");
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
            
            for(int i=0; i < [self.peerIdMutArray count]; i++)
            {
                NSString *recordedPeerID = [self.peerIdMutArray objectAtIndex:i];
                
                if([recordedPeerID isEqualToString:peer])
                {
                    PeerIphoneViewController *peerVC = (PeerIphoneViewController *)[self.peerIphoneVCMutArray objectAtIndex:i];
                    
                    Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
                    theCard.isFacingUp = cardFacing;
                    UIImage *cardImage = theCard.cardImage;
                    
                    if(! cardFacing)
                    {
                        cardImage = self.backsideImage;
                    }
                                        
                    UIImageView *cardImgView = [[UIImageView alloc] initWithImage:cardImage];
                    cardImgView.userInteractionEnabled = YES;
                    
                    cardImgView.frame = CGRectMake(peerVC.view.frame.origin.x, 
                                                   peerVC.view.frame.origin.y, 
                                                   CARD_WIDTH, CARD_HEIGHT);
                    
                    
                    cardImgView.center = CGPointMake(peerVC.view.center.x, 
                                                     peerVC.view.center.y + 50);
                    
                    
                    
                    cardImgView.tag = cardIdx;//tag the card
                    
                    //add gesture recognizers
                    
                    
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
                    
                    
                    
                    //=== pan gesture
                    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
                    
                    [cardImgView addGestureRecognizer:panRecognizer]; 
                    
                    [panRecognizer release];        
                    
                    
                    
                    
                    //add card to the container view
                    [self.cardContainerImgView addSubview:cardImgView];
                    
                    
                    
                    
                    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
                        
                        cardImgView.center = CGPointMake(cardImgView.center.x,
                                                         cardContainerImgView.center.y);
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                    
                    [cardImgView release];
                    
                    
                    break;
                }
            }
        }
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
            NSArray *iphoneTableArray = (NSArray *)self.peerIdMutArray;
            
            NSLog(@"[in iPad] peer tbl array to send: %@", iphoneTableArray);
            
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
        //v.transform = CGAffineTransformMakeTranslation(separationVal * i, 0.0);
        
        v.frame = CGRectOffset(v.frame, separationVal * i, 0.0);
        
        i++;
    }
}

- (void)swipeCloseCardsWithDirection:(int)dir
{
    float separationVal = 30.0;
    int i=0;
    
    if(dir == 0)
    {
        //left        
        CUR_CARD_STACK_STATUS = CARD_EXPANDED_LEFT;
        
        separationVal *= -1;
    }  
    
    for(UIView *v in self.cardContainerImgView.subviews)
    {
        //v.transform = CGAffineTransformMakeTranslation(0.0, 0.0);
        
        v.frame =  CGRectOffset(v.frame, separationVal * i, 0.0);
        
        i++;
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
    
    int CARD_TAG = -1;
    
    for(int i=0; i < CARD_COUNT; i++)
    {
        UIImageView *curCardImgView = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:i];
                
        //curCardImgView.transform = CGAffineTransformMakeTranslation(-curCardImgView.transform.tx, curCardImgView.transform.ty);
        
        float cardCenterDeltaMoveX = curCardImgView.center.x - self.cardContainerImgView.center.x;
        
        /*
        curCardImgView.frame = CGRectMake(-cardCenterDeltaMoveX, 
                                          curCardImgView.frame.origin.y, 
                                          curCardImgView.frame.size.width, 
                                          curCardImgView.frame.size.height);
         */
        
        //curCardImgView.center = CGPointMake(curCardImgView.center.x - (cardCenterDeltaMoveX * 2), curCardImgView.center.y);
       
        
        if(i == (CARD_COUNT - 2))
        {
            NSLog(@"card:%d, cardCenterDeltaMoveX: %f", i, cardCenterDeltaMoveX);
            //NSLog(@"card %d frame x:%f, y:%f", i, curCardImgView.frame.origin.x, curCardImgView.frame.origin.y);
            //NSLog(@"card center: x:%f, y:%f", curCardImgView.center.x, curCardImgView.center.y);
            
            //NSLog(@"card: %d, transform tx:%f, ty:%f", i, curCardImgView.transform.tx, curCardImgView.transform.ty);
        }
        
        CARD_TAG = curCardImgView.tag;
                
        Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:CARD_TAG];
        
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

- (IBAction)connectBtnPressed:(id)sender
{
    [self startBluetooth];
}

- (IBAction)peerTestBtnPressed:(UIButton *)btn
{
    int cardIdx = 3;
    BOOL cardFacing = TRUE;
    
    if(btn.tag % 2 == 0)
    {
        cardFacing = TRUE;
    }
    else
    {
        cardFacing = FALSE;
    }
    
    Card *theCard = (Card *)[self.cardObjectMutArray objectAtIndex:cardIdx];
    theCard.isFacingUp = cardFacing;
    UIImage *cardImage = theCard.cardImage;
    
    if(! cardFacing)
    {
        cardImage = self.backsideImage;
    }
    
    PeerIphoneViewController *peerVC = (PeerIphoneViewController *)[self.peerIphoneVCMutArray objectAtIndex:btn.tag];   
    
    UIImageView *cardImgView = [[UIImageView alloc] initWithImage:cardImage];
    cardImgView.userInteractionEnabled = YES;
    
    cardImgView.frame = CGRectMake(peerVC.view.frame.origin.x, 
                                   peerVC.view.frame.origin.y, 
                                   CARD_WIDTH, CARD_HEIGHT);
    
    cardImgView.center = CGPointMake(peerVC.view.center.x, 
                                     peerVC.view.center.y + 50);
    
    
    
    cardImgView.tag = cardIdx;//tag the card
    
    //add gesture recognizers
    
    
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
    
    
    
    //=== pan gesture
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureHandler:)];
    
    panRecognizer.minimumNumberOfTouches = 1;
    panRecognizer.maximumNumberOfTouches = 1; 
    [cardImgView addGestureRecognizer:panRecognizer]; 
    
    [panRecognizer release];     
    
    
    [self.cardContainerImgView addSubview:cardImgView];
    
    
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
        
        cardImgView.center = CGPointMake(cardImgView.center.x,
                                         cardContainerImgView.center.y);
        
    } completion:^(BOOL finished) {
        
    }];
    
    
    [cardImgView release];
    
}

- (IBAction)combineCardBtnTapped:(id)sender
{
        [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveLinear animations:^(void) {
            
            
            for(UIView *v in self.cardContainerImgView.subviews)
            {
                //v.transform = CGAffineTransformMakeTranslation(0, 0);
                
                v.center = self.cardContainerImgView.center;
            }
            
            
        } completion:^(BOOL finished) {
            
            CUR_CARD_STACK_STATUS = CARD_FULLY_STACKED;
            
        }];   
}

- (IBAction)showCardOrderBtnTapped:(id)sender
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
        
        self.cardOrderView.frame = CGRectMake(self.cardOrderView.frame.origin.x, 
                                              430, 
                                              self.cardOrderView.frame.size.width, 
                                              self.cardOrderView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)dismissCardOrderView:(id)sender
{
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
        
        self.cardOrderView.frame = CGRectMake(self.cardOrderView.frame.origin.x, 
                                              768, 
                                              self.cardOrderView.frame.size.width, 
                                              self.cardOrderView.frame.size.height);
        
    } completion:^(BOOL finished) {
        
    }];    
}

- (IBAction)shuffleBtnTapped:(id)sender
{
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
        
        int SHUFFLE_RUN_TIME = 100;
        int randValCard1_idx = 0;
        int randValCard2_idx = 0; 
        int CARD_COUNT = [self.cardContainerImgView.subviews count] - 1;

       
        //the index used here is the index of the card container subviews, not the card tag !
        //the card tag is the index to the information about a particular card
        
        for(int i=0; i < SHUFFLE_RUN_TIME; i++)
        {
            randValCard1_idx = (arc4random() % [self.smallCardContainerImgView.subviews count]);
            randValCard2_idx = (arc4random() % [self.smallCardContainerImgView.subviews count]);
            
            //debugging
            //NSLog(@"randValCard1: %d", randValCard1_idx);
            //NSLog(@"randValCard2: %d", randValCard2_idx);
            
            //=== for the card order view
                        
            //get small card 1
            
            UIImageView *smallCardImgView_1 = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:randValCard1_idx];
            
            //get small card 2
            UIImageView *smallCardImgView_2 = (UIImageView *)[self.smallCardContainerImgView.subviews objectAtIndex:randValCard2_idx];
            
            //holds the frame location and tag of the first card
            CGRect tempRect = smallCardImgView_1.frame;
            //int tempTag = smallCardImgView_1.tag;
            //UIImage *tempImage = smallCardImgView_1.image;
            
            //=== swap position
            
            smallCardImgView_1.frame = smallCardImgView_2.frame;
            //smallCardImgView_1.tag = smallCardImgView_2.tag;
            //smallCardImgView_1.image = smallCardImgView_2.image;
            
            smallCardImgView_2.frame = tempRect;
            //smallCardImgView_2.tag = tempTag;
            //smallCardImgView_2.image = tempImage;
             
            
            ///=== re-arrange the original card deck
            int ORI_CARD_RAND_IDX_1 = CARD_COUNT - randValCard1_idx;
            int ORI_CARD_RAND_IDX_2 = CARD_COUNT - randValCard2_idx;
            
            
            //debugging
            //NSLog(@"ORI_CARD_RAND_IDX_1: %d", ORI_CARD_RAND_IDX_1);
            //NSLog(@"ORI_CARD_RAND_IDX_2: %d", ORI_CARD_RAND_IDX_2);
            //NSLog(@"================\n\n");  
            
            //get card 1
            UIImageView *cardImgView_1 = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:ORI_CARD_RAND_IDX_1]; 
            UIImageView *cardImgView_2 = (UIImageView *)[self.cardContainerImgView.subviews objectAtIndex:ORI_CARD_RAND_IDX_2];
            
            //holds the frame location and tag of the first card
            CGRect tempRectOri = cardImgView_1.frame;
            //int tempTagOri = cardImgView_1.tag;
            //UIImage *tempImageOri = cardImgView_1.image;
            
            
            //=== swap position
            cardImgView_1.frame = cardImgView_2.frame;
            //cardImgView_1.tag = cardImgView_2.tag;
            //cardImgView_1.image = cardImgView_2.image;
            
            cardImgView_2.frame = tempRectOri;
            //cardImgView_2.tag = tempTagOri;
            //cardImgView_2.image = tempImageOri;
            
            
            [self.smallCardContainerImgView exchangeSubviewAtIndex:randValCard1_idx withSubviewAtIndex:randValCard2_idx];
            [self.cardContainerImgView exchangeSubviewAtIndex:ORI_CARD_RAND_IDX_1 withSubviewAtIndex:ORI_CARD_RAND_IDX_2];   
        }
        
        
    } completion:^(BOOL finished) {
        
    }];    
}

@end
