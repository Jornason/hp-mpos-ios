//
//  CalViewController.h
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

#import <UIKit/UIKit.h>

typedef enum {Plus,Minus,Multiply,Divide} CalcOperation;

@interface CalViewController : UIViewController

{
    IBOutlet UITextField *display;
    IBOutlet UIButton *cbutton;
    NSString *storage;
    CalcOperation operation;
}

- (IBAction) button1;
- (IBAction) button2;
- (IBAction) button3;
- (IBAction) button4;
- (IBAction) button5;
- (IBAction) button6;
- (IBAction) button7;
- (IBAction) button8;
- (IBAction) button9;
- (IBAction) button0;


- (IBAction)divButton:(id)sender;
- (IBAction)minusButton:(id)sender;
- (IBAction)multButton:(id)sender;
- (IBAction)plusButton:(id)sender;
- (IBAction)dotButton:(id)sender;

- (IBAction)clearDisplay:(id)sender;
- (IBAction)equalButton:(id)sender;











@end
