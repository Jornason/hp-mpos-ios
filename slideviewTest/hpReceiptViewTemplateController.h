//
//  hpReceiptViewTemplateViewController.h
//  mPOS
//
//  Created by Juan Nuñez on 9/17/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "hpViewController.h"
#import "hpReceiptViewController.h"
#import <MessageUI/MessageUI.h>
#import "hpReceipt.h"
#import "hpReceiptsDetailsTabViewController.h"

@interface hpReceiptViewTemplateController : hpViewController <UITextFieldDelegate, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate,MFMessageComposeViewControllerDelegate, UIWebViewDelegate>
{
    hpReceipt* localReceipt;
    UIWebView* webReceipt;
    UIScrollView *scrollView;
    
}



@property (weak, nonatomic) IBOutlet UILabel *authStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *authCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *creditCardImage;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (strong, nonatomic) IBOutlet UIImageView *pictureImage;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *detailsButton;
@property (weak, nonatomic) IBOutlet UILabel *wouldReceiptLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (strong, nonatomic) UITextField* activeField;
@property (strong, nonatomic) hpReceipt* localReceipt;
@property (strong, nonatomic) IBOutlet UIWebView *webReceipt;
@property (weak,nonatomic) hpReceiptViewController * parentVC;
@property (weak, nonatomic) IBOutlet UIImageView *receiptMiddleImage;
@property (weak, nonatomic) IBOutlet UIImageView *receiptBottomImage;
@property (weak, nonatomic) IBOutlet UIImageView *separatorTopImage;
@property (weak, nonatomic) IBOutlet UIImageView *separatorBottomImage;
@property (weak, nonatomic) IBOutlet UIButton *voidButton;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (weak, nonatomic) IBOutlet UIButton *descriptionButton;
- (IBAction)insertDescription:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *insertPhoto;
@property CGFloat startx;
@property CGFloat starty;

- (IBAction)detailsButton:(id)sender;
- (IBAction)voidButton:(id)sender;
-(void)loadWithReceipt:(hpReceipt*)receipt;
-(NSString*) getReceiptForSms;


@end
