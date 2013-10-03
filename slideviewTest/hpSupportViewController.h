//
//  SupportViewController.h
//  Navigation
//
/*
        Copyright 2013 Handpoint Ltd.
 
        Licensed under the Apache License, Version 2.0 (the "License");
        you may not use this file except in compliance with the License.
        You may obtain a copy of the License at
     
            http://www.apache.org/licenses/LICENSE-2.0
     
        Unless required by applicable law or agreed to in writing, software
        distributed under the License is distributed on an "AS IS" BASIS,
        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
        See the License for the specific language governing permissions and
        limitations under the License.
 */

#import <UIKit/UIKit.h>
#import "hpViewController.h"
#import <MessageUI/MessageUI.h> // To be able to send email
@interface hpSupportViewController : hpViewController <MFMailComposeViewControllerDelegate>
{
    NSDictionary *settings;
    __weak IBOutlet UIButton *phoneButton;
    __weak IBOutlet UIButton *webpageButton;

}

//Hypelink to Handpoint website, will be to help
-(IBAction)pushWebButton;
- (IBAction)ContactUS:(id)sender;
- (IBAction)callPhoneNumber:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *hotlineLabel;
@property (weak, nonatomic) IBOutlet UILabel *visitLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
- (IBAction) updateCardReader;
@property (weak, nonatomic) IBOutlet UIButton *softwareUpdateButton;
@property (weak, nonatomic) IBOutlet UIButton *supportModeLabel;

@end
