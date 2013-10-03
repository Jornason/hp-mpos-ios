//
//  hpInAppSettingsViewViewController.m
//  mPOS
//
//  Created by Juan Nuñez on 9/24/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "hpInAppSettingsViewController.h"
#import "IASKSettingsReader.h"
#import <MessageUI/MessageUI.h>
#import "CustomViewCell.h"
#import "hpSharedAppSettings.h"

@interface hpInAppSettingsViewController ()<UIPopoverControllerDelegate>
- (void)settingDidChange:(NSNotification*)notification;

@property (nonatomic) UIPopoverController* currentPopoverController;

@end


@implementation hpInAppSettingsViewController
@synthesize appSettingsViewController, tabAppSettingsViewController, fetchingLogsAlert;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
    settings = [[NSDictionary alloc] initWithContentsOfFile:path];
        
    self.appSettingsViewController.showCreditsFooter = NO;
    self.appSettingsViewController.showDoneButton = NO;
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.appSettingsViewController.navigationController.navigationBarHidden = NO;
    self.navigationController.title = Localize(@"Settings");
	//[self.navigationController pushViewController:self.appSettingsViewController animated:YES];

   
    //self.cont = [[IASKAppSettingsViewController alloc] init];
    //self.cont.showDoneButton = NO;
    //self.cont.navigationController.navigationBarHidden = NO;
    
    [self addChildViewController:self.appSettingsViewController];
    CGRect rect = self.view.frame;
    rect.origin.y -= 20.0; //For some reason this amount of gap has to be reduced
    self.appSettingsViewController.view.frame = rect;
    [self.view addSubview:self.appSettingsViewController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sendSupportEmail:)
                                                 name:@"logsDidDownload"
                                               object:nil];
   
}

-(void) willMoveToParentViewController:(UIViewController *)parent{
    if(self.navigationController.isNavigationBarHidden == NO)
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


/*
 *
 *
 *
 *
 *
 *
 *
 *****************************/

- (IASKAppSettingsViewController*)appSettingsViewController {
	if (!appSettingsViewController) {
		appSettingsViewController = [[IASKAppSettingsViewController alloc] init];
		appSettingsViewController.delegate = self;
	}
	return appSettingsViewController;
}


- (void)showSettingsPopover:(id)sender {
	if(self.currentPopoverController) {
        [self dismissCurrentPopover];
		return;
	}
    
	self.appSettingsViewController.showDoneButton = NO;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.appSettingsViewController];
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:navController];
	popover.delegate = self;
	[popover presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:NO];
	self.currentPopoverController = popover;
}

- (void)awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(settingDidChange:) name:kIASKAppSettingChanged object:nil];
	BOOL enabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"AutoConnect"];
	self.tabAppSettingsViewController.hiddenKeys = enabled ? nil : [NSSet setWithObjects:@"AutoConnectLogin", @"AutoConnectPassword", nil];
    
	if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showSettingsPopover:)];
	}
}

#pragma mark - View Lifecycle
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	if(self.currentPopoverController) {
		[self dismissCurrentPopover];
	}
}

- (void) dismissCurrentPopover {
	[self.currentPopoverController dismissPopoverAnimated:YES];
	self.currentPopoverController = nil;
}

- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
    [self dismissModalViewControllerAnimated:YES];
	
	// your code here to reconfigure the app for changed settings
}

- (CGFloat)settingsViewController:(id<IASKViewController>)settingsViewController
                        tableView:(UITableView *)tableView
        heightForHeaderForSection:(NSInteger)section {
    NSString* key = [settingsViewController.settingsReader keyForSection:section];
	if ([key isEqualToString:@"IASKLogo"]) {
		return [UIImage imageNamed:@"handpoint logo.png"].size.height + 25;
	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
		return 55.f;
    }
	return 0;
}

- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewController
                         tableView:(UITableView *)tableView
           viewForHeaderForSection:(NSInteger)section {
    NSString* key = [settingsViewController.settingsReader keyForSection:section];
	if ([key isEqualToString:@"IASKLogo"]) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"handpoint logo.png"]];
		imageView.contentMode = UIViewContentModeCenter;
		return imageView;
	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor redColor];
        label.shadowColor = [UIColor whiteColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.numberOfLines = 0;
        label.font = [UIFont boldSystemFontOfSize:16.f];
        
        //figure out the title from settingsbundle
        label.text = [settingsViewController.settingsReader titleForSection:section];
        
        return label;
    }
	return nil;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForSpecifier:(IASKSpecifier*)specifier {
	CustomViewCell *cell = (CustomViewCell*)[tableView dequeueReusableCellWithIdentifier:specifier.key];
	
	if (!cell) {
		cell = (CustomViewCell*)[[[NSBundle mainBundle] loadNibNamed:@"CustomViewCell"
															   owner:self
															 options:nil] objectAtIndex:0];
	}
	cell.textView.text= [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] != nil ?
    [[NSUserDefaults standardUserDefaults] objectForKey:specifier.key] : [specifier defaultStringValue];
	cell.textView.delegate = self;
	[cell setNeedsLayout];
	return cell;
}


- (CGFloat)tableView:(UITableView*)tableView heightForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"customCell"]) {
		return 44*3;
	}
	return 0;
}

#pragma mark - UIPopoverControllerDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
	self.currentPopoverController = nil;
}
#pragma mark -
- (void)settingsViewController:(IASKAppSettingsViewController*)sender buttonTappedForSpecifier:(IASKSpecifier*)specifier {
	if ([specifier.key isEqualToString:@"ACTION_MAIL_SUPPORT"]) {
        MFMailComposeViewController *mailController = [[MFMailComposeViewController alloc]init];
        [mailController setMailComposeDelegate:self];
        NSString *email = [settings valueForKey:@"email"];
        NSArray *emailArray = [[NSArray alloc] initWithObjects:email, nil];
        [mailController setToRecipients:emailArray];
        [self presentViewController:mailController animated:YES completion:nil];
	}
    else if ([specifier.key isEqualToString:@"ACTION_CALL_SUPPORT"]) {
        NSMutableString *phone = [[NSMutableString alloc] initWithString:[settings valueForKey:@"phonenumber"]];
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
    else if ([specifier.key isEqualToString:@"ACTION_UPDATE_CARD_READER"]) {
        if(sharedHeftService.heftClient != nil)
        {
            NSLog(@"Checking for card reader software update");
            [sharedHeftService financeInit];
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
    else if ([specifier.key isEqualToString:@"ACTION_SEND_LOGS"]) {
        //Check if email account has been setup in apple mail
        if ([MFMailComposeViewController canSendMail]) {
            NSLog(@"SENDING EMAIL");
            if ([sharedHeftService logGetInfo])
            {
                [sharedHeftService.transactionViewController setStatusMessage:Localize(@"Fetching log from card reader.") andStatusCode:0];
                //fetchingLogsAlert = [[UIAlertView alloc]initWithTitle:Localize(@"Fetching log from card reader.") message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
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
                [sharedHeftService dismissTransactionViewController];
                [fetchingLogsAlert show];
            }
        }
        else
        {
            fetchingLogsAlert = [[UIAlertView alloc]initWithTitle:Localize(@"No E-mail account found!") message:Localize(@"Please check iOS E-mail settings.") delegate:nil cancelButtonTitle:Localize(@"Ok") otherButtonTitles: nil];
            [fetchingLogsAlert show];
        }
        
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
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


#pragma mark UITextViewDelegate (for CustomViewCell)
- (void)textViewDidChange:(UITextView *)textView {
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"customCell"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kIASKAppSettingChanged object:@"customCell"];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
	self.appSettingsViewController = nil;
}

/* Delegate shit 'n stuff */
#pragma mark -
#pragma mark IASKAppSettingsViewControllerDelegate protocol


// optional delegate method for handling mail sending result
- (void)settingsViewController:(id<IASKViewController>)settingsViewController mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    if ( error != nil ) {
        // handle error here
    }
    
    if ( result == MFMailComposeResultSent ) {
        // your code here to handle this result
    }
    else if ( result == MFMailComposeResultCancelled ) {
        // ...
    }
    else if ( result == MFMailComposeResultSaved ) {
        // ...
    }
    else if ( result == MFMailComposeResultFailed ) {
        // ...
    }
}



#pragma mark kIASKAppSettingChanged notification
- (void)settingDidChange:(NSNotification*)notification {
    
	if([notification.object isEqual:@"EnableSupport"]){
        BOOL enabled = (BOOL)[[notification.userInfo objectForKey:notification.object] intValue];
        if (enabled) {
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
    else if([notification.object isEqual:@"id_currency"]){
        [[hpSharedAppSettings sharedManager] setPropertyWithKey:@"SelectedCurrency" withValue:(NSString*)[notification.userInfo objectForKey:notification.object]];
    }
    else if([notification.object isEqual:@"id_merchant_address"]){        [[hpSharedAppSettings sharedManager] setPropertyWithKey:@"merchantAddress" withValue:(NSString*)[notification.userInfo objectForKey:notification.object]];
    }
    else if([notification.object isEqual:@"id_merchant_name"]){        [[hpSharedAppSettings sharedManager] setPropertyWithKey:@"merchantName" withValue:(NSString*)[notification.userInfo objectForKey:notification.object]];
    }
}


@end
