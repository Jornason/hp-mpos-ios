//
//  hpReciept.m
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

#import "hpReceipt.h"
#import "HpUtils.h"

static sqlite3 *database = nil;
static sqlite3_stmt *deleteStmt = nil;
static sqlite3_stmt *addStmt = nil;
static sqlite3_stmt *detailStmt = nil;
static sqlite3_stmt *updateStmt = nil;

@implementation hpReceipt
@synthesize receiptID, xml, authorisedAmount, transactionId, customerReceipt, merchantReceipt, description, image, isDirty, isDetailViewHydrated, customerIsCopy, merchantIsCopy;

- (id)init
{
    self = [super init];
    if (self) {
        xml = [NSDictionary alloc];
        authorisedAmount = 0;
        transactionId = 0;
        customerReceipt = @"";
        merchantReceipt = @"";
        description = @"";
        image = [UIImage alloc];
        
    }
    return self;
}

+ (void) getInitialDataToDisplay:(NSString *)dbPath delegate:(id)delegate {
    
    NSLog(@"getInitialDataToDisplay");
	
    hpReceiptDelegate *appDelegate = delegate;
    
	if (sqlite3_open([dbPath UTF8String], &database) == SQLITE_OK) {
		
		const char *sql = "select receiptID, transactionId, description, authorisedAmount from Receipt";
		sqlite3_stmt *selectstmt;
		if(sqlite3_prepare_v2(database, sql, -1, &selectstmt, NULL) == SQLITE_OK) {
			
			while(sqlite3_step(selectstmt) == SQLITE_ROW) {
				
				NSInteger primaryKey = sqlite3_column_int(selectstmt, 0);
				hpReceipt *itemObj = [[hpReceipt alloc] initWithPrimaryKey:primaryKey];
                itemObj.transactionId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 1)];
				itemObj.description = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectstmt, 2)];
                
                //Get the price in a temporary variable.
                NSInteger authorisedAmountTemp = sqlite3_column_int(selectstmt, 3);
                
                //Assign the price. The price value will be copied, since the property is declared with "copy" attribute.
                itemObj.authorisedAmount = authorisedAmountTemp;
				
				itemObj.isDirty = NO;
				
				[appDelegate.itemArray addObject:itemObj];
			}
		}
	}
	else
		sqlite3_close(database); //Even though the open call failed, close the database connection to release all the memory.
}

+ (void) finalizeStatements {
	
	if (database) sqlite3_close(database);
	if (deleteStmt) sqlite3_finalize(deleteStmt);
	if (addStmt) sqlite3_finalize(addStmt);
	if (detailStmt) sqlite3_finalize(detailStmt);
	if (updateStmt) sqlite3_finalize(updateStmt);
}

- (id) initWithPrimaryKey:(NSInteger) pk {
	
	//[super init];
	receiptID = pk;
	
	image = [[UIImage alloc] init];
	isDetailViewHydrated = NO;
	
	return self;
}

- (void) deleteItem {
	
	if(deleteStmt == nil) {
		const char *sql = "delete from Item where transactionId = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &deleteStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
	}
	
	//When binding parameters, index starts from 1 and not zero.
	sqlite3_bind_int(deleteStmt, 1, receiptID);
	
	if (SQLITE_DONE != sqlite3_step(deleteStmt))
		NSAssert1(0, @"Error while deleting. '%s'", sqlite3_errmsg(database));
	
	sqlite3_reset(deleteStmt);
}

- (void) addItem {
    
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:xml
                                                             format:NSPropertyListXMLFormat_v1_0
                                                   errorDescription:nil];
    NSData *imageData = nil;
    if (image != nil)
    {
        imageData = UIImagePNGRepresentation(image);
    }
    
	if(addStmt == nil) {
		const char *sql = "insert into Receipt(transactionId, authorisedAmount, description, customerReceipt, customerIsCopy, merchantReceipt, merchantIsCopy, xml, image) Values(?, ?, ?, ?, ?, ?, ?, ?, ?)";
		if(sqlite3_prepare_v2(database, sql, -1, &addStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating add statement. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_text(addStmt, 1, [transactionId UTF8String], -1, SQLITE_TRANSIENT);
	sqlite3_bind_int(addStmt, 2, authorisedAmount);
    sqlite3_bind_text(addStmt, 3, [description UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(addStmt, 4, [customerReceipt UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(addStmt, 5, customerIsCopy);
    sqlite3_bind_text(addStmt, 6, [merchantReceipt UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_int(addStmt, 7, merchantIsCopy);
    sqlite3_bind_blob(addStmt, 8, [data bytes], [data length], SQLITE_TRANSIENT);
    sqlite3_bind_blob(addStmt, 9, [imageData bytes], [imageData length], SQLITE_TRANSIENT);
    
	
	if(SQLITE_DONE != sqlite3_step(addStmt))
		NSAssert1(0, @"Error while inserting data. '%s'", sqlite3_errmsg(database));
	else
		//SQLite provides a method to get the last primary key inserted by using sqlite3_last_insert_rowid
		receiptID = sqlite3_last_insert_rowid(database);
	
	//Reset the add statement.
	sqlite3_reset(addStmt);
}

- (void) hydrateDetailViewData {
	
	//If the detail view is hydrated then do not get it from the database.
	if(isDetailViewHydrated) return;
	
	if(detailStmt == nil) {
		const char *sql = "Select image, transactionId, customerReceipt, customerIsCopy, merchantReceipt, merchantIsCopy, xml from Receipt Where receiptID = ?";
		if(sqlite3_prepare_v2(database, sql, -1, &detailStmt, NULL) != SQLITE_OK)
			NSAssert1(0, @"Error while creating detail view statement. '%s'", sqlite3_errmsg(database));
	}
	
	sqlite3_bind_int(detailStmt, 1, receiptID);
	
	if(SQLITE_DONE != sqlite3_step(detailStmt)) {
		
		NSData *data = [[NSData alloc] initWithBytes:sqlite3_column_blob(detailStmt, 0) length:sqlite3_column_bytes(detailStmt, 0)];
		
		if(data == nil)
			NSLog(@"No image found.");
		else
			self.image = [UIImage imageWithData:data];
		
		NSString *transactionIdNS = [NSString stringWithUTF8String:(char *)sqlite3_column_text(detailStmt, 1)];
        self.transactionId = transactionIdNS;
        NSString *customerReceiptNS = [NSString stringWithUTF8String:(char *)sqlite3_column_text(detailStmt, 2)];
        self.customerReceipt = customerReceiptNS;
        BOOL customerIsCopyNS = sqlite3_column_int(detailStmt, 3);
        self.customerIsCopy = customerIsCopyNS;
        NSString *merchantReceiptNS = [NSString stringWithUTF8String:(char *)sqlite3_column_text(detailStmt, 4)];
        self.merchantReceipt = merchantReceiptNS;
        BOOL merchantIsCopyNS = sqlite3_column_int(detailStmt, 5);
        self.merchantIsCopy = merchantIsCopyNS;
        const void *blob = sqlite3_column_blob(detailStmt, 6);
        NSInteger bytes = sqlite3_column_bytes(detailStmt, 6);
        NSData *blobData = [NSData dataWithBytes:blob length:bytes];
        
        NSDictionary *dictionary = [NSPropertyListSerialization propertyListFromData:blobData
                                                                    mutabilityOption:NSPropertyListImmutable
                                                                              format:NULL
                                                                    errorDescription:nil];
        
        self.xml = dictionary;
        
	}
	else
		NSAssert1(0, @"Error while getting the price of item. '%s'", sqlite3_errmsg(database));
	
	//Reset the detail statement.
	sqlite3_reset(detailStmt);
	
	//Set isDetailViewHydrated as YES, so we do not get it again from the database.
	isDetailViewHydrated = YES;
}

- (void) saveAllData {
	
	if(isDirty) {
		
		if(updateStmt == nil) {
			const char *sql = "update Receipt Set transactionId = ?, authorisedAmount = ?, customerReceipt = ?, customerIsCopy = ?, merchantReceipt = ?, merchantIsCopy = ?, description = ?, image = ?, xml = ? Where receiptID = ?";
			if(sqlite3_prepare_v2(database, sql, -1, &updateStmt, NULL) != SQLITE_OK)
				NSAssert1(0, @"Error while creating update statement. '%s'", sqlite3_errmsg(database));
		}
		
		sqlite3_bind_text(updateStmt, 1, [transactionId UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_int(updateStmt, 2, authorisedAmount);
		sqlite3_bind_text(updateStmt, 3, [customerReceipt UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(updateStmt, 4, customerIsCopy);
        sqlite3_bind_text(updateStmt, 5, [merchantReceipt UTF8String], -1, SQLITE_TRANSIENT);
        sqlite3_bind_int(updateStmt, 6, merchantIsCopy);
        sqlite3_bind_text(updateStmt, 7, [description UTF8String], -1, SQLITE_TRANSIENT);
        
		NSData *imgData = UIImagePNGRepresentation(self.image);
		
		int returnValue = -1;
		if(self.image != nil)
			returnValue = sqlite3_bind_blob(updateStmt, 8, [imgData bytes], [imgData length], NULL);
		else
			returnValue = sqlite3_bind_blob(updateStmt, 8, nil, -1, NULL);
        
        NSData *data = [NSPropertyListSerialization dataFromPropertyList:xml
                                                                  format:NSPropertyListXMLFormat_v1_0
                                                        errorDescription:nil];
        sqlite3_bind_blob(updateStmt, 9, [data bytes], [data length], SQLITE_TRANSIENT);
		sqlite3_bind_int(updateStmt, 10, receiptID);
		
		if(returnValue != SQLITE_OK)
			NSLog(@"Not OK!!!");
		
		if(SQLITE_DONE != sqlite3_step(updateStmt))
			NSAssert1(0, @"Error while updating. '%s'", sqlite3_errmsg(database));
		
		sqlite3_reset(updateStmt);
		
		isDirty = NO;
	}
	
	//Reclaim all memory here.
	transactionId = nil;
	
	isDetailViewHydrated = NO;
}

- (void)setImage:(UIImage *)theItemImage {
	
	self.isDirty = YES;
	image = theItemImage;
}

- (void)setDescription:(NSString *)newValue {
	
	self.isDirty = YES;
	description = [newValue copy];
}

- (void)setCustomerReceipt:(NSString *)newValue {
	
	self.isDirty = YES;
	customerReceipt = [newValue copy];
}

- (NSString*)ammountWithCurrencySymbol
{
    Currency* currency = [[Currency alloc] initWithCode:[xml objectForKey:@"Currency"]];
    NSString* amount = [xml objectForKey:@"RequestedAmount"];
    if (currency.maxFractionDigits != 2){
        NSInteger amountNumber = [amount doubleValue]/100;
        return [HpUtils formatAmount:[@(amountNumber) stringValue] forCurrency:currency.currencyAlpha];
    }
    return [HpUtils formatAmount:amount forCurrency:currency.currencyAlpha];
}

- (NSString*)dateFromTimestamp
{
    NSString* timeStamp = [xml objectForKey:@"EFTTimestamp"];
    if (timeStamp != NULL)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *date = [formatter dateFromString:timeStamp];
        [formatter setDateFormat:@"dd/MM/YYYY"];
        timeStamp = [formatter stringFromDate:date];
        return timeStamp;
    }
    else
    {
        return @"date not available";
    }
}

- (NSString*)htmlReceipt
{
    NSUserDefaults *settings        = [NSUserDefaults standardUserDefaults];
    

    NSMutableString* htmlReceipt = [NSMutableString stringWithString:@"<html><body>"];
    [htmlReceipt appendFormat:@"<h2 style=\"margin-bottom:3px\">%@</h2>", [settings objectForKey:@"merchantName"]];
    [htmlReceipt appendFormat:@"<h3 style=\"margin-bottom:3px;margin-top:0px\">%@</h3>", [settings objectForKey:@"merchantAddress"]];
    [htmlReceipt appendString:@"<h3 style=\"margin-bottom:3px;margin-top:0px\">"];
    [htmlReceipt appendString:[xml objectForKey:@"FinancialStatus"]];
    [htmlReceipt appendString:@"</h3>"];
    [htmlReceipt appendFormat:@"<b>Type: </b>%@",[[xml objectForKey:@"TransactionType"]lowercaseString]];
    [htmlReceipt appendString:@"</p>"];
    [htmlReceipt appendString:@"<p>"];
    [htmlReceipt appendFormat:@"<b>Date:</b> %@",[self dateFromTimestamp]];
    [htmlReceipt appendString:@"</p>"];
    if(image != NULL)
    {
        NSData* imageData = UIImagePNGRepresentation(image);
        NSString* filename = [NSString stringWithFormat:@"%d.png", receiptID];
        NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
        [imageData writeToFile:filePath atomically:YES];
        [htmlReceipt appendFormat:@"<img src=\"file://%@\" height=\"100px\" width=\"100px\" align=\"right\" />",filePath];
    }
    else
    {
        [htmlReceipt appendString:@"<p>No image</p>"];
    }
    [htmlReceipt appendString:@"<p>"];
    [htmlReceipt appendFormat:@"<b>Price:</b> %@",[self ammountWithCurrencySymbol]];
    [htmlReceipt appendString:@"</p>"];  

    if(![description isEqualToString:@""])
    {
        [htmlReceipt appendFormat:@"<p><b>Description:</b><br>%@</p>",description];
    }
    
    [htmlReceipt appendString:@"</body></html>"];
    return htmlReceipt;
}

- (void)customerReceiptIsCopy
{
    NSString* copyReceipt = [customerReceipt stringByReplacingOccurrencesOfString:@"{COPY_RECEIPT}" withString:@"COPY RECEIPT"];
    [self setCustomerReceipt:copyReceipt];
    [self setCustomerIsCopy:YES];
    [self saveAllData];
}

@end
