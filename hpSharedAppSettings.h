//
//  hpSharedAppSettings.h
//  mPOS
//
//  Created by Juan Nuñez on 9/25/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IASKAppSettingsViewController.h"
#import <UIKit/UIKit.h>
#import "hpViewController.h"
#import <MessageUI/MessageUI.h> // To be able to send email


@interface hpSharedAppSettings : NSObject <IASKSettingsDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate> {
    NSString *padlock;
    UIAlertView *fetchingLogsAlert;
}

@property (nonatomic, retain) NSString *padlock;


+ (id)sharedManager;
-(void)setDefaults;
-(void)customInits;
-(void)setPropertyWithKey:(NSString*)key withValue:(NSString*)value;
-(NSString*)getPropertyWithKey:(NSString*)key;

-(NSString*)getOldPropertyWithKey:(NSString*)key;
-(void)setOldPropertyWithKey:(NSString*)key withValue:(NSString*)value;
@property NSMutableDictionary *oldSettings;
@property hpHeftService* sharedHeftService;

@end