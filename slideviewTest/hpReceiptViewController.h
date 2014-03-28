//
//  hpReceiptViewController.h
//  mPOS-withSlideView
//
//  Created by Jón Hilmar Gústafsson on 30.4.2013.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "hpViewController.h"
#import "hpReceipt.h"
#import "hpReceiptsDetailsTabViewController.h"

@interface hpReceiptViewController : UIViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate, UIWebViewDelegate>
{
    hpReceipt* localReceipt;
    UIWebView* webReceipt;
}

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UITextField* activeField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phonenumberField;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) hpReceipt* localReceipt;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (strong, nonatomic) IBOutlet UIWebView *webReceipt;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIView *receiptTemplate;

@end
