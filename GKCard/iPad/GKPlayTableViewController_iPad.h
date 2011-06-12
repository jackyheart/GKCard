//
//  GKPlayTableViewController_iPad.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface GKPlayTableViewController_iPad : UIViewController
<GKSessionDelegate, GKPeerPickerControllerDelegate> {
    
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;     
}

@property (nonatomic, retain) GKSession *currentSession;

- (void)startBluetooth;
- (void)sendCardToIPhoneWithIndex:(int)cardIdx;
- (IBAction)disconnectBtnPressed:(id)sender;

@end
