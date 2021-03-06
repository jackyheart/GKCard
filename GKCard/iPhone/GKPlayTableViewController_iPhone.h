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
    IBOutlet UIView *bluetoothSendView;
    IBOutlet UIImageView *bluetoothOverlayImgView;
    
    @private UIImage *backsideImage;//backside img
    
    @private NSMutableArray *cardDictMutArray;
    @private NSMutableArray *cardObjectMutArray;
    @private BOOL IS_CARD_CONTAINER_FACING_FRONT;
    @private int CUR_CARD_STACK_STATUS;
    @private NSMutableArray *peerIdMutArray;
    
    @private CGAffineTransform CARD_INITIAL_TRANSFORM;
        
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;
    @private NSString *MASTER_PEER_ID;
    
    //JSON
    @private SBJSON *sbJSON;
}

@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UILabel *cardNameLabel;
@property (nonatomic, retain) UIImageView *cardContainerImgView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) UIView *bluetoothSendView;
@property (nonatomic, retain) UIImageView *bluetoothOverlayImgView;
@property (nonatomic, retain) UIImage *backsideImage;
@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) NSMutableArray *cardObjectMutArray;
@property (nonatomic, retain) NSMutableArray *peerIdMutArray;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) SBJSON *sbJSON;

- (IBAction)flipBtnPressed:(id)sender;
- (IBAction)connectDisconnectBtnPressed:(id)sender;
- (IBAction)testBtnPressed:(id)sender;

@end
