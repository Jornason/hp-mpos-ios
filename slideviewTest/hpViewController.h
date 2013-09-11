//
//  egViewController.h
//  slideviewTest
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
#import "hpHeftService.h"
#import "Draw SignatureViewController.h"

@class hpWebViewController;
@interface hpViewController : UIViewController <UITextFieldDelegate>
{
    hpHeftService* sharedHeftService;
    NSString *path;
    NSMutableDictionary *hpViewSettings;
    NSString* storedAmount;
    NSString *selectedCurrency;
}

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIView *firstView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UIView *thirdView;
@property (weak, nonatomic) IBOutlet UIView *numpadView;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UILabel *ammountDisplay;
@property (weak, nonatomic) IBOutlet UILabel *currencyDisplay;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (weak, nonatomic)  UIImage *descriptionImage;
@property (weak, nonatomic) NSMutableDictionary *hpViewSettings;
@property (weak, nonatomic) IBOutlet UIButton *payButton;
@property (weak, nonatomic) IBOutlet UIButton *payRefundToggleButton;
@property (weak, nonatomic) IBOutlet UILabel *payRefundToggleLable;
@property (weak, nonatomic) IBOutlet UIButton *refundButton;

@property (weak, nonatomic) IBOutlet UILabel *listOfRecordsLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *socialLabel;
@property (weak, nonatomic) IBOutlet UILabel *userGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemsLabel;
@property (weak, nonatomic) IBOutlet UILabel *listOfRecordsButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *supportLabel;
@property (weak, nonatomic) IBOutlet UILabel *settingsButtonLabel;
@property (weak, nonatomic) IBOutlet UILabel *discoverLabel;

-(NSString*)formatAmount:(NSString*)amount forCurrency:(NSString*)currency;

@end
