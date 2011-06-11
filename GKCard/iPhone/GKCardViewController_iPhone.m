//
//  GKCardViewController_iPhone.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GKCardViewController_iPhone.h"


@implementation GKCardViewController_iPhone

@synthesize cardImgView;
@synthesize cardBacksideImgView;

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
    [cardImgView release];
    [cardBacksideImgView release];
    
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

#pragma mark - App logic

- (IBAction)flipBtnPressed
{
    /*
    [UIView transitionFromView:self.cardImgView toView:self.cardBacksideImgView duration:1.0 options:UIViewAnimationTransitionFlipFromRight completion:^(BOOL finished) { }];
     */
    
    [UIView transitionWithView:self.cardImgView
                      duration:0.5
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{ 
                        
                        [self.cardImgView removeFromSuperview]; 
                        [self.view addSubview:self.cardBacksideImgView]; 
                    }
     
                    completion:NULL];   
}

@end
