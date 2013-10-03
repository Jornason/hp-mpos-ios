//
//  hpInAppSettingsViewViewController.h
//  mPOS
//
//  Created by Juan Nuñez on 9/24/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "IASKAppSettingsViewController.h"
#import <UIKit/UIKit.h>
#import "hpViewController.h"
#import <MessageUI/MessageUI.h> // To be able to send email

@interface hpInAppSettingsViewController: hpViewController <IASKSettingsDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate> {
    NSDictionary *settings;
    IASKAppSettingsViewController *appSettingsViewController;
    IASKAppSettingsViewController *tabAppSettingsViewController;
    UIAlertView *fetchingLogsAlert;
}

//@property IASKAppSettingsViewController *cont;
@property (nonatomic, retain) IASKAppSettingsViewController *appSettingsViewController;
@property (nonatomic, retain) IBOutlet IASKAppSettingsViewController *tabAppSettingsViewController;
@property (nonatomic, retain) UIAlertView *fetchingLogsAlert;
@end
