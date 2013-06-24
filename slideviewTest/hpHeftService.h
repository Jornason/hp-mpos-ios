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

@interface hpHeftService : NSObject <HeftDiscoveryDelegate, HeftStatusReportDelegate>
{
    UIAlertView *activityIndicator;
    UIActivityIndicatorView *progress;
    id<HeftClient> heftClient;
    HeftManager* manager;
    NSMutableArray* devices;
    id<FinanceResponseInfo> xmlResponce;
    hpReceiptDelegate* receiptDelegate;
    hpReceipt *receipt;
    NSString* transactionDescription;
    UIImage* transactionImage;
    BOOL automaticConnectToReader;
    BOOL supportModeOn;
}

@property(retain, nonatomic) id<HeftClient> heftClient;
@property(retain, nonatomic) NSMutableArray* devices;
@property(retain, nonatomic) HeftManager* manager;
@property(retain, nonatomic) id<FinanceResponseInfo> xmlResponce;
@property(retain, nonatomic) hpReceiptDelegate* receiptDelegate;
@property(retain, nonatomic) hpReceipt *receipt;
@property(retain, nonatomic) NSString* transactionDescription;
@property(retain, nonatomic) UIImage* transactionImage;
@property(nonatomic) BOOL supportModeOn;
@property(nonatomic) BOOL automaticConnectToReader;


+ (hpHeftService *)sharedHeftService;
- (void)startDiscoveryWithActivitiMonitor:(BOOL)fDiscoverAllDevices;
- (void)startDiscovery:(BOOL)fDiscoverAllDevices;
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
- (BOOL)refundWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
- (void)resetDevices;
- (void)clientForDevice:(HeftRemoteDevice*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject<HeftStatusReportDelegate>*)aDelegate;
- (void)connectToLastCardReader;
- (void) logSetLevel:(eLogLevel)level;
- (BOOL) logReset;
- (BOOL) logGetInfo;
- (NSData*)readSharedSecretFromFile;

@end