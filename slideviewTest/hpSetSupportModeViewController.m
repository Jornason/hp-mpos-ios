//
//  hpSetSupportModeViewController.m
//  mPOS
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

#import "hpSetSupportModeViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface hpSetSupportModeViewController ()

@end

@implementation hpSetSupportModeViewController
@synthesize switchSupportMode;

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
	// Do any additional setup after loading the view.
    
    // If there is no connection with the client we want to disable support mode
    if(sharedHeftService.heftClient == nil) {
        switchSupportMode.enabled = NO;
        UILabel *label =  [[UILabel alloc] initWithFrame:CGRectMake(40, 55, 240, 15)];
        [label setBackgroundColor:[UIColor clearColor]];
        [label setFont:[UIFont systemFontOfSize:12]];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:Localize(@"Connect to reader to enable support mode.")];
        [text addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, text.length)];
        [label setAttributedText: text];
        [self.view addSubview:label];
    } else {
        // Get the current state of support mode
        switchSupportMode.on = [sharedHeftService supportModeOn];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendSupportEmail:)
                                                 name:@"logsDidDownload"
                                               object:nil];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

// Pre: mPED logging is either on or off depending on switch state
// Post: Switch state changed and mPED logging as well!!!
- (IBAction)switchSupportModePressed:(id)sender {
    if (switchSupportMode.isOn) {
        NSLog(@"SUPPORT MODE ON");
        sharedHeftService.supportModeOn = YES;
        [sharedHeftService logSetLevel:eLogDebug];
    }
    else {
        NSLog(@"SUPPORT MODE OFF");
        sharedHeftService.supportModeOn = NO;
        [sharedHeftService logSetLevel:eLogNone];
    }
}

- (IBAction)sendEmailBtnPressed:(id)sender {
    //Check if email account has been setup in apple mail
    if ([MFMailComposeViewController canSendMail]) {
        NSLog(@"SENDING EMAIL");
        if ([sharedHeftService logGetInfo])
        {
            fetchingLogsAlert = [[UIAlertView alloc]initWithTitle:Localize(@"Fetching log from card reader.") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
            UIActivityIndicatorView *fetchingLogsActive = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 70, 30, 30)];
            [fetchingLogsActive setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [fetchingLogsActive startAnimating];
            [fetchingLogsAlert addSubview:fetchingLogsActive];
            [fetchingLogsAlert show];
            // TODO Set timeout
        }
        else
        {
            fetchingLogsAlert = [[UIAlertView alloc]initWithTitle:Localize(@"No log available!") message:Localize(@"Please check instructions.") delegate:nil cancelButtonTitle:Localize(@"Ok") otherButtonTitles: nil];
            [fetchingLogsAlert show];
        }
    }
    else
    {
        fetchingLogsAlert = [[UIAlertView alloc]initWithTitle:Localize(@"No E-mail account found!") message:Localize(@"Please check iOS E-mail settings.") delegate:nil cancelButtonTitle:Localize(@"Ok") otherButtonTitles: nil];
        [fetchingLogsAlert show];
    }
    
}

- (void) sendSupportEmail:(NSNotification*)notification {
    NSLog(@"opening email app");
    
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path]; //load hpConfig.plist
    [fetchingLogsAlert dismissWithClickedButtonIndex:0 animated:YES];
    // Fetch the log file
    NSString *documentdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *logFileLocation = [documentdir stringByAppendingPathComponent:@"log.txt"];
    NSData *logFile = [NSData dataWithContentsOfFile:logFileLocation];
    // Open mail app and attach file
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
    [mailController setMailComposeDelegate:self];
    NSString *email = [settings objectForKey:@"email"]; //set support email from config file
    NSArray *emailArray = [[NSArray alloc] initWithObjects:email, nil];
    [mailController setToRecipients:emailArray];
    [mailController setSubject:@"Logs from mPOS"];
    [mailController setMessageBody:@"Hi, I was having problems with my iOS mPos app. Attached are the logs from the card reader." isHTML:YES];
    [mailController addAttachmentData:logFile mimeType:@"text/plain" fileName:@"log.txt"];
    [self presentViewController:mailController animated:YES completion:nil];
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
