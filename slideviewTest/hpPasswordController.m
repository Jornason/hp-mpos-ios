//
//  hpPasswordController.m
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

#import "hpPasswordController.h"
#import "hpTextField.h"
#import "PasswordConstants.h"
#import "hpColor.h"
@interface hpPasswordController ()

@end

@implementation hpPasswordController

@synthesize inputLabelPointer;

NSInteger const PIN_DIGITS = 4;
BOOL hasPIN = false;
NSMutableArray *inputArray;
NSString *pin;
BOOL deleting = false;
Status status = FIRST_CREATE;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //setting the background image
    UIImage* background = [UIImage imageNamed: @"Background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];

    hasPIN      = [[NSUserDefaults standardUserDefaults] boolForKey:PIN_SAVED];
    pin         = @"";
    status      = (hasPIN) ? LOGIN:FIRST_CREATE;
    inputArray  = [[NSMutableArray alloc] initWithCapacity:PIN_DIGITS];

    //HI
    UILabel *hiLabel        = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 34)];
    hiLabel.font            = [UIFont systemFontOfSize:(40.0)];
    hiLabel.text            = Localize(@"Hi");
    hiLabel.textAlignment   = NSTextAlignmentCenter;
    hiLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:hiLabel];

    //Nice to see you
    UILabel *welcomeLabel           = [[UILabel alloc] initWithFrame:CGRectMake(0, hiLabel.frame.origin.y + hiLabel.frame.size.height + 5, self.view.frame.size.width,21)];
    welcomeLabel.font               = [UIFont systemFontOfSize:(18.0)];
    welcomeLabel.text               = Localize(@"Nice to see you again.");
    welcomeLabel.textAlignment      = NSTextAlignmentCenter;
    welcomeLabel.backgroundColor    = [UIColor clearColor];
    [self.view addSubview:welcomeLabel];
    

    //Inputs
    NSInteger   WIDTH       = self.view.frame.size.width;
    NSInteger   REF_WIDTH   = 60;
    NSInteger   REF_HEIGHT  = 60;
    NSInteger   REF_OFFSET  = ((WIDTH - (PIN_DIGITS * REF_WIDTH))) / (PIN_DIGITS + 1);
    UIFont      *REF_FONT   = [UIFont systemFontOfSize:(46.0)];
    UIColor     *REF_BG     = [UIColor whiteColor];

    //Create a passcode // confirm a passcode // Enter a passcode
    UILabel *inputLabel         = [[UILabel alloc] initWithFrame:CGRectMake(REF_OFFSET, welcomeLabel.frame.origin.y + welcomeLabel.frame.size.height + 20, self.view.frame.size.width - REF_OFFSET,21)];
    inputLabel.font             = [UIFont systemFontOfSize:(16.0)];
    inputLabel.text             = (hasPIN) ? Localize(@"Create passcode") : Localize(@"Enter passcode");
    inputLabel.textAlignment    = NSTextAlignmentLeft;
    inputLabel.backgroundColor  = [UIColor clearColor];
    self.inputLabelPointer      = inputLabel;
    [self.view addSubview:inputLabel];

    for (NSInteger x = 0; x < PIN_DIGITS; x++) {

        int posX = ((x + 1) * REF_OFFSET) + (x * REF_WIDTH);
        int posY = inputLabel.frame.origin.y + inputLabel.frame.size.height + 20;
        
        hpTextField *inputField      = [[hpTextField alloc] initWithFrame:CGRectMake(posX, posY, REF_WIDTH, REF_HEIGHT)];
        inputField.font              = REF_FONT;
        inputField.textAlignment     = NSTextAlignmentCenter;
        inputField.backgroundColor   = REF_BG;
        inputField.borderStyle       = UITextBorderStyleBezel;
        inputField.secureTextEntry   = true;
        inputField.keyboardType      = UIKeyboardTypeNumberPad;
        inputField.delegate          = self;
        inputField.tag               = x;
        //textField.ba
        [self.view addSubview:inputField];
        
        [inputArray addObject:inputField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backspaceWasPressed:) name:@"backspacePressed" object:nil];
    }

    //Reset password
    UILabel *resetLabel           = [[UILabel alloc] initWithFrame:CGRectMake(REF_OFFSET, inputLabel.frame.origin.y + inputLabel.frame.size.height + REF_HEIGHT + 30, self.view.frame.size.width - REF_OFFSET,21)];
    resetLabel.font               = [UIFont systemFontOfSize:(18.0)];
    resetLabel.text               = Localize(@"Reset passcode");
    resetLabel.textAlignment      = NSTextAlignmentLeft;
    resetLabel.backgroundColor    = [UIColor clearColor];
    resetLabel.textColor          = [UIColor hpOrange];//colorWithRed:70.0 green: 113.0 blue:168.0 alpha:1.0];
    [self.view addSubview:resetLabel];


    
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if(pin.length < PIN_DIGITS)
    {
        //move focus to next textfield
        int pos = (deleting) ? (pin.length - 1): pin.length;
        if(pos < 0)
            pos = 0;
        UITextField *nextField = (UITextField*)inputArray[pos];
        if(nextField.tag != textField.tag){
            [nextField becomeFirstResponder];
        }
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if((string.length == 0) && (pin.length > 0)){
        deleting = true;
        if(pin.length > 1)
            pin = [pin substringToIndex:(pin.length - 1)];
        else
            pin = @"";
        textField.text = @"";
    }
    else if(pin.length < PIN_DIGITS){
        deleting = false;
        pin = [pin stringByAppendingString:string];
        textField.text = string;
    }


    if(pin.length < PIN_DIGITS)
    {
        //move focus to next textfield
        int pos = (deleting) ? (pin.length - 1): pin.length;
        if(pos < 0)
            pos = 0;
        UITextField *nextField = (UITextField*)inputArray[pos];
        [nextField becomeFirstResponder];
    }
    else
    {
        //dismiss keyboard
        [textField resignFirstResponder];
        if(status == LOGIN){
            [self performSegueWithIdentifier:@"navigationSegue" sender:self];
           
        }
    }
    return NO;
}

-(void)backspaceWasPressed:(NSNotification *)notification {
    
    UITextField *field = [notification object];
    if(pin.length > 0){
        NSRange range = {0,0};
        [self textField:field shouldChangeCharactersInRange:range replacementString:@""];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
