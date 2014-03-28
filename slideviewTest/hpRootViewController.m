//
//  hpRootViewController.m
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

#import "hpRootViewController.h"
#import "hpTextField.h"
#import "KeychainWrapper.h"
#import "hpHeftService.h"

#define passcodeResetAlert ((NSInteger)1)

@implementation hpRootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

// Presents the appropriate view, create/enter passcodem, based on if there is a passcode stored in the keychain
- (void)presentViewForPasscode
{
    
    for (int i = FIRST_PASSCODE_TEXTFIELD; i <= LAST_VERIFY_PASSCODE_TEXTFIELD; i++) // Just to make sure the textFields always start out empty on reloads
    {
        UITextField * textField = (UITextField*)[self.view viewWithTag:i];
        [textField setText:@""];
    }
    
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    
    if (hasPin) // passcode stored in keychain
    {
        [self.createPasscode setHidden:YES];
        [self.enterPasscode setHidden:NO];
        [self.welcomeLabel setText:Localize(@"Nice to see you again.")];
        [self.signInButton setTitle:Localize(@"Sign in") forState:UIControlStateNormal];
    }
    else  // no passcode stored in keychain
    {
        [self.enterPasscode setHidden:YES];
        [self.createPasscode setHidden:NO];
        [self.welcomeLabel setText:Localize(@"Welcome.")];
        [self.signInButton setTitle:Localize(@"Create") forState:UIControlStateNormal];
        
    }
    
}

- (IBAction)signInButton:(id)sender
{
    BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    if(hasPin) 
    {
        [self signIn];
    }
    else
    {
        [self addNewPasscode];
    }
}

// creates a string from all the checkboxes and compares with the passcode stored in the keychain
- (void)signIn
{
    NSMutableString *passcode = [NSMutableString stringWithString:@""];
    for (int i = FIRST_PASSCODE_TEXTFIELD; i <= LAST_PASSCODE_TEXTFIELD; i++)
    {
        UITextField * textField = (UITextField*)[self.view viewWithTag:i];
        [passcode appendString:textField.text];
    }
    NSUInteger fieldHash = [passcode hash];
    if ([KeychainWrapper compareKeychainValueForMatchingPIN:fieldHash])
    {
        // procced to the main view
        [self performSegueWithIdentifier:@"hpTableSegue" sender:self];
    }
    else
    {
        // Display alertbox
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"Passcode incorrect!")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:Localize(@"Retry")
                                              otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        [self presentViewForPasscode];
        
    }
}

// creates strings from the checkboxes and compares them and adds to the keychain if the strings match
- (void)addNewPasscode
{
    NSMutableString *passcode = [NSMutableString stringWithString:@""];
    for (int i = FIRST_CREATE_PASSCODE_TEXTFIELD; i <= LAST_CREATE_PASSCODE_TEXTFIELD; i++)
    {
        UITextField * textField = (UITextField*)[self.view viewWithTag:i];
        [passcode appendString:textField.text];
    }
    
    NSMutableString *passcodeVerification = [NSMutableString stringWithString:@""];
    for (int i = FIRST_VERIFY_PASSCODE_TEXTFIELD; i <= LAST_VERIFY_PASSCODE_TEXTFIELD; i++)
    {
        UITextField * textField = (UITextField*)[self.view viewWithTag:i];
        [passcodeVerification appendString:textField.text];
    }
    
    if (![passcode isEqualToString:passcodeVerification])
    {
        // Display alert if strings do not match
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Localize(@"Passcodes do not match!")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:Localize(@"Ok")
                                              otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
        
    }
    else
    {
        // device identy for vendor is used for passcode encryption 
        NSUUID *deviceUDID = [[UIDevice currentDevice] identifierForVendor];
        NSString *deviceUDIDString = deviceUDID.UUIDString;
        [[NSUserDefaults standardUserDefaults] setValue:deviceUDIDString forKey:USERNAME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ([passcode length] > 0) {
            // Hashing and storing the passcode in the keychain
            NSUInteger fieldHash = [passcode hash];
            NSString *fieldString = [KeychainWrapper securedSHA256DigestHashForPIN:fieldHash];
            // Save PIN hash to the keychain
            if ([KeychainWrapper createKeychainValue:fieldString forIdentifier:PIN_SAVED]) {
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:PIN_SAVED];
                [[NSUserDefaults standardUserDefaults] synchronize];
                }
            }
    }
    [self presentViewForPasscode];
    
}

// Resets the stored passcode
- (IBAction)resetPasscodeGestureRecognizer:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset passcode?"
                                                    message:@"This will reset your passcode and delete ALL data on device!"
                                                   delegate:self
                                          cancelButtonTitle:Localize(@"Cancel")
                                          otherButtonTitles:Localize(@"Ok"),nil];
    [alert setAlertViewStyle:UIAlertViewStyleDefault];
    [alert setTag:passcodeResetAlert];
    [alert show];
}

- (void)resetPasscodeConfirmed
{
    [TestFlight passCheckpoint:RESET_PASSCODE];
    [KeychainWrapper deleteItemFromKeychainWithIdentifier:PIN_SAVED];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:PIN_SAVED];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:USERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"savedSharedSecret"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"defaultCardReaderSerialNumber"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    hpHeftService* sharedHeftService = [hpHeftService sharedHeftService];
    sharedHeftService.heftClient = nil;
    [self deleteAllFilesInDocumentsFolder];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clearListData"
                                                        object:nil];
    [self presentViewForPasscode];
}

- (void)deleteAllFilesInDocumentsFolder
{
    NSString *docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *localFileManager=[[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:docsDir];
    NSString *file;
    NSError *error;
    while ((file = [dirEnum nextObject]))
    {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@", docsDir,file];
        // process the document
        [localFileManager removeItemAtPath: fullPath error:&error ];
    }
    // Coopy the original plist settings file back to my documents folder
    hpAppDelegate *appDelegate = (hpAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate copyPlist];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentOffset:CGPointMake(0,textField.center.y-60) animated:YES];
    return YES;
}


// UITextField delegate function that detects all inputs in textfields, used to move focus to next textfield after each digit input
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL shouldProcess = NO; //default to reject
    BOOL shouldMoveToNextField = NO; //default to remaining on the current field
    BOOL shouldMoveToFormerField = NO; //default to remaining on the current field
    
    int insertStringLength = [string length];
    if(insertStringLength == 0){ //backspace
        shouldProcess = YES; //Process if the backspace character was pressed
    }
    else {
        if([[textField text] length] == 0) {
            shouldProcess = YES; //Process if there is only 1 character right now
        }
    }
    
    //here we deal with the UITextField on our own
    if(shouldProcess){

        //grab a mutable copy of what's currently in the UITextField
        
        textField.text = string;
        if(insertStringLength == 0){
            shouldMoveToFormerField = YES;
        }
        else{
            shouldMoveToFormerField = NO;
            shouldMoveToNextField = YES;
        }
        
    
        
        BOOL hasPin = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
        
        if (shouldMoveToNextField) {
            // identifying the last textField
            
            NSInteger textFieldCount = hasPin ? LAST_PASSCODE_TEXTFIELD : LAST_VERIFY_PASSCODE_TEXTFIELD;
            
            UITextField *nextField = (UITextField*)[self.view viewWithTag:(textField.tag+1)];
            if(textField.tag < textFieldCount)
            {
                //move focus to next textfield
                [nextField becomeFirstResponder];
            }
            else
            {
                //dismiss keyboard
                [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
                [textField resignFirstResponder];
                if(hasPin){
                    [self signIn];
                }
                else{
                    [self signInButton];
                }
                
            }
        }
        if (shouldMoveToFormerField) {
            // identifying the last textField
            NSInteger textFieldCount = hasPin ? FIRST_PASSCODE_TEXTFIELD : FIRST_CREATE_PASSCODE_TEXTFIELD;
            UITextField *nextField = (UITextField*)[self.view viewWithTag:(textField.tag-1)];
            if(textField.tag > textFieldCount)
            {
                //move focus to next textfieldanimated:YES];
                [nextField becomeFirstResponder];
                nextField.text = @"";
            }
            else
            {
                //dismiss keyboard
                [self.scrollView setContentOffset:CGPointMake(0,0) animated:YES];
                [textField resignFirstResponder];
            }
        }
    }
    
    //always return no since we are manually changing the text field
    return NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        if (alertView.tag == passcodeResetAlert)
        {
            if (buttonIndex == [alertView firstOtherButtonIndex])
            {
                [self resetPasscodeConfirmed];
            }
        }
    }
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    //setting the background image
    UIImage* background = [UIImage imageNamed: @"Background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];


    [self.signInButton setTitle:Localize(@"Sign in") forState:UIControlStateNormal];
    self.welcomeLabel.text          = Localize(@"Nice to see you again.");
    self.resetPasscode.text         = Localize(@"Reset passcode");
    self.hiLabel.text               = Localize(@"Hi");
    self.enterPasscodeLabel.text    = Localize(@"Enter passcode");
    self.createPasscodeLabel.text   = Localize(@"Create passcode");
    self.confirmPasscodeLabel.text  = Localize(@"Confirm passcode");
    self.createPinSloganLabel.text  = Localize(@"Create passcode and start accepting payments");

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceWasPressed:) name:@"backspacePressed" object:nil];

}


-(void)backspaceWasPressed:(NSNotification *)notification {
    UITextField *textField = [notification object];
    //Kludge
    if (textField.text.length == 1)
    {
        textField.text = @"";
    }
    else
    {
        textField.text = @"";
        NSRange range = {0,0};
        
        [self textField:textField shouldChangeCharactersInRange:range replacementString:@""];
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self presentViewForPasscode];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end