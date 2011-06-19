//
//  Card.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Card : NSObject {
    
    UIImage *cardImage;
    NSString *cardName;
    float value;
    BOOL isFacingUp;
}

@property (nonatomic, retain) UIImage *cardImage;
@property (nonatomic, retain) NSString *cardName;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) BOOL isFacingUp;

@end
