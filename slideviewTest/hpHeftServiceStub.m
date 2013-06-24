//
//  hpHeftServiceStub.m
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

#import "hpHeftServiceStub.h"
#import "hpHeftServiceStubClient.h"
#import "hpHeftServiceStubManager.h"

@class hpHeftServiceStubClient;
@class hpHeftServiceStubManager;
@interface hpHeftServiceStub ()

@end

@implementation hpHeftServiceStub
@synthesize heftClient;
@synthesize devices;
@synthesize manager;

+ (NSObject *)sharedHeftService
{
    static NSObject *sharedHeftServiceInstance = nil;
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
        activityIndicator = [[UIAlertView alloc] initWithTitle:Localize(@"Processing") message:@" " delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        progress= [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(125, 80, 30, 30)];
        progress.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [activityIndicator addSubview:progress];
        //heftClient = [[hpHeftServiceStubClient alloc]init];
        heftClient = nil;
        devices = [NSMutableArray array];
        manager = [hpHeftServiceStubManager sharedManager];
        //manager.delegate = self;
        [self resetDevices];
    }
    return self;
}

- (void)starDiscoveryWithActivitiMonitor:(BOOL)fDiscoverAllDevices
{
    activityIndicator.title = Localize(@"Scanning");
    [activityIndicator show];
    [progress startAnimating];
    //[devices addObject:[hpHeftServiceStubClient init]];
    // Send notification about a new device being found
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshDevicesTableView"
                                                        object:nil];

    
}

- (void)resetDevices
{
    [devices removeAllObjects];
}

- (void)clientForDevice:(NSObject*)device sharedSecret:(NSData*)sharedSecret delegate:(NSObject*)aDelegate
{
    NSLog(@"hpHeftServiceStup clientForDevice");
    heftClient = device;
    
}

- (BOOL)saleWithAmount:(NSInteger)amount currency:(NSString*)currency cardholder:(BOOL)present
{
    // Create a new alert object and set initial values.
    UIAlertView *status = [[UIAlertView alloc] initWithTitle:Localize(@"Status")
                                                     message:Localize(@"Approved")
                                                    delegate:nil
                                           cancelButtonTitle:Localize(@"Ok")
                                           otherButtonTitles:nil];
    // Display the alert to the user
    [status show];
    return YES;
}

@end
