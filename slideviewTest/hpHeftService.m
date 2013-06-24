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

@implementation hpHeftService
@synthesize heftClient;
@synthesize devices;
@synthesize manager;
@synthesize xmlResponce;
@synthesize receiptDelegate, receipt, transactionDescription, automaticConnectToReader, transactionImage, supportModeOn;


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
        activityIndicator = [[UIAlertView alloc] initWithTitle:Localize(@"Processing") message:@" " delegate:self cancelButtonTitle:Localize(@"Cancel")otherButtonTitles:nil];
        progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 40, 30, 30)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [activityIndicator addSubview:progress];
        heftClient = nil;
        automaticConnectToReader = YES;
        supportModeOn = NO;
        devices = [NSMutableArray array];
        manager = [HeftManager sharedManager];
        manager.delegate = self;
        receiptDelegate =[[hpReceiptDelegate alloc]init];
        [manager resetDevices];
    }
    return self;
}

// Starts a sale transaction with amount, currency and cardholder present properties
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present
{
    return [heftClient saleWithAmount:amount currency:currency cardholder:present];
}
// Starts a refund transaction with amount, currency and cardholder present properties
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
{
    return [heftClient refundWithAmount:amount currency:currency cardholder:present];
}

// Resets/clears the list of found devices in the heft manager
- (void)resetDevices
{
    [manager resetDevices];
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
    //[manager startDiscovery:fDiscoverAllDevices];
//    activityIndicator.title = Localize(@"Scanning");
//    activityIndicator.message = @" ";
//    [activityIndicator show];
//    [progress startAnimating];
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
}

- (void)didLostAccessoryDevice:(HeftRemoteDevice *)oldDevice
{
    NSLog(@"hpHeftService didLostAccessoryDevice");
    [devices removeObject:oldDevice];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
                                                        object:nil];
    
}


//// This function is called each time a device is found
//- (void)didDiscoverDevice:(HeftRemoteDevice*)newDevice;
//{
//    NSLog(@"hpHeftService didDiscoverDevice");
//
//    [devices addObject:newDevice];
//    // Send notification about a new device being found
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
//                                                        object:nil];
//    // Declare the shared secret in hex numbers.
//
//
//    
//}
// This function gets called when discovery is finished
- (void)didDiscoverFinished;
{
    NSLog(@"hpHeftService didDiscoverFinished");
    [self connectToLastCardReader];
    // Dismiss activiti indicator
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    
}
// This function connects the application to the card reader and uses the shared secret to authenticate
// If the connections is successfull the didConnect function should be called next
- (void)clientForDevice:(HeftRemoteDevice*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject<HeftStatusReportDelegate>*)aDelegate;
{
    NSLog(@"hpHeftService clientForDevice");
    activityIndicator.title = Localize(@"Connecting");
    activityIndicator.message = @" ";
    [activityIndicator show];
    [progress startAnimating];
    [manager clientForDevice:device sharedSecret:sharedSecret delegate:aDelegate];
}

// This function is called when the connection to the reader has been established and
// creates an object for the client
- (void)didConnect:(id<HeftClient>)client;
{
    NSLog(@"hpHeftService didConnect");
    NSLog(@"didConnect client: %@", client);
    
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    UIAlertView *connectionAlert = [[UIAlertView alloc] initWithTitle:Localize(@"Connection to reader:")
                                                     message:@" "
                                                    delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:Localize(@"Ok"), nil];
    
    if(client == NULL)
    {
        connectionAlert.message = Localize(@"Error connection to reader, please try again.");
        
    }
    else
    {
        heftClient = nil;
        heftClient = client;
        [heftClient logSetLevel:eLogDebug];
        connectionAlert.message = Localize(@"Connected!");
    }
    [connectionAlert show];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"readerConnected"
                                                        object:nil];
    
}

// This function gets called when a transaction is in progress to report of the transaction status
- (void)responseStatus:(id<ResponseInfo>)info;
{
    NSLog(@"hpHeftService responceStatus");
    activityIndicator.title = Localize(@"Processing");
    [activityIndicator show];
    //[progress startAnimating];
    
    NSLog(@"%@", info.status);
    NSLog(@"%@", info.xml.description);
    activityIndicator.message = info.status;
    
    
    
}

// This function gets called if there is an response error in the transaction
- (void)responseError:(id<ResponseInfo>)info;
{
    NSLog(@"hpHeftService responceError");
    NSLog(@"%@", info.status);
    NSLog(@"%@", info.xml.description);
    
    
    
}

// Is only called when user chooses to send logs to handpoint in support mode
- (void)responseLogInfo:(id<LogInfo>)info{
	NSLog(@"responseLogInfo:%@", info.status);
    NSLog(@"%@", info.log);
    NSMutableString* logString = [NSMutableString stringWithFormat:@"Device model: %@ \n",[[UIDevice currentDevice] model]];
    [logString appendFormat:@"System name: %@ \n", [[UIDevice currentDevice] systemName]];
    [logString appendFormat:@"System version: %@ \n",[[UIDevice currentDevice] systemVersion]];
    [logString appendString:info.log];
    
	[logString writeToFile:[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"log.txt"] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"logsDidDownload"
                                                        object:nil];
}


// This function gets called when a transaction finishes and stores the data for successfull transactions
// Here alot could be moved to a seperat function and re-designed
- (void)responseFinanceStatus:(id<FinanceResponseInfo>)info;
{
    
    NSLog(@"hpHeftService responceFinanceStatus");
    NSLog(@"%@", info.status);
    NSLog(@"%@", info.customerReceipt);
    NSLog(@"%@", info.xml.description);
    if(![[info.status uppercaseString] isEqualToString:@"USER CANCELLED"])
    {
        xmlResponce = info;
        receipt = [[hpReceipt alloc]initWithPrimaryKey:0];
        receipt.customerReceipt = [info customerReceipt];
        receipt.customerIsCopy = NO;
        receipt.merchantReceipt = [info merchantReceipt];
        receipt.merchantIsCopy = NO;
        receipt.xml = [info xml];
        receipt.transactionId = [info transactionId];
        receipt.description = transactionDescription;
        receipt.authorisedAmount = [info authorisedAmount];
        if( transactionImage != NULL)
        {
            receipt.image = transactionImage;
        }
        [receiptDelegate addItem:receipt];
    }
    
    // Display the alert to the user
    if ([[info.status uppercaseString] isEqualToString:@"APPROVED"] || [[info.status uppercaseString] isEqualToString:@"AUTHORISED"])
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"transactionFinished"
                                                            object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadListData"
                                                            object:nil];
        
    }
    else
    {
        // Create a new alert object and set initial values.
        UIAlertView *status = [[UIAlertView alloc] initWithTitle:Localize(@"Status")
                                                         message:info.status
                                                        delegate:nil
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:Localize(@"Ok"), nil];
        [status show];
    }
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    
    
}

// This function gets called when a card that needs a signature is inserted into the card reader
- (void)requestSignature:(NSString*)receipt;
{
    NSLog(@"hpHeftService requestSignature");
    [activityIndicator dismissWithClickedButtonIndex:0 animated:YES];
    NSLog(receipt);
    self.receipt.customerReceipt = receipt;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"requestSignature"
                                                        object:nil];
}

- (void)cancelSignature;
{
    NSLog(@"hpHeftService cancelSignature");
    
}
// Stores information about last card reader connected
- (void)storeHeftClientSerial:(HeftRemoteDevice*)client andSharedSecret:(NSData*)secret;
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *strFile = [documentsDirectory stringByAppendingPathComponent:@"clientInfo.txt"];
    
    NSMutableData *data = [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    
    [archiver encodeObject:client forKey:@"remoteDevice"];
    [archiver encodeObject:secret forKey:@"clientSecret"];
    [archiver finishEncoding];
    
    BOOL success = [data writeToFile:strFile atomically:YES];
    
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

// Connects to last coonected reader
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
    return [heftClient logGetInfo];
}

@end
