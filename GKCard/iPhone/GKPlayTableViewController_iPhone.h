//
//  GKPlayTableViewController_iPhone.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface GKPlayTableViewController_iPhone : UIViewController
<GKSessionDelegate, GKPeerPickerControllerDelegate> {
   
    IBOutlet UILabel *numCardsLabel;
    IBOutlet UIView *cardContainerView;
    IBOutlet UIView *swipeAreaView;
    
    @private NSMutableArray *cardDictMutArray;
    @private NSMutableArray *cardDeckImgViewMutArray;
    @private BOOL IS_FACING_FRONT;
    
    @private CGAffineTransform CARD_INITIAL_TRANSFORM;
        
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;    
}

@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UIView *cardContainerView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) NSMutableArray *cardDeckImgViewMutArray;
@property (nonatomic, retain) GKSession *currentSession;

- (void)startBluetooth;
- (void)sendCardToIPadWithIndex:(int)cardIdx;
- (void)swipeOpenCards;
- (void)swipeCloseCards;
- (IBAction)flipBtnPressed:(id)sender;
- (IBAction)disconnectBtnPressed:(id)sender;

@end
