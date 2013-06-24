//
//  CalViewController.m
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

#import "CalViewController.h"

@interface CalViewController ()

@end

@implementation CalViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

- (IBAction) button0
{
    display.text=[NSString stringWithFormat:@"%@0",display.text];
}
- (IBAction) button1
{
    display.text=[NSString stringWithFormat:@"%@1",display.text];
}
- (IBAction) button2
{
    display.text=[NSString stringWithFormat:@"%@2",display.text];
}
- (IBAction) button3
{
    display.text=[NSString stringWithFormat:@"%@3",display.text];
}

- (IBAction) button4
{
    display.text=[NSString stringWithFormat:@"%@4",display.text];
}

- (IBAction) button5
{
    display.text=[NSString stringWithFormat:@"%@5",display.text];
}

- (IBAction) button6
{
    display.text=[NSString stringWithFormat:@"%@6",display.text];
}

- (IBAction) button7
{
    display.text=[NSString stringWithFormat:@"%@7",display.text];
}

- (IBAction) button8
{
    display.text=[NSString stringWithFormat:@"%@8",display.text];
}

- (IBAction) button9
{
    display.text=[NSString stringWithFormat:@"%@9",display.text];
}


- (IBAction)divButton:(id)sender
{
    operation = Divide;
    storage = display.text;
    display.text=@"";
}

- (IBAction)minusButton:(id)sender
{
    operation = Minus;
    storage = display.text;
    display.text=@"";
}

- (IBAction)multButton:(id)sender
{
    operation = Multiply;
    storage = display.text;
    display.text=@"";
}

- (IBAction)plusButton:(id)sender
{
    operation = Plus;
    storage = display.text;
    display.text=@"";
}

- (IBAction)dotButton:(id)sender
{
    display.text=[NSString stringWithFormat:@"%@.",display.text];
}

- (IBAction)clearDisplay:(id)sender
{
     display.text = @"";
}

- (IBAction)equalButton:(id)sender
{
    NSString *val = display.text;
    switch(operation)
    {
        case Plus :
            display.text= [NSString stringWithFormat:@"%1.2f",[val floatValue]+[storage floatValue]];
            break;
        case Minus:
            display.text= [NSString stringWithFormat:@"%1.2f",[val floatValue]-[storage floatValue]];
            break;
        case Divide:
            display.text= [NSString stringWithFormat:@"%1.2f",[val floatValue]/[storage floatValue]];
            break;
        case Multiply:
            display.text= [NSString stringWithFormat:@"%1.2f",[val floatValue]*[storage floatValue]];
            break;
    }
}


@end
