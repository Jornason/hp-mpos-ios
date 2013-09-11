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

#import "hpViewController.h"
#import "hpUtils.h"
#import "hpReceiptViewController.h"

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
- (IBAction)backspacePressed
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


- (IBAction) startSale
{

    //get current currency
    hpViewSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    selectedCurrency = [hpViewSettings valueForKey:@"SelectedCurrency"];
    
    int amount = [storedAmount intValue];
    NSLog(@"Amount: %d", amount);
    NSLog(@"Currency: %@", selectedCurrency);
    if(sharedHeftService.heftClient != nil)
    {
        if(amount != 0)
        {
            //Read the amount and send it to the SDK
            sharedHeftService.transactionDescription = [descriptionTextField text];
            [sharedHeftService saleWithAmount:amount currency:selectedCurrency cardholder:YES];
            self.userIsInTheMiddleOfEnteringANumber = NO;
            storedAmount = @"0";
            self.descriptionTextField.text = @"";
        }
    }
    else
    {
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
    hpViewSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    selectedCurrency = [hpViewSettings valueForKey:@"SelectedCurrency"];
    
    int amount = [storedAmount intValue];
    NSLog(@"Amount: %d", amount);
    NSLog(@"Currency: %@", selectedCurrency);
    if(sharedHeftService.heftClient != nil)
    {
        if(amount != 0)
        {
            //Read the amount and send it to the SDK
            sharedHeftService.transactionDescription = [descriptionTextField text];
            [sharedHeftService refundWithAmount:amount currency:selectedCurrency cardholder:YES];
            self.userIsInTheMiddleOfEnteringANumber = NO;
            storedAmount = @"0";
            self.descriptionTextField.text = @"";
        }
    }
    else
    {
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
    sharedHeftService =[hpHeftService sharedHeftService];
    [sharedHeftService checkIfAccessoryIsConnected];
    
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
    self.listOfRecordsLabel.text        = Localize(@"List of records");
    self.settingLabel.text              = Localize(@"Settings");
    self.logoutLabel.text               = Localize(@"Logout");
    self.socialLabel.text               = Localize(@"Social");
    self.userGuideLabel.text            = Localize(@"User guide");
    self.itemsLabel.text                = Localize(@"Items");
    self.listOfRecordsButtonLabel.text  = Localize(@"List of records");
    self.supportLabel.text              = Localize(@"Support");
    self.settingsButtonLabel.text       = Localize(@"Settings");
    self.discoverLabel.text             = Localize(@"Discover");
    self.descriptionTextField.placeholder = Localize(@"+ Description");



}

- (void)viewDidAppear:(BOOL)animated
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
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
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)loadWebViewController:(NSNotification *)notif
{
    NSLog(@"load web view");
    hpReceipt *itemObj = sharedHeftService.receipt;
    hpReceiptViewController *detailViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"receiptViewController"];
    detailViewController.localReceipt = itemObj;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)loadSignatureController:(NSNotification *)notif
{
    NSLog(@"load signature view");
    //hpReceiptViewController *detailViewController = [hpReceiptViewController alloc];
    Draw_SignatureViewController *signatureViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"signatureViewController"];
    signatureViewController.receipt = sharedHeftService.signatureReceipt;
    signatureViewController.amountwithCurrency = self.ammountDisplay.text;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:signatureViewController animated:YES];
}

- (void)clearAmount:(NSNotification *)notif
{
    self.ammountDisplay.text = [self formatAmount:storedAmount forCurrency:selectedCurrency];
}

-(NSString*)formatAmount:(NSString*)amount forCurrency:(NSString*)currency
{
    return [HpUtils formatAmount:amount forCurrency:currency];
}
@end
