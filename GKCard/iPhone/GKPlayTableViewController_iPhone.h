//
//  GKPlayTableViewController_iPhone.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SBJSON.h"

@interface GKPlayTableViewController_iPhone : UIViewController
<GKSessionDelegate, GKPeerPickerControllerDelegate> {
   
    IBOutlet UILabel *numCardsLabel;
    IBOutlet UILabel *cardNameLabel;
    IBOutlet UIImageView *cardContainerImgView;
    IBOutlet UIView *swipeAreaView;
    
    @private NSMutableArray *cardDictMutArray;
    @private BOOL IS_FACING_FRONT;
    
    @private CGAffineTransform CARD_INITIAL_TRANSFORM;
        
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;
    
    //JSON
    @private SBJSON *sbJSON;
}

@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UILabel *cardNameLabel;
@property (nonatomic, retain) UIView *cardContainerImgView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) SBJSON *sbJSON;

- (void)startBluetooth;
- (IBAction)flipBtnPressed:(id)sender;
- (IBAction)disconnectBtnPressed:(id)sender;

@end
