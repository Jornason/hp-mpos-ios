//
//  hpMerchantInformationViewController.h
//  mPOS-withSlideView
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

@interface hpMerchantInformationViewController : hpViewController <UITextFieldDelegate, UIGestureRecognizerDelegate>
@property (strong, nonatomic) IBOutlet UIView *merchantSettingsView;
@property (weak, nonatomic) IBOutlet UITextField *merchantName;
@property (weak, nonatomic) IBOutlet UITextField *merchantAddress;
@property (weak, nonatomic) IBOutlet UITextField *activeField;
@property (weak, nonatomic) IBOutlet UIButton *saveMerchantInfo;
@property (weak, nonatomic) IBOutlet UILabel *merchantLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
