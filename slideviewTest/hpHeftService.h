//
//  hpHeftService.h
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

#import <Foundation/Foundation.h>
#import "HeftClient.h"
#import "HeftManager.h"
#import "HeftStatusReportPublic.h"
#import "hpReceipt.h"
#import "TransactionViewController.h"
#import "CmdIds.h"
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface hpHeftService : NSObject <HeftDiscoveryDelegate, HeftStatusReportDelegate, UIWebViewDelegate, SKPSMTPMessageDelegate>
{
    UIAlertView *activityIndicator;
    UIActivityIndicatorView *progress;
    id<HeftClient> heftClient;
    HeftRemoteDevice *selectedDevice;
    HeftManager* manager;
    NSMutableArray* devices;
    id<FinanceResponseInfo> xmlResponse;
    hpReceiptDelegate* receiptDelegate;
    hpReceipt *receipt;
    NSString* signatureReceipt;
    NSString* transactionDescription;
    UIImage* transactionImage;
    BOOL automaticConnectToReader;
    BOOL newDefaultCardReader;
    BOOL supportModeOn;
    
    SKPSMTPMessage *emailMessage;
    TransactionViewController* transactionViewController;
    UIWebView* webReceipt;
}

@property(retain, nonatomic) id<HeftClient> heftClient;
@property(retain, nonatomic) HeftRemoteDevice *selectedDevice;
@property(retain, nonatomic) NSMutableArray* devices;
@property(retain, nonatomic) HeftManager* manager;
@property(retain, nonatomic) id<FinanceResponseInfo> xmlResponse;
@property(retain, nonatomic) hpReceiptDelegate* receiptDelegate;
@property(retain, nonatomic) hpReceipt *receipt;
@property(retain, nonatomic) NSString* signatureReceipt;
@property(retain, nonatomic) NSString* transactionDescription;
@property(retain, nonatomic) UIImage* transactionImage;
@property(retain, nonatomic) UIImage* signatureImage;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property(nonatomic) BOOL supportModeOn;
@property(nonatomic) BOOL automaticConnectToReader;
@property(nonatomic) BOOL newDefaultCardReader;
@property(strong, nonatomic) SKPSMTPMessage *emailMessage;
@property(retain, nonatomic) TransactionViewController* transactionViewController;


+ (hpHeftService *)sharedHeftService;
- (void)startDiscoveryWithActivitiMonitor:(BOOL)fDiscoverAllDevices;
- (void)startDiscovery:(BOOL)fDiscoverAllDevices;
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
- (BOOL)saleVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction;
- (BOOL)refundVoidWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present transaction:(NSString*)transaction;
- (void)throwVoidError;
- (BOOL)isTransactionVoid:(NSString*)transaction;
- (void)resetDevices;
- (void)clientForDevice:(HeftRemoteDevice*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject<HeftStatusReportDelegate>*)aDelegate;
- (void)checkIfAccessoryIsConnected;
- (BOOL)financeInit;
- (void)storeDefaultCardReader;
- (void)checkForDefaultCardReader;
- (void)checkForDefaultCardReaderWithIndex:(NSInteger)index;
- (void) logSetLevel:(eLogLevel)level;
- (BOOL) logReset;
- (BOOL) logGetInfo;
- (void)acceptSignature:(BOOL)flag;
- (NSData*)getSavedSharedSecret;
- (NSMutableArray*)devicesCopy;

- (void)dismissTransactionViewController;



@end