//
//  Draw SignatureViewController.h
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
#import "hpHeftService.h"

@interface Draw_SignatureViewController : UIViewController
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    BOOL mouseSwiped;
    hpHeftService* sharedHeftService;
}

@property(weak, nonatomic) IBOutlet UIImageView *mainImage;
@property(weak, nonatomic) IBOutlet UIImageView *tempDrawImage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) NSString* receipt;


- (IBAction)reset:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)decline:(id)sender;
- (IBAction)accept:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *signatureView;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIButton *declineButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) NSString* amountwithCurrency;

@end
