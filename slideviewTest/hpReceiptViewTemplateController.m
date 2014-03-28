//
//  hpReceiptViewTemplateViewController.m
//  mPOS
//
//  Created by Juan Nuñez on 9/17/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "hpReceiptViewTemplateController.h"
#import "HpUtils.h"
//#import "hpReceiptViewController.h"

@interface hpReceiptViewTemplateController ()

@end

@implementation hpReceiptViewTemplateController
@synthesize emailField, phoneNumberField, activeField, localReceipt, parentVC, webReceipt;

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
    [self.emailField setDelegate:self];
    [self.phoneNumberField setDelegate:self];
    if(!sharedHeftService)
    {
        sharedHeftService =[hpHeftService sharedHeftService];
    }
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard:)];
    gestureRecognizer.delegate = self;
    self.emailField.placeholder = Localize(@"E-mail address");
    self.phoneNumberField.placeholder = Localize(@"Phone Number");
    [self.detailsButton setTitle:Localize(@"Details") forState:UIControlStateNormal];
    [self.voidButton setTitle:Localize(@"Reverse") forState:UIControlStateNormal];

    self.authStatusLabel.text   = [localReceipt.xml objectForKey: @"FinancialStatus"];
    self.authCodeLabel.text     = [localReceipt.xml objectForKey: @"StatusMessage"];
    self.dateLabel.text         = [NSString stringWithFormat:@"Date: %@",[HpUtils formatEFTTimestamp:[localReceipt.xml objectForKey: @"EFTTimestamp"]]];
    self.amountLabel.text       = localReceipt.ammountWithCurrencySymbol;
    //self.descriptionLabel.text  = localReceipt.description;
    //UIFont* defaultFont         = [UIFont fontWithName:@"Roboto" size:self.ammountDisplay.font.pointSize];
    //self.ammountDisplay.font    = defaultFont;
    
    self.startx = self.dateLabel.frame.origin.x;
    self.starty = self.amountLabel.frame.origin.y + self.amountLabel.frame.size.height + 12.0;
    
   }

-(void)loadWithReceipt:(hpReceipt*)receipt{
    CGFloat height = 0.0;
    self.authStatusLabel.text   = [localReceipt.xml objectForKey: @"FinancialStatus"];
    self.authCodeLabel.text     = [localReceipt.xml objectForKey: @"StatusMessage"];
    self.dateLabel.text         = [NSString stringWithFormat:@"Date: %@",[HpUtils formatEFTTimestamp:[localReceipt.xml objectForKey: @"EFTTimestamp"]]];
    if(localReceipt.image != NULL){
        
        CGRect pictureRect = CGRectMake(self.startx, self.starty, self.dateLabel.frame.size.width, 200);
        self.pictureImage = [[UIImageView alloc] initWithFrame:pictureRect];
        self.pictureImage.image     = localReceipt.image;
        height = self.pictureImage.frame.size.height;
        self.starty += self.pictureImage.frame.size.height;
        [self.view addSubview:self.pictureImage];
        [self repositionForHeight:height];
    }
   
   
     NSString *cardSchemeName   = [localReceipt.xml objectForKey: @"CardSchemeName"];
     self.creditCardImage.image = [HpUtils getCardSchemeLogo:cardSchemeName];
     
     
    self.amountLabel.text       = localReceipt.ammountWithCurrencySymbol;
    if([localReceipt.description isEqual: @""] == NO){
        CGRect labelRect = CGRectMake(self.startx, self.starty, self.dateLabel.frame.size.width, 41);
        self.descriptionLabel = [[UILabel alloc] initWithFrame:labelRect];
        self.descriptionLabel.text = localReceipt.description;
        self.descriptionLabel.font = self.authCodeLabel.font;
        self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
        self.descriptionLabel.numberOfLines = 2;
        height = self.descriptionLabel.frame.size.height;
        [self.view addSubview:self.descriptionLabel];
        [self repositionForHeight:height];
    }
    
    // if a sale/refund was authorized - allow void.
    if ([self.authStatusLabel.text isEqualToString:(@"AUTHORISED")] && ([[localReceipt.xml objectForKey:@"TransactionType"] isEqualToString:(@"SALE")] || [[localReceipt.xml objectForKey:@"TransactionType"] isEqualToString:(@"REFUND")]))
    {
        if(![sharedHeftService isTransactionVoid:[localReceipt.xml objectForKey:@"EFTTransactionID"]]){
            //transaction hasn't been voided before
            [self.voidButton setEnabled:YES];
            [self.voidButton setHidden:NO];
        }
        else{
            CGRect imageRect = self.receiptMiddleImage.frame;
            imageRect.size.width -= 16;
            imageRect.origin.x +=8;
            
            UIImageView *redStripeImage = [[UIImageView alloc] initWithFrame:imageRect];
            redStripeImage.image = [UIImage imageNamed: @"voided.png"];
            redStripeImage.alpha = 0.7;
            [self.view addSubview:redStripeImage];
            [self.voidButton setEnabled:NO];
            [self.voidButton setHidden:YES];
        }
    }
    else
    {
        [self.voidButton setEnabled:NO];
        [self.voidButton setHidden:YES];
    }
}
-(void)repositionForHeight:(CGFloat)height{
    // We need to align the bottom of the receipt slip
    float bottomOffset = -30;
    if(height > 0.0){
        for(UIView *view in self.view.subviews){
            if(view.frame.origin.y >= (self.receiptMiddleImage.frame.origin.y + self.receiptMiddleImage.frame.size.height)){
                CGRect rectBottom = view.frame;
                rectBottom.origin.y += height + bottomOffset;
                view.frame = rectBottom;
            }
        }
        
        CGRect rectMiddle = self.receiptMiddleImage.frame;
        rectMiddle.size.height += height + bottomOffset;
        self.receiptMiddleImage.frame = rectMiddle;
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"receiptContent"]) {
        self.parentVC = segue.destinationViewController;
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewWillAppear:(BOOL)animated
{
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == emailField)
    {
        [TestFlight passCheckpoint:RECEIPT_EMAIL_SENT];
        [self sendCustomerReceiptEmail];
    }
    else if(textField == phoneNumberField)
    {
        [TestFlight passCheckpoint:RECEIPT_SMS_SENT];
        [self sendCustomerReceiptSms];
    }
    [textField resignFirstResponder];
    return NO;
}

- (void) sendCustomerReceiptEmail {
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
    [self.webReceipt.layer renderInContext:pdfContext];
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
    if (localReceipt.image != nil)
    {
        NSData *imageData = UIImagePNGRepresentation(localReceipt.image);
        [mailController addAttachmentData:imageData mimeType:@"image/png" fileName:@"image.png"];
    }
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

-(NSString*) getReceiptForSms {
    // Sorry! Quick and dirty removal of html tags
    NSRange r;
    NSString *s;
    NSString *desc = [localReceipt.description stringByAppendingString:@"\n"];
    
    // Remove {COPY_RECEIPT} placeholder
    if ([localReceipt customerIsCopy])
    {
        s = [localReceipt customerReceipt];
    }
    else
    {
        s = [[localReceipt customerReceipt] stringByReplacingOccurrencesOfString:@"{COPY_RECEIPT}" withString:@""];
    }
    
    // Clean out all start tags
    while ((r = [s rangeOfString:@"<[^/>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@""];
    }
    // Replace closing tags with newline
    while ((r = [s rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound) {
        s = [s stringByReplacingCharactersInRange:r withString:@"\n"];
    }
    // Add description on top
    s = [desc stringByAppendingString:s];
    return s;
}

-(void) sendCustomerReceiptSms {
    MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc]init];
    if([MFMessageComposeViewController canSendText])
    {   
        controller.body = self.getReceiptForSms;
        controller.recipients = [NSArray arrayWithObjects:self.phoneNumberField.text, nil];
        controller.messageComposeDelegate = self;
        [self presentViewController:controller animated:YES completion:nil];
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)voidButton:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"Reverse")
                                                    message:Localize(@"Reverse are you sure")
                                                   delegate:self
                                          cancelButtonTitle:Localize(@"No")
                                          otherButtonTitles:Localize(@"Yes"),nil];
    [alert show];
}

- (IBAction)insertDescription:(id)sender {
}

- (IBAction)detailsButton:(id)sender {
    [TestFlight passCheckpoint:VIEW_DETAILS];
    hpReceiptsDetailsTabViewController* detailTabController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReceiptDetailsTabBar"];
    detailTabController.tabBarReceipt = localReceipt;
    [self.navigationController pushViewController:detailTabController animated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger) buttonIndex{
    
    if (buttonIndex == 1) {
        Currency* currency = [[Currency alloc] initWithCode:[localReceipt.xml objectForKey:@"Currency"]];
        if ([[localReceipt.xml objectForKey:@"TransactionType"] isEqualToString:(@"SALE")])
        {
            
            
            [sharedHeftService saleVoidWithAmount:localReceipt.authorisedAmount currency:currency.currencyCode cardholder:YES transaction:localReceipt.transactionId];
        }
        else if ([[localReceipt.xml objectForKey:@"TransactionType"] isEqualToString:(@"REFUND")])
        {
            [sharedHeftService refundVoidWithAmount:localReceipt.authorisedAmount currency:currency.currencyCode cardholder:YES transaction:localReceipt.transactionId];
        }
    } else {
        // Cancel
    }
}


@end
