//
//  hpHeftService.m
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

#import "hpHeftService.h"
#import <QuartzCore/QuartzCore.h>
#import "ExternalAccessory/ExternalAccessory.h"
#import "BWStatusBarOverlay.h"

@implementation hpHeftService
@synthesize heftClient;
@synthesize devices;
@synthesize manager;
@synthesize xmlResponse;
@synthesize receiptDelegate, receipt, transactionDescription, signatureReceipt, automaticConnectToReader, transactionImage, supportModeOn, selectedDevice, newDefaultCardReader, transactionViewController;

NSInteger defaultCardReaderIndex = 0;
NSString* defaultCardReaderStoredSerialNumber;

// Creates a shared hpHeftService object using the singleton pattern
+ (hpHeftService *)sharedHeftService
{
    static hpHeftService *sharedHeftServiceInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedHeftServiceInstance = [[self alloc] init];
    });
    return sharedHeftServiceInstance;
}
- (id)init
{
    self = [super init];
    if (self) {
        activityIndicator = [[UIAlertView alloc] initWithTitle:Localize(@"Processing")
                                                       message:@" " delegate:self
                                             cancelButtonTitle:Localize(@"Cancel")
                                             otherButtonTitles:nil];
        progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 40, 30, 30)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [activityIndicator addSubview:progress];

        heftClient = nil;
        selectedDevice = nil;
        automaticConnectToReader = YES;
        newDefaultCardReader = NO;
        supportModeOn = NO;
        devices = [NSMutableArray array];
        manager = [HeftManager sharedManager];
        manager.delegate = self;
        receiptDelegate =[[hpReceiptDelegate alloc]init];
        [manager resetDevices];
        [BWStatusBarOverlay setAnimation:BWStatusBarOverlayAnimationTypeFromTop];
    }
    return self;
}

// Starts a sale transaction with amount, currency and cardholder present properties
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present
{
    [self showTransactionViewController:eTransactionSale];
    return [heftClient saleWithAmount:amount currency:currency cardholder:present];
}
// Starts a refund transaction with amount, currency and cardholder present properties
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
{
    [self showTransactionViewController:eTransactionRefund];
    return [heftClient refundWithAmount:amount currency:currency cardholder:present];
}

- (BOOL)saleVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction
{
    if (![self isTransactionVoid:transaction])
    {
        [self showTransactionViewController:eTransactionVoid];
        return [heftClient saleVoidWithAmount:amount currency:currency cardholder:present transaction:transaction];
    }
    else
    {
        [self throwVoidError];
        return NO;
    }
}

- (BOOL)refundVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction
{
    if (![self isTransactionVoid:transaction])
    {
        [self showTransactionViewController:eTransactionVoid];
        return [heftClient refundVoidWithAmount:amount currency:currency cardholder:present transaction:transaction];
    }
    else
    {
        [self throwVoidError];
        return NO;
    }
}

- (BOOL)isTransactionVoid:(NSString*)transaction
{
    for (int i = 0; i < [receiptDelegate.itemArray count]; i++) {
        hpReceipt* receiptTran = [receiptDelegate.itemArray objectAtIndex:i];
        if ([[receiptTran.xml objectForKey:@"OriginalEFTTransactionID"] isEqualToString:transaction] && [[receiptTran.xml objectForKey:@"FinancialStatus"] isEqualToString:@"AUTHORISED"])
        {
            return YES;
        }
    }
    return NO;
}

- (void)throwVoidError
{
    activityIndicator.title = Localize(@"Error");
    activityIndicator.message = Localize(@"This transaction voided");
    [activityIndicator show];
}

// Resets/clears the list of found devices in the heft manager
- (void)resetDevices
{
    [manager resetDevices];
}

- (NSMutableArray*)devicesCopy
{
    return [manager devicesCopy];
}

// This function is called if the heft manager can access the blueatooth services
- (void)hasSources;
{
    NSLog(@"hpHeftService hasSources");
    [self startDiscovery:NO];
    
}

// This function is called if the heft manager can NOT access the blueatooth services
- (void)noSources;
{
    NSLog(@"hpHeftService noSources");
}

// Starts discovery of devices and displays an activity indicator
- (void)startDiscoveryWithActivitiMonitor:(BOOL)fDiscoverAllDevices;
{
    [manager startDiscovery:fDiscoverAllDevices];
    activityIndicator.title = Localize(@"Scanning");
    activityIndicator.message = @" ";
    [activityIndicator show];
    [progress startAnimating];
}

// Starts discovery of devices
- (void)startDiscovery:(BOOL)fDiscoverAllDevices;
{
    [manager startDiscovery:fDiscoverAllDevices];
}

- (void)didFindAccessoryDevice:(HeftRemoteDevice *)newDevice
{
    NSLog(@"hpHeftService didFindAccessoryDevice");
    //add found device to list of devices
    [devices addObject:newDevice];
    // Send notification about a new device being found
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
                                                        object:nil];
    [self clientForDevice:newDevice sharedSecret:[self readSharedSecretFromFile] delegate:self];
    
}

- (void)didLostAccessoryDevice:(HeftRemoteDevice *)oldDevice
{
    NSLog(@"hpHeftService didLostAccessoryDevice");
    [devices removeObject:oldDevice];
    heftClient = nil;
    [BWStatusBarOverlay showWithMessage:Localize(@"Reader disconnected!") animated:YES];
    [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
                                                        object:nil];
    
}


// This function is called each time a device is found
- (void)didDiscoverDevice:(HeftRemoteDevice*)newDevice;
{
    NSLog(@"hpHeftService didDiscoverDevice");

    [devices addObject:newDevice];
    // Send notification about a new device being found
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
                                                        object:nil];   
}
// This function gets called when discovery is finished
- (void)didDiscoverFinished;
{
    NSLog(@"hpHeftService didDiscoverFinished");
    //[self connectToLastCardReader];
    // Dismiss activiti indicator
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    
}
// This function connects the application to the card reader and uses the shared secret to authenticate
// If the connections is successfull the didConnect function should be called next
- (void)clientForDevice:(HeftRemoteDevice*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject<HeftStatusReportDelegate>*)aDelegate;
{
    NSLog(@"hpHeftService clientForDevice");
    [BWStatusBarOverlay showWithMessage:@"Connecting to reader..." loading:YES animated:YES];
    selectedDevice = device;
    [manager clientForDevice:device sharedSecret:sharedSecret delegate:aDelegate];
}

// This function is called when the connection to the reader has been established and
// creates an object for the client
- (void)didConnect:(id<HeftClient>)client;
{
    NSLog(@"hpHeftService didConnect");
    NSLog(@"didConnect client: %@", client);
    NSLog(@"didConnect client serial: %@", [[client mpedInfo] objectForKey:@"SerialNumber"]);
    
    if(client == NULL && heftClient == nil)
    {
        selectedDevice = nil;
        [BWStatusBarOverlay showErrorWithMessage:Localize(@"Error connection to reader, please try again.") duration:5 animated:YES];
        [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];
        
    }
    else
    {
        heftClient = nil;
        heftClient = client;
        [heftClient logSetLevel:eLogDebug];
        
        if ([[[heftClient mpedInfo]objectForKey:kSerialNumberInfoKey] isEqual:defaultCardReaderStoredSerialNumber] || newDefaultCardReader)
        {
            NSLog(@"Default CardReader found!");
            defaultCardReaderIndex = 0;
            if(newDefaultCardReader)
            {
                [self storeDefaultCardReader];
            }
            newDefaultCardReader = NO;
            [BWStatusBarOverlay showSuccessWithMessage:Localize(@"Connected!") duration:5 animated:YES];
            [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.33f green:0.74f blue:0.68f alpha:1.0f]];
        }
        else
        {
            NSLog(@"Not found!");
            NSLog(@"CardReaderSerialNumber: %@", [[heftClient mpedInfo]objectForKey:kSerialNumberInfoKey]);
            heftClient = nil;
            selectedDevice = nil;
            defaultCardReaderIndex++;
            [self checkForDefaultCardReaderWithIndex:defaultCardReaderIndex];
        }

    }
    //[connectionAlert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readerConnected"
                                                        object:nil];
    
}

// This function gets called when a transaction is in progress to report of the transaction status
- (void)responseStatus:(id<ResponseInfo>)info;
{
    NSLog(@"hpHeftService responceStatus");
    [transactionViewController setStatusMessage:info.status andStatusCode:info.statusCode];
	[transactionViewController allowCancel:[info.xml[@"CancelAllowed"] boolValue]];
    
    NSLog(@"StatusMessage: %@", info.status);
    NSLog(@"StatusCode: %d", info.statusCode);
    NSLog(@"%@", info.xml.description);
}

// This function gets called if there is an response error in the transaction
- (void)responseError:(id<ResponseInfo>)info;
{
    NSLog(@"hpHeftService responseError");
    [self dismissTransactionViewController];
    activityIndicator.title = Localize(@"Error");
    activityIndicator.message = info.status;
    if(![activityIndicator isVisible])
    {
        [activityIndicator show];
        //[progress startAnimating];
    }
    NSLog(@"%@", info.status);
    NSLog(@"%@", info.xml.description);

}

// Is only called when user chooses to send logs to handpoint in support mode
- (void)responseLogInfo:(id<LogInfo>)info{
    [transactionViewController setStatusMessage:info.status andStatusCode:info.statusCode];
	NSLog(@"responseLogInfo:%@", info.status);
    NSLog(@"%@", info.log);
    NSMutableString* logString = [NSMutableString stringWithFormat:@"Device model: %@ \n",[[UIDevice currentDevice] model]];
    [logString appendFormat:@"System name: %@ \n", [[UIDevice currentDevice] systemName]];
    [logString appendFormat:@"System version: %@ \n",[[UIDevice currentDevice] systemVersion]];
    [logString appendString:info.log];
    
	[logString writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"log.txt"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    [self dismissTransactionViewController];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logsDidDownload"
                                                        object:nil];
}


// This function gets called when a transaction finishes and stores the data for successfull transactions
// Here alot could be moved to a seperat function and re-designed
- (void)responseFinanceStatus:(id<FinanceResponseInfo>)info;
{
    [transactionViewController setStatusMessage:info.status andStatusCode:info.statusCode];
    NSMutableSet *saleSet = [NSSet setWithObjects:@"APPROVED", @"AUTHORISED", @"DECLINED", @"CANCELLED", @"CARD BLOCKED", nil];
    // The other set defined below is the "financialStatus" when it should not print out a receipt.
    //NSMutableSet *otherSet = [NSSet setWithObjects:@"PROCESSED", @"FAILED", @"UNDEFINED", @"INVALID CARD", nil];
    
    NSLog(@"hpHeftService responseFinanceStatus");
    NSLog(@"%@", info.status);
    NSLog(@"%@", info.xml.description);
    NSString* financialStatus = [info.xml objectForKey:@"FinancialStatus"];
    if ([saleSet containsObject:financialStatus]) 
    {
        receipt = [self generateReceipt:info];
        [receiptDelegate addItem:receipt];
        
        NSLog(@"send customer receipt");
        webReceipt = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 595, 0)];
        [webReceipt setDelegate:self];
        
        NSString* merchantReceipt;
        // Remove {COPY_RECEIPT} placeholder
        if ([receipt merchantIsCopy])
        {
            merchantReceipt = [receipt customerReceipt];
        }
        else
        {
            merchantReceipt = [[receipt merchantReceipt] stringByReplacingOccurrencesOfString:@"{COPY_RECEIPT}" withString:@""];
        }
        // TODO: Add functionality so we know if receipt is being sent for the first time or not.
        
        NSLog(@"Merchant receipt: %@", merchantReceipt);
        [webReceipt loadHTMLString:merchantReceipt baseURL:nil];
        NSLog(@"Webview is loading...");
        //The rest is handled in the delegate webViewDidFinishLoad
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transactionFinished"
                                                            object:nil];
        
    }
    else
    {
        // Create a new alert object and set initial values.
        [transactionViewController setStatusMessage:info.status andStatusCode:info.statusCode];
//        UIAlertView *status = [[UIAlertView alloc] initWithTitle:Localize(@"Status")
//                                                         message:info.status
//                                                        delegate:nil
//                                                    cancelButtonTitle:nil
//                                                    otherButtonTitles:Localize(@"Ok"), nil];
//        [status show];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshData"
                                                        object:nil];
    

    [self dismissTransactionViewController];
//    [transactionViewController.view removeFromSuperview];
//    transactionViewController = nil;
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    
    
}

- (hpReceipt*)generateReceipt:(id<FinanceResponseInfo>)info{
    xmlResponse = info;
    
    //Generate all receipt fields with non-null/nil value
    receipt = [[hpReceipt alloc]initWithPrimaryKey:0];
    receipt.customerReceipt = @"";
    receipt.merchantReceipt = @"";
    receipt.customerIsCopy = NO;
    receipt.merchantIsCopy = NO;
    receipt.xml = [NSDictionary alloc];
    receipt.transactionId = 0;
    receipt.authorisedAmount = 0;
    receipt.image = nil;
    receipt.description = @"";
    
    if ([[info customerReceipt] length] != 0)
    {
        receipt.customerReceipt = [info customerReceipt];
    }
    
    if ([[info merchantReceipt] length] != 0)
    {
        receipt.merchantReceipt = [info merchantReceipt];
    }
    else
    {
        if ([signatureReceipt length] != 0)
        {
            receipt.merchantReceipt = signatureReceipt;
            signatureReceipt = @"";
        }
    }
    
    if ([info xml])
    {
        receipt.xml = [info xml];
    }
    
    if ([info transactionId])
    {
        receipt.transactionId = [info transactionId];
    }
    
    if ([info authorisedAmount])
    {
        receipt.authorisedAmount = [info authorisedAmount];
    }
    
    if( transactionImage != NULL)
    {
        receipt.image = transactionImage;
        transactionImage = nil;
    }
    
    if (transactionDescription != nil)
    {
        receipt.description = transactionDescription;
        transactionDescription = nil;
    }
    
    return receipt;
}

// This function gets called when a card that needs a signature is inserted into the card reader
- (void)requestSignature:(NSString*)signatureReceiptIn;
{
    NSLog(@"hpHeftService requestSignature");
    [self dismissTransactionViewController];
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(@"%@",signatureReceiptIn);
    self.signatureReceipt = signatureReceiptIn;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestSignature"
                                                        object:nil];
}

- (void)cancelSignature;
{
    NSLog(@"hpHeftService cancelSignature");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cancelSignature"
                                                        object:nil];
    
}

- (void)acceptSignature:(BOOL)flag
{
    [self showTransactionViewController:eTransactionSale];
    [heftClient acceptSignature:flag];
}
// Stores information about last card reader connected
- (void)storeHeftClientSerial:(HeftRemoteDevice*)client andSharedSecret:(NSData*)secret;
{
    NSLog(@"hpHeftService - storing last reader");
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"clientInfo.txt"];
    
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [archiver encodeObject:client forKey:@"remoteDevice"];
    [archiver encodeObject:secret forKey:@"clientSecret"];
    [archiver finishEncoding];
    
    BOOL success = [data writeToFile:strFile atomically:YES];
    NSLog(@"%d", success);
    
}
// Retrevies the last connected heft client that was stored
- (HeftRemoteDevice*)lastHeftClient;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"clientInfo.txt"];
    
    NSData * dataElm = [[NSData alloc] initWithContentsOfFile:strFile];
    if (dataElm != NULL)
    {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataElm];
        
        HeftRemoteDevice* remoteDevice = [unarchiver decodeObjectForKey:@"remoteDevice"];
        return remoteDevice;
    }
    else
    {
        HeftRemoteDevice* remoteDevice = nil;
        return remoteDevice;
    }
    
}
// Retrevies the shared secret of the last connected reader that was stored
// This would propably be stored somewhere else in the future
- (NSData*)lastHeftClientSecret;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"clientInfo.txt"];
    
    NSData * dataElm = [[NSData alloc] initWithContentsOfFile:strFile];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:dataElm];
    
    NSData* remoteDevice = [unarchiver decodeObjectForKey:@"clientSecret"];
    return remoteDevice;
}

- (NSData*)readSharedSecretFromFile;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"sharedSecret.txt"];
    NSData * dataElm;
    NSMutableData* data = [NSMutableData data];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:strFile])
    {
        NSString *sharedSecretFromFile = [NSString stringWithContentsOfFile:strFile encoding:NSUTF8StringEncoding error:nil];
        for (int i = 0 ; i < 32; i++)
        {
            NSRange range = NSMakeRange (i*2, 2);
            NSString *bytes = [sharedSecretFromFile substringWithRange:range];
            NSScanner* scanner = [NSScanner scannerWithString:bytes];
            unsigned int intValue;
            [scanner scanHexInt:&intValue];
            [data appendBytes:&intValue length:1];
        }
        dataElm = data;
    }
    else
    {
        
        uint8_t ss[32] = {0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x30, 0x31, 0x32};
        dataElm = [[NSData alloc]initWithBytes:ss length:sizeof(ss)];
    }
    return dataElm;
}

- (void)storeDefaultCardReader;
{
    if(heftClient)
    {
        NSString* defaultCardReaderSerialNumber = [[heftClient mpedInfo] objectForKey:kSerialNumberInfoKey];
        [[NSUserDefaults standardUserDefaults] setObject:defaultCardReaderSerialNumber forKey:@"defaultCardReaderSerialNumber"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
}
- (void)checkForDefaultCardReader;
{
    
    NSLog(@"checkForDefaultCardReader");
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"defaultCardReaderSerialNumber"])
    {
        defaultCardReaderStoredSerialNumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultCardReaderSerialNumber"];
        if ([[self devicesCopy] count] > 0)
        {
            [self clientForDevice:[[self devicesCopy] objectAtIndex:0] sharedSecret:[self readSharedSecretFromFile] delegate:self];
        }
        else
        {
            [BWStatusBarOverlay showWithMessage:Localize(@"No card reader available!") animated:YES];
            [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];
        }
    }
    else
    {
        defaultCardReaderStoredSerialNumber = @"";
        [BWStatusBarOverlay showWithMessage:Localize(@"No default card reader selected") animated:YES];
        [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];
    }
    NSLog(@"defaultCardReaderStoredSerialNumber: %@", defaultCardReaderStoredSerialNumber);

}

- (void)checkForDefaultCardReaderWithIndex:(NSInteger)index;
{
    if (index < [[self devicesCopy] count])
    {
        [self clientForDevice:[[self devicesCopy] objectAtIndex:index] sharedSecret:[self readSharedSecretFromFile] delegate:self];
    }
    else
    {
        [BWStatusBarOverlay showWithMessage:@"Default card reader not found" animated:YES];
        [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];    
    }
}


// Connects to last connected reader
- (void)connectToLastCardReader;
{
    if(automaticConnectToReader)
    {
        NSLog(@"connectToLastCardReader");
        HeftRemoteDevice* lastClient = [self lastHeftClient];
        if (lastClient != NULL)
        {
            NSMutableArray* lastDeviceArray = [[NSMutableArray alloc]init];
            [lastDeviceArray addObject:lastClient];
            NSString* lastName = [[lastDeviceArray objectAtIndex:0]name];
            NSString* newName = [[devices objectAtIndex:0]name];
            if([newName isEqual:lastName]) {
                NSLog(@"found Device");
                [self clientForDevice:lastClient sharedSecret:[self lastHeftClientSecret] delegate:self];
            }
        }
    }
}

- (void)checkIfAccessoryIsConnected
{
    NSString* eaProtocol = @"com.datecs.pinpad";
    NSArray *accessories = [[EAAccessoryManager sharedAccessoryManager]
                            connectedAccessories];

    NSLog(@"accessories desc: %@",[accessories description]);
    if (heftClient == nil)
    {
        if ([accessories count] == 0)
        {
            [BWStatusBarOverlay showWithMessage:Localize(@"Reader disconnected!") animated:YES];
            [BWStatusBarOverlay setBackgroundColor:[UIColor colorWithRed:0.94f green:0.40f blue:0.18f alpha:1.0f]];
        }
        else
        {
            for (EAAccessory* accessory in accessories)
            {
                if([accessory.protocolStrings containsObject:eaProtocol])
                {
                    //Connect to last known card reader
                    HeftRemoteDevice* newRemoteDevice = [manager.devicesCopy objectAtIndex:(manager.devicesCopy.count-1)];
                    [self clientForDevice:newRemoteDevice sharedSecret:[self readSharedSecretFromFile] delegate:self];
                }
            }
        }
    }
}

- (BOOL)financeInit{
    [self showTransactionViewController:eTransactionFinInit];
    return [heftClient financeInit];
}

- (void)storeReceiptIniCloud:(NSMutableData*)receiptData withFilename:(NSString*)filename
{
    NSError* error = nil;
    
    //create url to write pdf to Documents folder
    NSString *localFilename = [NSString stringWithFormat:@"/%@.pdf", filename];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* document = [documentsDirectory stringByAppendingString:localFilename];
    [receiptData writeToFile:document atomically:YES];
    
    //Create url to move pdf to iCloud folder
    NSString *iCloudFilename = [NSString stringWithFormat:@"Documents/%@.pdf", filename];
    NSURL *iCloudFolderURL = [[NSFileManager defaultManager]
                              URLForUbiquityContainerIdentifier:nil];
    iCloudFolderURL = [iCloudFolderURL URLByAppendingPathComponent:iCloudFilename];
    
    //Copy pdf to iCloud folder
    [[NSFileManager defaultManager]setUbiquitous:YES itemAtURL:[NSURL URLWithString:document] destinationURL:iCloudFolderURL error:&error];
}

-(void) webViewDidFinishLoad:(UIWebView *)webView {
    NSLog(@"merchantReceipt webview loaded");
    
    // Get full height of content
    NSString *heightStr = [webReceipt stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    int height = [heightStr intValue];
    
    // Set height
    [webReceipt setFrame:CGRectMake(0.f, 0.f, 595, height)];
    
    // Convert to pdf
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, webReceipt.bounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef pdfContext = UIGraphicsGetCurrentContext();
    [webReceipt.layer renderInContext:pdfContext];
    UIGraphicsEndPDFContext();
    [self storeReceiptIniCloud:pdfData withFilename:[receipt.xml objectForKey:@"EFTTimestamp"]];
    
}

// adds functionality to the buttons in the alert view
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0){
        [heftClient cancel];
    }else if (buttonIndex == 1){
        
    }
}
// Can be used to resize the alert view
- (void)willPresentAlertView:(UIAlertView *)alertView {
    alertView.frame = CGRectMake(activityIndicator.frame.origin.x, activityIndicator.frame.origin.y, activityIndicator.frame.size.width, activityIndicator.frame.size.height);
}

// mPED Logging Functionality
- (void) logSetLevel:(eLogLevel)level {
    [heftClient logSetLevel:level];
}
- (BOOL) logReset {
    return [heftClient logReset];
}

- (BOOL) logGetInfo {
    [self showTransactionViewController:eTransactionGetLog];
    return [heftClient logGetInfo];
}

# pragma mark Transaction controller

- (void)showTransactionViewController:(eTransactionType)tType{
    UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
    UIViewController* visible = keyWindow.rootViewController;
	transactionViewController = [TransactionViewController transactionWithType:tType storyboard:visible.storyboard];
	[transactionViewController showViewController:transactionViewController];
}

- (void)dismissTransactionViewController{
	[transactionViewController dismissViewController:transactionViewController];
	transactionViewController = nil;
}

@end
