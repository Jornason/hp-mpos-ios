//
//  hpReciept.h
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
#import <UIKit/UIKit.h>
#import "sqlite3.h"
#import "hpReceiptDelegate.h"

@interface hpReceipt : NSObject {
    
    NSInteger receiptID;
    NSDictionary* xml;
    NSInteger authorisedAmount;
    NSString* transactionId;
    NSString* customerReceipt;
    NSString* merchantReceipt;
    
    NSString *description;
    UIImage *image;
    
    BOOL customerIsCopy;
    BOOL merchantIsCopy;
    
    BOOL isDirty;
    BOOL isDetailViewHydrated;
    
}

@property(nonatomic) NSInteger receiptID;
@property(nonatomic) NSInteger authorisedAmount;
@property(nonatomic, strong) NSDictionary* xml;
@property(nonatomic,strong) NSString* transactionId;
@property(nonatomic,strong) NSString* customerReceipt;
@property(nonatomic,strong) NSString* merchantReceipt;
@property(nonatomic,strong) NSString* description;
@property(nonatomic,strong) UIImage* image;

@property (nonatomic, readwrite) BOOL customerIsCopy;
@property (nonatomic, readwrite) BOOL merchantIsCopy;

@property (nonatomic, readwrite) BOOL isDirty;
@property (nonatomic, readwrite) BOOL isDetailViewHydrated;

//Static methods.
+ (void) getInitialDataToDisplay:(NSString *)dbPath delegate:delegate;
+ (void) finalizeStatements;

//Instance methods.
- (id) initWithPrimaryKey:(NSInteger)pk;
- (NSString*)ammountWithCurrencySymbol;
- (NSString*)dateFromTimestamp;
- (NSString*)htmlReceipt;
- (void) deleteItem;
- (void) addItem;
- (void) hydrateDetailViewData;
- (void) saveAllData;
- (void) customerReceiptIsCopy;

@end
