//
//  Draw SignatureViewController.m
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

#import "Draw SignatureViewController.h"

@interface Draw_SignatureViewController ()

@end

@implementation Draw_SignatureViewController

@synthesize mainImage, tempDrawImage, webView, receipt;


- (void)viewDidLoad
{
    red = 0.0/255.0;
    green = 0.0/255.0;
    blue = 0.0/255.0;
    brush = 3.0;
    opacity = 1.0;
    
    [super viewDidLoad];
    sharedHeftService = [hpHeftService sharedHeftService];
    /*[self.clearButton setTintColor:[UIColor yellowColor]];
    [self.declineButton setTintColor:[UIColor redColor]];
    [self.acceptButton setTintColor:[UIColor greenColor]];*/
    NSInteger REF_WIDTH = self.view.frame.size.height;

    NSArray *sourceImages = [[NSArray alloc]initWithObjects:[UIImage imageNamed: @"visa.png"],[UIImage imageNamed: @"mastercard.png"], nil];

    for(UIImage *t in sourceImages){
        REF_WIDTH -= t.size.width;
        UIImageView *cardLogoView   = [[UIImageView alloc] initWithFrame:CGRectMake((REF_WIDTH), 4, t.size.width, t.size.height)];
        cardLogoView.image          = t;
        [self.tempDrawImage addSubview:cardLogoView];
    }
    NSUserDefaults *settings        = [NSUserDefaults standardUserDefaults];
    UILabel *merchLabel             = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, REF_WIDTH, 40.0) ];
    merchLabel.textColor            = [UIColor blackColor];
    merchLabel.backgroundColor      = [UIColor whiteColor];
    merchLabel.font                 = [UIFont fontWithName:@"Avenir" size:(36.0)];
    NSString *merchantName          = [settings objectForKey:@"merchantName"];
    //merchLabel.numberOfLines        = 2;
    merchLabel.text                 = merchantName;
    NSLog(@"%@", merchLabel.text);
    [self.view addSubview:merchLabel];
    
    UILabel *amountLable            = [[UILabel alloc] initWithFrame:CGRectMake(10, 44, REF_WIDTH, 40.0) ];
    amountLable.textColor           = [UIColor blackColor];
    amountLable.backgroundColor     = [UIColor whiteColor];
    amountLable.font                = [UIFont fontWithName:@"Avenir" size:(36.0)];
    //amountLable.numberOfLines       = 2;
    amountLable.text                = self.amountwithCurrency;
    NSLog(@"%@", amountLable.text);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(cancelSignature:)
                                                 name:@"cancelSignature"
                                               object:nil];
    //sharedHeftService.receipt.customerReceipt;
    
    [self.view addSubview:amountLable];
    
	// Do any additional setup after loading the view.
}
- (void)viewDidUnload
{
    [self setMainImage:nil];
    [self setTempDrawImage:nil];
    [super viewDidUnload];
    //[sharedHeftService.heftClient ]   //acceptSignature:YES];
    
    // Release any retained subviews of the main view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)shouldAutorotate
{
    return YES;
}

-(NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewWillAppear:(BOOL)animated
{
    CGAffineTransform newTransform = CGAffineTransformMake(0.0,1.0,-1.0,0.0,0.0,0.0);
    self.view.transform = newTransform;
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (IBAction)reset:(id)sender
{
    self.mainImage.image = nil; //Clears all the strokes in the image
    self.tempDrawImage.image = nil; //Clears all the strokes in the image
}

- (void)cancelSignature:(NSNotification *)notif
{
    //[sharedHeftService.heftClient acceptSignature:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)decline:(id)sender
{
    [sharedHeftService acceptSignature:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)accept:(id)sender
{
    [sharedHeftService acceptSignature:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

//Drawing functions
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //This is the spot where the pencil hits the drawing surface
    mouseSwiped = NO;
    UITouch *touch = [touches anyObject];
    lastPoint = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    mouseSwiped = YES;
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:self.tempDrawImage];
    
    UIGraphicsBeginImageContext(self.tempDrawImage.frame.size);
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
    CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
    CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush ); //The brush tool we are using 
    CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0); // The size of the brush, color and opacity
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
    
    CGContextStrokePath(UIGraphicsGetCurrentContext()); // The path we are drawing 
    self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
    [self.tempDrawImage setAlpha:opacity];
    UIGraphicsEndImageContext();
    
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //This is where the merge of the two pictures takes place, where the temp merges with the MainImage 
    if(!mouseSwiped)
    {
        UIGraphicsBeginImageContext(self.view.frame.size);
        [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height)];
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        CGContextFlush(UIGraphicsGetCurrentContext());
        self.tempDrawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    UIGraphicsBeginImageContext(self.mainImage.frame.size);
    [self.mainImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    [self.tempDrawImage.image drawInRect:CGRectMake(0, 0, self.tempDrawImage.frame.size.width, self.tempDrawImage.frame.size.height) blendMode:kCGBlendModeNormal alpha:opacity];
    self.mainImage.image = UIGraphicsGetImageFromCurrentImageContext();
    self.tempDrawImage.image = nil;
    UIGraphicsEndImageContext();
}



@end
