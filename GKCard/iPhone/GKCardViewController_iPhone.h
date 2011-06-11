//
//  GKCardViewController_iPhone.h
//  GKCard
//
//  Created by sap_all\c5152815 on 6/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface GKCardViewController_iPhone : UIViewController {
 
    IBOutlet UIImageView *cardImgView;
    IBOutlet UIImageView *cardBacksideImgView;
}

@property (nonatomic, retain) UIImageView *cardImgView;
@property (nonatomic, retain) UIImageView *cardBacksideImgView;

- (IBAction)flipBtnPressed;

@end
