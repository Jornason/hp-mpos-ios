//
//  egViewController.m
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

#import <QuartzCore/QuartzCore.h>
#import "hpViewController.h"
#import "hpUtils.h"
#import "hpReceiptViewController.h"
#import "TransactionViewController.h"
#import "BWStatusBarOverlay.h"
#import <tgmath.h> 

@interface hpViewController ()
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;

@end

@implementation hpViewController

@synthesize ammountDisplay, currencyDisplay, descriptionTextField, descriptionImage;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;

- (IBAction)digitPressed:(UIButton *)sender
{
    NSString *digit = [sender currentTitle];
    if (self.userIsInTheMiddleOfEnteringANumber)
    {
        storedAmount = [storedAmount stringByAppendingString:digit];
    }
    else
    {
        storedAmount = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    self.ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];

}
- (IBAction)handleTap:(UITapGestureRecognizer *)sender
{
    if ( storedAmount > 0)
    {
        storedAmount = [storedAmount substringToIndex:storedAmount.length - 1];
        if (storedAmount.length == 0)
        {
            self.userIsInTheMiddleOfEnteringANumber = NO;
            storedAmount = @"0";
            
        }
    }
    self.ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];
}

-  (IBAction)handleLongPress:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        self.userIsInTheMiddleOfEnteringANumber = NO;
        storedAmount = @"0";
        self.ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];
    }
}


- (IBAction) startSale
{

    //get current currency
    NSUserDefaults *settings        = [NSUserDefaults standardUserDefaults];
    selectedCurrency = [settings valueForKey:@"SelectedCurrency"];
    
    int amount = [HpUtils formatSendableAmount:[storedAmount intValue] withCurrency:selectedCurrency];
    NSLog(@"Amount: %d", amount);
    NSLog(@"Currency: %@", selectedCurrency);
    if(sharedHeftService.heftClient != nil)
    {
        if(amount != 0)
        {
            //Read the amount and send it to the SDK
            sharedHeftService.transactionDescription = [descriptionTextField text];
            [sharedHeftService saleWithAmount:amount currency:selectedCurrency cardholder:YES];
            //[self showTransactionViewController:eTransactionSale];
            self.userIsInTheMiddleOfEnteringANumber = NO;
            storedAmount = @"0";
        }
    }
    else
    {
        [sharedHeftService checkForDefaultCardReader];
        UIAlertView *status = [[UIAlertView alloc] initWithTitle:Localize(@"Error")
                                                         message:Localize(@"No reader connected")
                                                        delegate:nil
                                               cancelButtonTitle:Localize(@"Ok")
                                               otherButtonTitles:nil];
        [status show];
    }
}
- (IBAction)startRefund:(id)sender
{
    NSUserDefaults *settings        = [NSUserDefaults standardUserDefaults];
    selectedCurrency = [settings objectForKey:@"SelectedCurrency"];
    
    int amount = [HpUtils formatSendableAmount:[storedAmount intValue] withCurrency:selectedCurrency];
    NSLog(@"Amount: %d", amount);
    NSLog(@"Currency: %@", selectedCurrency);
    if(sharedHeftService.heftClient != nil)
    {
        if(amount != 0)
        {
            //Read the amount and send it to the SDK
            sharedHeftService.transactionDescription = [descriptionTextField text];
            [sharedHeftService refundWithAmount:amount currency:selectedCurrency cardholder:YES];
            //[self showTransactionViewController:eTransactionRefund];
            self.userIsInTheMiddleOfEnteringANumber = NO;
            storedAmount = @"0";
        }
    }
    else
    {
        [sharedHeftService checkForDefaultCardReader];
        UIAlertView *status = [[UIAlertView alloc] initWithTitle:Localize(@"Error")
                                                         message:Localize(@"No reader connected")
                                                        delegate:nil
                                               cancelButtonTitle:Localize(@"Ok")
                                               otherButtonTitles:nil];
        [status show];
    }    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    storedAmount = @"0";
    //load config file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
    self.descriptionTextField.delegate = self;
    
    UIFont* defaultFont = [UIFont fontWithName:@"Roboto" size:self.ammountDisplay.font.pointSize];
    self.ammountDisplay.font = defaultFont;
    
    //Setup slideView
    UIImage* background = [UIImage imageNamed: @"Background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    [self.scrollView addSubview:_firstView];
    [self.scrollView addSubview:_secondView];
    [self.scrollView addSubview:_thirdView];
   
    CGRect scrollFrame;
    scrollFrame.origin = self.scrollView.frame.origin;
    scrollFrame.size = CGSizeMake(self.scrollView.frame.size.width, self.mainView.frame.size.height - 48);
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * self.scrollView.subviews.count, self.scrollView.frame.size.height);
    
    CGRect startFrame = self.scrollView.frame;
    startFrame.origin.x = startFrame.size.width * 1;
    startFrame.origin.y = 0;
    [self.scrollView scrollRectToVisible:startFrame animated:YES];
    
    
    //Create a sharedHeftService object
    if(!sharedHeftService)
    {
        sharedHeftService =[hpHeftService sharedHeftService];
    }
    if (sharedHeftService.heftClient == nil)
    {
        [sharedHeftService checkForDefaultCardReader];
    }
    
    // Recieve notification from hpHeftService when transaction is done
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadWebViewController:)
                                                 name:@"transactionFinished"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadSignatureController:)
                                                 name:@"requestSignature"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearAmount:)
                                                 name:@"refreshData"
                                               object:nil];

    //Setup localozation in buttons
    [self.payButton setTitle:Localize(@"Pay") forState:UIControlStateNormal];
    [self.refundButton setTitle:Localize(@"Refund") forState:UIControlStateNormal];
    self.payRefundToggleLable.text      = Localize(@"Refund");
    self.listOfRecordsLabel.text        = Localize(@"Payment history");
    self.settingLabel.text              = Localize(@"Menu");
    self.logoutLabel.text               = Localize(@"Logout");
    self.socialLabel.text               = Localize(@"Social");
    self.userGuideLabel.text            = Localize(@"User guide");
    self.itemsLabel.text                = Localize(@"Items");
    self.listOfRecordsButtonLabel.text  = Localize(@"Payment history");
    self.supportLabel.text              = Localize(@"About Handpoint");
    self.settingsButtonLabel.text       = Localize(@"Settings");
    self.discoverLabel.text             = Localize(@"Connect");
    self.descriptionTextField.placeholder = Localize(@"+ Description");
    self.ammountDisplay.font = defaultFont;
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(handleTap:)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.backspaceButton addGestureRecognizer:tapRecognizer];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.8;
    [self.backspaceButton addGestureRecognizer:longPress];
    

}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *settings        = [NSUserDefaults standardUserDefaults];
    selectedCurrency = [settings valueForKey:@"SelectedCurrency"];
    currencyDisplay.text = selectedCurrency;
    currencyDisplay.hidden = YES;
    ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [descriptionTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark Camera button

- (IBAction)openCameraChooser {
    
    //This is check to see if the iPhone have a camera and if it works correctly
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:Localize(@"Error")
                                                              message:Localize(@"Device has no camera")
                                                             delegate:nil
                                                    cancelButtonTitle:Localize(@"OK")
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    else //display action sheet to selec camera or photo library
    {
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      initWithTitle:nil
                                      delegate:self
                                      cancelButtonTitle:@"Cancel"
                                      destructiveButtonTitle:nil
                                      otherButtonTitles:@"Camera", @"Photo library", nil];

        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        [actionSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    switch (buttonIndex) {
        case 0:
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [BWStatusBarOverlay dismissAnimated];
            [self presentViewController:picker animated:YES completion:NULL];
            break;
        case 1:
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [BWStatusBarOverlay dismissAnimated];
            [self presentViewController:picker animated:YES completion:NULL];
            break;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    sharedHeftService.transactionImage = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (IBAction)goToPage:(UIPageControl *)sender
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * sender.currentPage;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)gotoListOfRecords:(id)sender {
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * 0;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    

}
- (IBAction)showRefundButton:(id)sender {
    self.payButton.hidden = YES;
    if ([self.payRefundToggleLable.text isEqual:Localize(@"Refund")])
    {
        self.payRefundToggleLable.text = Localize(@"Pay");
        
        self.payButton.hidden = YES;
        self.refundButton.hidden = NO;
    }
    else
    {
        self.payRefundToggleLable.text = Localize(@"Refund");
        self.payButton.hidden = NO;
        self.refundButton.hidden = YES;
    }
    
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * 1;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    /*if(self.scrollView.contentOffset.x > 720.0){
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * 0;
        frame.origin.y = 0;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
    else if(self.scrollView.contentOffset.x < 0.0){
        CGRect frame = self.scrollView.frame;
        frame.origin.x = frame.size.width * 2;
        frame.origin.y = 0;
        [self.scrollView scrollRectToVisible:frame animated:YES];
    }
    else{*/
        int page =  floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        self.pageControl.currentPage = page;
    //}
}

- (void)loadWebViewController:(NSNotification *)notif
{
    NSLog(@"load web view");
    //[self dismissTransactionViewController];
    hpReceipt *itemObj = sharedHeftService.receipt;
    hpReceiptViewController *detailViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"receiptViewController"];
    detailViewController.localReceipt = itemObj;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)loadSignatureController:(NSNotification *)notif
{
    NSLog(@"load signature view");
    //[self dismissTransactionViewController];
    //hpReceiptViewController *detailViewController = [hpReceiptViewController alloc];
    Draw_SignatureViewController *signatureViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"signatureViewController"];
    signatureViewController.receipt = sharedHeftService.signatureReceipt;
    signatureViewController.amountwithCurrency = self.ammountDisplay.text;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:signatureViewController animated:YES];
}

- (void)clearAmount:(NSNotification *)notif
{
    self.descriptionTextField.text = @"";
    self.ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];
}

- (IBAction)showAbout:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.handpoint.com/about/"]];
}

-(NSString*)formatAmount:(NSString*)amount forCurrency:(NSString*)currency
{
    return [HpUtils formatAmount:amount forCurrency:currency];
}

//- (void)addFadeTransition{
//	CATransition* transition = [CATransition animation];
//	transition.type = kCATransitionFade;
//	[self.view.layer addAnimation:transition forKey:nil];
//}
//
//- (void)showViewController:(UIViewController*)viewController{
//	[self addFadeTransition];
//	[self.view addSubview:viewController.view];
//}
//
//- (void)dismissViewController:(UIViewController*)viewController{
//	[self addFadeTransition];
//	[viewController.view removeFromSuperview];
//}
//
//- (void)showTransactionViewController:(eTransactionType)type{
//	sharedHeftService.transactionViewController = [TransactionViewController transactionWithType:type storyboard:self.storyboard];
//	[self showViewController:sharedHeftService.transactionViewController];
//}
//
//- (void)dismissTransactionViewController{
//	[self dismissViewController:sharedHeftService.transactionViewController];
//	sharedHeftService.transactionViewController = nil;
//}

@end
