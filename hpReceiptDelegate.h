//
//  SQLAppDelegate.h
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

#import <UIKit/UIKit.h>

@class hpReceipt;

@interface hpReceiptDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
	
	//To hold a list of objects
    NSMutableArray *itemArray;
}

@property (nonatomic, retain) NSMutableArray *itemArray;

- (id)init;
- (void) copyDatabaseIfNeeded;
- (NSString *) getDBPath;

- (void) removeItem:(hpReceipt *)itemObj;
- (void) addItem:(hpReceipt *)itemObj;
- (void) saveAllData;

@end

