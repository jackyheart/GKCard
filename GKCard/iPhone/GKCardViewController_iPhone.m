//
//  GKCardViewController_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GKCardViewController_iPhone.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )

@implementation GKCardViewController_iPhone

@synthesize cardContainerView;
@synthesize cardImgView;
@synthesize cardBacksideImgView;
@synthesize swipeAreaView;

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
    [cardContainerView release];
    [cardImgView release];
    [cardBacksideImgView release];
    [swipeAreaView release];
    
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
    
    
    //NSLog(@"Swipe left started at (%f,%f)",location.x,location.y);
    
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft)
    {
        NSLog(@"left swipe detected");
    }
    else if(recognizer.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@"right swipe detected");
    }
    else
    {
        NSLog(@"other direction detected");
    }
}

#pragma mark - App logic

- (IBAction)flipBtnPressed
{
    /*
    [UIView transitionFromView:self.cardImgView toView:self.cardBacksideImgView duration:1.0 options:UIViewAnimationTransitionFlipFromRight completion:^(BOOL finished) { }];
     */
    
    int animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    
    if(IS_FACING_FRONT)
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromRight;
    }
    else 
    {
        animationOptionIdx = UIViewAnimationOptionTransitionFlipFromLeft;
    }
    
    
    [UIView transitionWithView:self.cardContainerView
                      duration:1.0
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
     
                    completion:NULL];   
}

@end
