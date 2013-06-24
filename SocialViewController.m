//
//  SocialViewController.m
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

#import "SocialViewController.h"

@interface SocialViewController ()

@end

@implementation SocialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)postToFacebook:(id)sender
{
    SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    //Default text using for testing purposes, should be removed == @"mPOS Test from application to Facebook"
    [controller setInitialText:self.socialDescription.text];
    [controller addImage:self.imageView.image];
    [self presentViewController:controller animated:YES completion:nil];
    
}

//The back Navigation 
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    self.navigationItem.title = Localize(@"Social networks");
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.socialDescription resignFirstResponder];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.socialDescription resignFirstResponder];
}
- (IBAction)tweetButton:(id)sender
{
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:self.socialDescription.text];
        
        [tweetSheet addImage:self.imageView.image];
        
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:Localize(@"Error")
                                  message:Localize(@"please setup Twitter")
                                  delegate:self
                                  cancelButtonTitle:Localize(@"OK")
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (IBAction)chooseImage:(id)sender
{
    self.pickerController = [[UIImagePickerController alloc] init];
    
    self.pickerController.delegate = self;
    self.pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:self.pickerController animated:YES completion:NULL];
}

- (IBAction)takePhoto:(id)sender
{
    self.pickerController = [[UIImagePickerController alloc] init];
    self.pickerController.delegate = self;
    self.pickerController.allowsEditing = YES;
    self.pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:self.pickerController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
{
    self.imageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
