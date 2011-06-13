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
    
    @private NSMutableArray *cardDictMutArray;
    IBOutlet UILabel *numCardsLabel;
    IBOutlet UIView *cardContainerView;
    IBOutlet UIView *swipeAreaView;
    
    //bluetooth
    @private GKSession *currentSession;
    @private GKPeerPickerController *picker;
    
    @private int CUR_CARD_STACK_STATUS;
    @private CGPoint netTranslation;
}

@property (nonatomic, retain) NSMutableArray *cardDictMutArray;
@property (nonatomic, retain) UILabel *numCardsLabel;
@property (nonatomic, retain) UIView *cardContainerView;
@property (nonatomic, retain) UIView *swipeAreaView;
@property (nonatomic, retain) GKSession *currentSession;

- (void)startBluetooth;
- (void)sendCardToIPhoneWithIndex:(int)cardIdx;
- (IBAction)disconnectBtnPressed:(id)sender;

@end
