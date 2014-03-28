//
//  egDiscoverViewController.m
//  slideviewTest
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

#import "hpDiscoverViewController.h"

@interface hpDiscoverViewController ()

@end

@implementation hpDiscoverViewController
{

}
@synthesize deviceTable;


- (void)viewDidLoad
{
    [super viewDidLoad];
    [TestFlight passCheckpoint:CONNECTION_MENU];
    sharedHeftService = [hpHeftService sharedHeftService];
    [sharedHeftService resetDevices]; // Clean out device list
    sharedHeftService.automaticConnectToReader = NO;
    
    UIImage* background = [UIImage imageNamed: @"Background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];

    // Recieve notification from hpHeftService when new devices found
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(refreshDeviceTableView:)
                                                 name:@"refreshDevicesTableView"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(readerConnected:)
                                                 name:@"readerConnected"
                                               object:nil];

    super.navigationItem.title = Localize(@"Devices");
    super.navigationItem.backBarButtonItem.title = Localize(@"Back");
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:Localize(@"Discover")
                                                                   style:UIBarButtonItemStyleBordered
                                                                  target:self
                                                                  action:@selector(discoveryButton:)];
    super.navigationItem.rightBarButtonItem = addButton;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    sharedHeftService.automaticConnectToReader = YES;
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSLog(@"numberOfSectionsInTableView:");
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	NSLog(@"numberOfRowsInSection:");
    return [[sharedHeftService devicesCopy] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"discoverCell";
	
	// Try to retrieve from the table view a now-unused cell with the given identifier.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	
	// If no cell is available, create a new one using the given identifier.
	if (cell == nil) {
		// Use the default cell style.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier];
	}
	
	// Set up the cell.
	cell.textLabel.text = [[[sharedHeftService devicesCopy] objectAtIndex:indexPath.row] name];
    if([[[sharedHeftService devicesCopy] objectAtIndex:indexPath.row] isEqual:[sharedHeftService selectedDevice]])
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

    [TestFlight passCheckpoint:SELECT_CARDREADER];
    sharedHeftService.newDefaultCardReader = YES;
    sharedHeftService.heftClient = nil;
    [sharedHeftService checkForDefaultCardReaderWithIndex:indexPath.row];
    //[sharedHeftService clientForDevice:[[sharedHeftService devicesCopy] objectAtIndex:indexPath.row] sharedSecret:[sharedHeftService readSharedSecretFromFile] delegate:sharedHeftService];
}

- (void)refreshDeviceTableView:(NSNotification *)notif
{
    [deviceTable reloadData];
}
- (void)readerConnected:(NSNotification *)notif
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)discoveryButton:(id)sender {
    
    [sharedHeftService startDiscovery:NO];
    
}


@end
