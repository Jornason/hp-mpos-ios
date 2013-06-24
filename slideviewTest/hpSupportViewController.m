//
//  SupportViewController.m
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

#import "hpSupportViewController.h"

@interface hpSupportViewController ()

@end

@implementation hpSupportViewController

//Push Buttom Hyperlink to help site, is handpoint.com as of now
-(IBAction)pushWebButton
{
    //The actual link to the page
    [[UIApplication sharedApplication]openURL: [NSURL URLWithString:[settings valueForKey:@"webpage"]]];
}
//Send eMail from Support ... Using
- (IBAction)ContactUS:(id)sender
{
    MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
    [mailController setMailComposeDelegate:self];
    NSString *email = [settings valueForKey:@"email"];
    NSArray *emailArray = [[NSArray alloc] initWithObjects:email, nil];
    [mailController setToRecipients:emailArray];
    [self presentViewController:mailController animated:YES completion:nil];
}

- (IBAction)callPhoneNumber:(id)sender
{
    NSMutableString *phone = [[sender currentTitle] mutableCopy];
    [phone replaceOccurrencesOfString:@" "
                           withString:@""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, [phone length])];
    [phone replaceOccurrencesOfString:@"-"
                           withString:@""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, [phone length])];
    [phone replaceOccurrencesOfString:@"("
                           withString:@""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, [phone length])];
    [phone replaceOccurrencesOfString:@")"
                           withString:@""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, [phone length])];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phone]];
    [[UIApplication sharedApplication] openURL:url];
}


-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


//Default code starts here

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
    
    //load config file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
    settings = [[NSDictionary alloc] initWithContentsOfFile:path];
    //Get string for webpage button and remove "http://"
    NSMutableString *webpage = [[settings valueForKey:@"webpage"] mutableCopy];
    [webpage replaceOccurrencesOfString:@"http://"
                           withString:@""
                              options:NSLiteralSearch
                                range:NSMakeRange(0, [webpage length])];
    //set label of phonenumber button
    [phoneButton setTitle:[settings valueForKey:@"phonenumber"]forState:UIControlStateNormal];
    //set label of webpage button
    [webpageButton setTitle:webpage forState:UIControlStateNormal];
    self.contactLabel.text = Localize(@"Contact Handpoint support");
    self.hotlineLabel.text = Localize(@"Hotline");
    self.visitLabel.text = Localize(@"visit our website");
    [self.emailButton setTitle:Localize(@"E-mail us") forState:UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.title = Localize(@"Support");
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
