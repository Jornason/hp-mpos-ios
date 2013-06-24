//
//  hpReceiptDetailsViewController.h
//  mPOS-withSlideView
//
//  Created by Jón Hilmar Gústafsson on 6.5.2013.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hpViewController.h"
#import "hpReceipt.h"
#import "hpReceiptDetailsWebViewController.h"

@interface hpReceiptDetailsViewController : UITabBarController
{
    hpReceipt* detailsReceipt;
    
}

@property (strong, nonatomic) hpReceipt* detailsReceipt;

@end
