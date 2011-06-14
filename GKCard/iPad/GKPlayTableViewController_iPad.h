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

@interface GKPlayTableViewController_iPad : UIViewController
<GKSessionDelegate, GKPeerPickerControllerDelegate> {
    
    @private NSMutableArray *cardDictMutArray;
    IBOutlet UILabel *numCardsLabel;
    IBOutlet UIImageView *cardContainerImgView;
    IBOutlet UIView *swipeAreaView;
    
    @private BOOL IS_CARD_CONTAINER_FACING_FRONT;
    @private int CUR_CARD_STACK_STATUS;
    @private CGPoint netTranslation;   
    
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;

    //JSON
    @private SBJSON *sbJSON;
}

@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UIImageView *cardContainerImgView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) GKSession *currentSession;
@property (nonatomic, retain) SBJSON *sbJSON;

- (void)startBluetooth;
- (void)sendCardToIPhoneWithIndex:(int)cardIdx;
- (IBAction)flipBtnPressed:(id)sender;
- (IBAction)disconnectBtnPressed:(id)sender;

@end
