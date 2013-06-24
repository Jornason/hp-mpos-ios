//
//  hpSelectCurrencyViewController.m
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

#import "hpSelectCurrencyViewController.h"

@interface hpSelectCurrencyViewController ()

@end

@implementation hpSelectCurrencyViewController

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
	// Do any additional setup after loading the view.    
    //load config file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
    settings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    currency = [settings valueForKey:@"Currencies"];
    currencySelected = [settings valueForKey:@"SelectedCurrency"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
    return [currency count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"currencyCell";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:MyIdentifier];
	}
	
	// Set up the cell.
    NSDictionary *dict = [currency copy];
    NSArray *keys = [dict allKeys];
    NSString *currencyShort = [dict objectForKey:[keys objectAtIndex:indexPath.row]];
    cell.textLabel.text = [keys objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = currencyShort;
    if ([currencyShort isEqualToString:currencySelected])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
    }
	else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [currency copy];
    NSArray *keys = [dict allKeys];
    NSString *currencyShort = [dict objectForKey:[keys objectAtIndex:indexPath.row]];
    currencySelected = currencyShort;
    [settings setObject:currencyShort forKey:@"SelectedCurrency"];
    [settings writeToFile:path atomically:YES];
    [tableView reloadData];
}

@end
