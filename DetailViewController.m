//
//  DetailViewController.m
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

#import "DetailViewController.h"
//#import <CoreData/CoreData.h>

@interface DetailViewController ()

@end

@implementation DetailViewController

@synthesize item;

- (NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)])
    {
        context = [delegate managedObjectContext];
    }
    return context;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

//The Back Navigation
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
// Back Navigation ends

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if (self.item)
    {
        [self.itemnameTextField setText:[self.item valueForKey:@"itemname"]];
        [self.itempriceTextField setText:[self.item valueForKey:@"itemprice"]];
        [self.categoryTextField setText:[self.item valueForKey:@"category"]];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)save:(id)sender
{
    NSManagedObjectContext *context = [self managedObjectContext];
    
    if (self.item)
    {
        // Update existing device
        [self.item setValue:self.itemnameTextField.text forKey:@"itemname"];
        [self.item setValue:self.itempriceTextField.text forKey:@"itemprice"];
        [self.item setValue:self.categoryTextField.text forKey:@"category"];
        
    } else
    {
        // Create a new device
        NSManagedObject *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"Items" inManagedObjectContext:context];
        
        [newItem setValue:self.itemnameTextField.text forKey:@"itemname"];
        [newItem setValue:self.itempriceTextField.text forKey:@"itemprice"];
        [newItem setValue:self.categoryTextField.text forKey:@"category"];
    }
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error])
    {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
