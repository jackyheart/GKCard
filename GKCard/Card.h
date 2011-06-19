//
//  Card.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Card : NSObject {
    
    NSString *imageName;
    NSString *humanName;
    float value;
    BOOL isFacingUp;
}

@property (nonatomic, retain) NSString *imageName;
@property (nonatomic, retain) NSString *humanName;
@property (nonatomic, assign) float value;
@property (nonatomic, assign) BOOL isFacingUp;

@end
