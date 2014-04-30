//
//  egAppDelegate.m
//  slideviewTest
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

#import "hpAppDelegate.h"
#import <CoreData/CoreData.h>
#import "hpSharedAppSettings.h"


@implementation hpAppDelegate

//CoreData

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//CoreData Starts here !!!

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil)
    {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MyStore" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil)
    {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MyStore.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

//CoreData Ends Here !!!

//Defaults
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [self performSelector:@selector(copyPlist)];
    [self performSelector:@selector(copySharedSecret)];
    
    //Check if iCloud is functioning
    NSURL *ubiq = [[NSFileManager defaultManager]
                   URLForUbiquityContainerIdentifier:nil];
    if (ubiq) {
        NSLog(@"iCloud access at %@", ubiq);
        // TODO: Load document...
    } else {
        NSLog(@"No iCloud access");
    }
    
    [hpSharedAppSettings sharedManager];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [self storeSharedSecretFromFile:url];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)copyPlist
{
    //Copy plist file from bundle to Documents folder on launch if not found in Documents folder
    hpReceiptDelegate *receiptDelegate = [[hpReceiptDelegate alloc]init];
    [receiptDelegate copyDatabaseIfNeeded];
    
    NSFileManager *fileManger=[NSFileManager defaultManager];
    NSError *error;
    NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    
    NSString *doumentDirectoryPath=[pathsArray objectAtIndex:0];
    
    NSString *destinationPath= [doumentDirectoryPath stringByAppendingPathComponent:@"hpConfig.plist"];
    
    if ([fileManger fileExistsAtPath:destinationPath]){
        NSLog(@"database localtion %@",destinationPath);
        return;
    }
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"hpConfig" ofType:@"plist"];
    
    [fileManger copyItemAtPath:sourcePath toPath:destinationPath error:&error];
}

- (void)copySharedSecret {
    
    //Check if SharedSecret has been saved in NSUserDefaults
    if (![[NSUserDefaults standardUserDefaults] stringForKey:@"savedSharedSecret"]) {
        
        //Get path to sharedSecret.txt
        NSFileManager *fileManger=[NSFileManager defaultManager];
        NSArray *pathsArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *doumentDirectoryPath=[pathsArray objectAtIndex:0];
        NSString *sharedSecretFile= [doumentDirectoryPath stringByAppendingPathComponent:@"sharedSecret.txt"];
        
        //Check if sharedSecret.txt exists
        if ([fileManger fileExistsAtPath:sharedSecretFile]){
            
            //Copy shared secret from file
            NSString *sharedSecretFromFile = [NSString stringWithContentsOfFile:sharedSecretFile encoding:NSUTF8StringEncoding error:nil];
            //Store shared secret in NSUserDefaults
            [[NSUserDefaults standardUserDefaults] setObject:sharedSecretFromFile forKey:@"savedSharedSecret"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            //Remove sharedSecret.txt
            [fileManger removeItemAtPath:sharedSecretFile error:nil];
            return;
        }
        // else: nothing - shared secret was not been saved with version 1.2.1 or older
    }
    //else: nothing - Shared secret has been saved in NSUserDefaults
}


- (void)storeSharedSecretFromFile:(NSURL *)url
{
    NSLog(@"Url: %@", [url absoluteString]);
    NSString* content = [NSString stringWithContentsOfFile:[url path]
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    content = [content uppercaseString];
    NSLog(@"Content: %@", content);
    NSString *prefix = @"SS=";
    
    if ([content hasPrefix:prefix])
    {
        NSCharacterSet *hex = [NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"];
        hex = [hex invertedSet];
        NSString *contentWithoutPrefix = [content substringFromIndex:[prefix length]];
        if ([contentWithoutPrefix rangeOfCharacterFromSet:hex].location == NSNotFound && contentWithoutPrefix.length == 64)
        {
            [[NSUserDefaults standardUserDefaults] setObject:contentWithoutPrefix forKey:@"savedSharedSecret"];
            [[NSUserDefaults standardUserDefaults]synchronize];

            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shared secret saved"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Shared secret not valid"
                                                            message:@"Please contact Handpoint support"
                                                           delegate:self
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert setAlertViewStyle:UIAlertViewStyleDefault];
            [alert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File error"
                                                        message:@"This file in not a valid shared secret file"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert setAlertViewStyle:UIAlertViewStyleDefault];
        [alert show];
    }
    
}

@end
