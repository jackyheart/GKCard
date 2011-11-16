//
//  GKPlayTableViewController_iPad.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "SBJSON.h"

@class DisclaimerViewController_iPad;

@interface GKPlayTableViewController_iPad : UIViewController
<GKSessionDelegate, GKPeerPickerControllerDelegate> {
    
    IBOutlet UILabel *numCardsLabel;
    IBOutlet UILabel *cardNameLabel;
    IBOutlet UIImageView *cardContainerImgView;
    IBOutlet UIView *swipeAreaView;
    IBOutlet UIView *cardOrderView;
    IBOutlet UIImageView *smallCardContainerImgView;
    
    @private UIImage *backsideImage;//backside img
    @private NSMutableArray *cardDictMutArray;
    @private NSMutableArray *cardObjectMutArray;
    
    @private BOOL IS_CARD_CONTAINER_FACING_FRONT;
    @private int CUR_CARD_STACK_STATUS;
    @private CGPoint netTranslation;
    @private NSMutableArray *peerIphoneVCMutArray;
    @private NSMutableArray *peerIdMutArray;
    
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;
    @private NSString *REMOTE_ATTEMPT_PEER_ID;

    //JSON
    @private SBJSON *sbJSON;
    
    //for testing
    @private NSMutableArray *sentOutCardMutArray;
    
    @private DisclaimerViewController_iPad *disclaimerVC_iPad;
}

@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UILabel *cardNameLabel;
@property (nonatomic, retain) UIImageView *cardContainerImgView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) UIView *cardOrderView;
@property (nonatomic, retain) UIImageView *smallCardContainerImgView;
@property (nonatomic, retain) UIImage *backsideImage;
@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) NSMutableArray *cardObjectMutArray;
@property (nonatomic, retain) NSMutableArray *peerIphoneVCMutArray;
@property (nonatomic, retain) NSMutableArray *peerIdMutArray;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) SBJSON *sbJSON;
@property (nonatomic, retain) NSMutableArray *sentOutCardMutArray;
@property (nonatomic, retain) DisclaimerViewController_iPad *disclaimerVC_iPad;

- (void)startBluetooth;
- (IBAction)flipBtnPressed:(id)sender;
- (IBAction)disconnectBtnPressed:(id)sender;
- (IBAction)peerTestBtnPressed:(UIButton *)btn;
- (IBAction)combineCardBtnTapped:(id)sender;
- (IBAction)showCardOrderBtnTapped:(id)sender;
- (IBAction)dismissCardOrderView:(id)sender;
- (IBAction)shuffleBtnTapped:(id)sender;
- (IBAction)connectBtnPressed:(id)sender;
- (IBAction)disclaimerIpadBtnPressed:(id)sender;

@end
