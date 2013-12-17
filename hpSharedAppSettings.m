//
//  hpSharedAppSettings.m
//  mPOS
//
//  Created by Juan Nuñez on 9/25/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "hpSharedAppSettings.h"
#import "IASKSettingsReader.h"
#import <MessageUI/MessageUI.h>
#import "CustomViewCell.h"
#import "hpSharedAppSettings.h"

@implementation hpSharedAppSettings

@synthesize padlock, oldSettings;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static hpSharedAppSettings *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        padlock = @"Default Property Value";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
        self.oldSettings = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        self.sharedHeftService =[hpHeftService sharedHeftService];
        [self customInits];
        [self setDefaults];
    }
    return self;
}

-(void)customInits{
    [[NSUserDefaults standardUserDefaults] setValue:NO forKey:@"EnableSupport"];
    NSString* version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    [[NSUserDefaults standardUserDefaults] setValue:version forKey:@"version"];
}
-(void)setDefaults {
    
    //get the plist location from the settings bundle
    NSString *settingsPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Settings.bundle"];
    NSString *plistPath = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
    
    //get the preference specifiers array which contains the settings
    NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
    
    //use the shared defaults object
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    //for each preference item, set its default if there is no value set
    for(NSDictionary *item in preferencesArray) {
        
        //get the item key, if there is no key then we can skip it
        NSString *key = [item objectForKey:@"Key"];
        if (key) {
            
            //check to see if the value and default value are set
            //if a default value exists and the value is not set, use the default
            id value = [defaults objectForKey:key];
            id defaultValue = [item objectForKey:@"DefaultValue"];
            if(defaultValue && !value) {
                [defaults setObject:defaultValue forKey:key];
            }
        }
    }
    
    //write the changes to disk
    [defaults synchronize];
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(void)setPropertyWithKey:(NSString*)key withValue:(NSString*)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
}
-(NSString*)getPropertyWithKey:(NSString*)key{
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(NSString*)getOldPropertyWithKey:(NSString*)key{
    return [oldSettings objectForKey:key];
}

-(void)setOldPropertyWithKey:(NSString*)key withValue:(NSString*)value{
       
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"hpConfig.plist"];
    
    [self.oldSettings setObject:value forKey:key];
    [self.oldSettings writeToFile:path atomically:YES];
}










@end
