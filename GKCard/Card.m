//
//  Card.m
//  GKCard
//
//  Created by sap_all\c5152815 on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Card.h"


@implementation Card

@synthesize cardImage;
@synthesize cardName;
@synthesize value;
@synthesize isFacingUp;

- (id)init
{
    return self;
}

- (void)dealloc
{
    [cardImage release];
    [cardName release];
    
    [super dealloc];
}

@end
