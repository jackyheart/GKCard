//
//  GKCardViewController_iPhone.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class GKPlayTableViewController_iPhone;

@interface GKCardViewController_iPhone : UIViewController 
{
    @private GKPlayTableViewController_iPhone *gkTableIphoneVC;
}

@property (nonatomic, retain) GKPlayTableViewController_iPhone *gkTableIphoneVC;

- (IBAction)startBtnPressed:(id)sender;
- (IBAction)quitBtnPressed:(id)sender;


@end
