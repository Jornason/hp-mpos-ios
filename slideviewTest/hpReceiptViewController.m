//
//  hpReceiptViewController.m
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

#import "hpReceiptViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "hpReceiptViewTemplateController.h"

@interface hpReceiptViewController ()

@end

@implementation hpReceiptViewController
@synthesize scrollView, activeField, emailField, phonenumberField, webView, localReceipt,webReceipt, receiptTemplate;

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
    [emailField setDelegate:self];
    [phonenumberField setDelegate:self];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    gestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:gestureRecognizer];

    [self.detailsButton setTitle:Localize(@"Details") forState:UIControlStateNormal];
    NSLog(@"children : %@", self.childViewControllers);
    hpReceiptViewTemplateController *dvc = (hpReceiptViewTemplateController *)self.childViewControllers[0];
    dvc.localReceipt =  self.localReceipt;
    dvc.scrollView = self.scrollView;
    [dvc loadWithReceipt:self.localReceipt];
    NSLog(@"dvc height in load: %F",dvc.view.bounds.size.height);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, dvc.phoneNumberField.frame.origin.y + dvc.phoneNumberField.frame.size.height+10);
    

}

-(void) hideKeyBoard:(id) sender
{
    [activeField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self registerForKeyboardNotifications];
    [self.scrollView setContentOffset:CGPointZero animated:YES];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString* filename = [NSString stringWithFormat:@"%d.png", localReceipt.receiptID];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    
    //[self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [activeField resignFirstResponder];
}


// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSLog(@"Attn. Keyboard was shown in scroll view container");
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    float keyboardTopMargin = 5.0;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height+keyboardTopMargin, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    // TODO: Scroll Back
}


//- (IBAction)detailsButton:(id)sender {
//    hpReceiptsDetailsTabViewController* detailTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptDetailsTabBar"];
//    detailTabController.tabBarReceipt = localReceipt;
//    [self.navigationController pushViewController:detailTabController animated:YES];
//    
//}

@end
