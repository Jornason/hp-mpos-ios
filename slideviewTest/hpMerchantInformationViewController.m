//
//  hpMerchantInformationViewController.m
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

#import "hpMerchantInformationViewController.h"

@interface hpMerchantInformationViewController ()


@end

@implementation hpMerchantInformationViewController
@synthesize activeField, merchantSettingsView, merchantName, merchantAddress;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [merchantName becomeFirstResponder];
    NSMutableDictionary * settings = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    NSString* merchantNameString = [settings objectForKey:@"merchantName"];
    merchantName.text = merchantNameString;
    NSString* merchantAddressString = [settings objectForKey:@"merchantAddress"];
    merchantAddress.text = merchantAddressString;
   	// Do any additional setup after loading the view.

    self.merchantLabel.text = Localize(@"Merchant address");
    self.nameLabel.text = Localize(@"Merchant name");
    [self.saveMerchantInfo setTitle:Localize(@"Save") forState:UIControlStateNormal];
}
- (IBAction)saveMerchantInformation:(id)sender
{
    NSMutableDictionary * settings = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    [settings setObject:merchantName.text forKey:@"merchantName"];
    [settings setObject:merchantAddress.text forKey:@"merchantAddress"];
    [settings writeToFile:path atomically:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
