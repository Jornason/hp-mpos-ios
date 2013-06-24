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

@interface hpReceiptViewController ()

@end

@implementation hpReceiptViewController
@synthesize scrollView, activeField, emailField, phonenumberField, webView, localReceipt,webReceipt;

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
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    [webView loadHTMLString:[localReceipt htmlReceipt] baseURL:nil];
    webView.scrollView.bounces = NO;
    webView.scrollView.scrollEnabled = YES;
    
    [self registerForKeyboardNotifications];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    gestureRecognizer.delegate = self;
    [scrollView addGestureRecognizer:gestureRecognizer];
    self.emailField.placeholder = Localize(@"E-mail address");
    [self.detailsButton setTitle:Localize(@"Details") forState:UIControlStateNormal];

	// Do any additional setup after loading the view.
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
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSString* filename = [NSString stringWithFormat:@"%d.png", localReceipt.receiptID];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:filePath error:NULL];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == emailField)
    {
        [self sendCustomerReceipt];
        [textField resignFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    return NO;
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
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, self.navigationController.view.frame.size.height, kbSize.height, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your application might not need or want this behavior.
    CGRect aRect = self.view.frame;
    aRect.size.height -= kbSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, activeField.frame.origin.y-kbSize.height+10);
        [scrollView setContentOffset:scrollPoint animated:YES];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    CGPoint scrollPoint = CGPointMake(0.0, -40.0);
    [scrollView setContentOffset:scrollPoint animated:YES];
}


- (void) sendCustomerReceipt {
    NSLog(@"send customer receipt");
    webReceipt = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 595, 0)];
    NSString* customerReceipt;
    
    [webReceipt setDelegate:self];
    
    // Remove {COPY_RECEIPT} placeholder
    if ([localReceipt customerIsCopy])
    {
        customerReceipt = [localReceipt customerReceipt];
    }
    else
    {
         customerReceipt = [[localReceipt customerReceipt] stringByReplacingOccurrencesOfString:@"{COPY_RECEIPT}" withString:@""];
    }
    // TODO: Add functionality so we know if receipt is being sent for the first time or not.
    
     NSLog(@"Customer receipt: %@", customerReceipt);
    [webReceipt loadHTMLString:customerReceipt baseURL:nil];
    NSLog(@"Webview is loading...");
    //The rest is handled in the delegate webViewDidFinishLoad
    
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"customerReceipt webview loaded");
    
    // Get full height of content
    NSString *heightStr = [webReceipt stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    int height = [heightStr intValue];
    
    // Set height
    [webReceipt setFrame:CGRectMake(0.f, 0.f, 595, height)];
    
    // Convert to pdf
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, webReceipt.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [webReceipt.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    
    // And finally mail it!
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
    [mailController setMailComposeDelegate:self];
    NSString *email = emailField.text;
    NSArray *emailArray = [[NSArray alloc] initWithObjects:email, nil];
    [mailController setToRecipients:emailArray];
    [mailController setSubject:Localize(@"Receipt from mPOS")];
    [mailController setMessageBody:Localize(@"Regards") isHTML:YES];
    [mailController addAttachmentData:pdfData mimeType:@"application/pdf" fileName:@"Receipt.pdf"];
    [self presentViewController:mailController animated:YES completion:nil];
    if (![localReceipt customerIsCopy])
    {
        [localReceipt customerReceiptIsCopy];
    }
    
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)detailsButton:(id)sender {
    hpReceiptsDetailsTabViewController* detailTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptDetailsTabBar"];
    detailTabController.tabBarReceipt = localReceipt;
    [self.navigationController pushViewController:detailTabController animated:YES];
    
}

@end
