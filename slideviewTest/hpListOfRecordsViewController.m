//
//  hpListOfRecordsViewController.m
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

#import "hpListOfRecordsViewController.h"

@interface hpListOfRecordsViewController ()

@end

@implementation hpListOfRecordsViewController
@synthesize listOfRecordsTable, currencySymbol, logo;


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    hpHeftService* sharedHeftService = [hpHeftService sharedHeftService];
    receiptDelegate = sharedHeftService.receiptDelegate;
    
    currencySymbol = @{@"826":@"₤", @"840":@"$", @"978":@"€"};
    
    self.title = Localize(@"List of records");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadListData:)
                                                 name:@"reloadListData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearListData:)
                                                 name:@"clearListData"
                                               object:nil];
    
    logo = [UIImage imageNamed: @"card.png"];
    
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(void)reloadListData:(NSNotification *)notif
{
    [listOfRecordsTable reloadData];
}
-(void)clearListData:(NSNotification *)notif
{
    [receiptDelegate.itemArray removeAllObjects];
    [self reloadListData:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Number of records: %d", [receiptDelegate.itemArray count]);
    return [receiptDelegate.itemArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"listOfRecordsCell";
    hpListOfRecordsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    hpReceipt *itemObj = [receiptDelegate.itemArray objectAtIndex:indexPath.row];
    [itemObj hydrateDetailViewData];
    if(itemObj.image != NULL)
    {
        cell.listImage.image = itemObj.image;
    }
    else
    {
         cell.listImage.image = logo;   
    }
    cell.tranactionType.text = [Localize([itemObj.xml objectForKey:@"TransactionType"])capitalizedString];
    cell.transactionDateTime.text = [itemObj dateFromTimestamp];
    cell.transactionAmount.text = [itemObj ammountWithCurrencySymbol];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.

    hpReceipt *itemObj = [receiptDelegate.itemArray objectAtIndex:indexPath.row];
    hpReceiptViewController *detailViewController =[self.storyboard instantiateViewControllerWithIdentifier:@"receiptViewController"];
    detailViewController.localReceipt = itemObj;
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];

}

@end
