//
//  GKCardViewController_iPad.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GKPlayTableViewController_iPad;

@interface GKCardViewController_iPad : UIViewController {
    
    @private GKPlayTableViewController_iPad *gkTableIpadVC;
}

@property (nonatomic, retain) GKPlayTableViewController_iPad *gkTableIpadVC;

- (IBAction)startBtnPressed:(id)sender;
- (IBAction)quitBtnPressed:(id)sender;

@end
