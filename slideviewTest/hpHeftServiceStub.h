//
//  hpHeftServiceStub.h
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

@class hpHeftServiceStubClient;
@class hpHeftServiceStubManager;

typedef hpHeftServiceStubClient HeftClient;
typedef hpHeftServiceStubClient HeftRemoteDevice;
typedef hpHeftServiceStubManager HeftManager;


@interface hpHeftServiceStub : NSObject
{
    UIAlertView *activityIndicator;
    UIActivityIndicatorView *progress;
    NSObject *heftClient;
    NSObject *manager;
    NSMutableArray* devices;
}

@property(retain, nonatomic) NSObject *heftClient;
@property(retain, nonatomic) NSMutableArray* devices;
@property(retain, nonatomic) NSObject *manager;

+ (NSObject *)sharedHeftService;
- (void)starDiscoveryWithActivitiMonitor:(BOOL)fDiscoverAllDevices;
- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present;
- (void)resetDevices;
- (void)clientForDevice:(NSObject*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject*)aDelegate;


@end
