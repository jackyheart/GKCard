//
//  GKCardViewController_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GKCardViewController_iPhone.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation GKCardViewController_iPhone

@synthesize numCardsLabel;
@synthesize cardContainerView;
@synthesize cardImgView;
@synthesize cardBacksideImgView;
@synthesize swipeAreaView;
@synthesize cardDictMutArray;
@synthesize cardDeckImgViewMutArray;

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
    [cardImgView release];
    [cardBacksideImgView release];
    [swipeAreaView release];
    [cardDictMutArray release];
    [cardDeckImgViewMutArray release];
    
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
        curCardImgView.layer.anchorPoint = CGPointMake(0.5, 1.0);
        
        curCardImgView.frame = CGRectMake(67.0, 15.0, 187.0, 261.0);
        
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

#pragma mark - App logic

- (IBAction)flipBtnPressed
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
                            
                            [self.cardImgView removeFromSuperview]; 
                            [self.cardContainerView addSubview:self.cardBacksideImgView]; 
                        }
                        else
                        {
                            IS_FACING_FRONT = TRUE;
                            
                            [self.cardBacksideImgView removeFromSuperview]; 
                            [self.cardContainerView addSubview:self.cardImgView];                             
                        }
                    }
     
                    completion:^(BOOL finished) {
                        
                    }];
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

@end
