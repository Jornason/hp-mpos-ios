//
//  SQLAppDelegate.m
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

#import "hpReceiptDelegate.h"
#import "hpReceipt.h"

@implementation hpReceiptDelegate

@synthesize itemArray;

- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"init hpReceiptAppdelegate");
        //Copy database to the user's phone if needed.
        [self copyDatabaseIfNeeded];
        
        //Initialize the array.
        NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        self.itemArray = tempArray;
        //[tempArray release];

        //Once the db is copied, get the initial data to display on the screen.
        [hpReceipt getInitialDataToDisplay:[self getDBPath] delegate:self];
    }
    return self;
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	//Copy database to the user's phone if needed.
	[self copyDatabaseIfNeeded];
	
	//Initialize the array.
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	self.itemArray = tempArray;
	//[tempArray release];
	
	//Once the db is copied, get the initial data to display on the screen.
	[hpReceipt getInitialDataToDisplay:[self getDBPath] delegate:self];
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	
	//Save all the dirty item objects and free memory.
	[self.itemArray makeObjectsPerformSelector:@selector(saveAllData)];
	
	[hpReceipt finalizeStatements];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    
    //Save all the dirty item objects and free memory.
	[self.itemArray makeObjectsPerformSelector:@selector(saveAllData)];
}

- (void) copyDatabaseIfNeeded {
	
	//Using NSFileManager we can perform many file system operations.
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSError *error;
	NSString *dbPath = [self getDBPath];
	BOOL success = [fileManager fileExistsAtPath:dbPath]; 
	
	if(!success) {
		
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"hpReceipts.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:dbPath error:&error];
		
		if (!success) 
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
	}	
}

- (NSString *) getDBPath {
    
    NSLog(@"getDBPath");
	
	//Search for standard documents using NSSearchPathForDirectoriesInDomains
	//First Param = Searching the documents directory
	//Second Param = Searching the Users directory and not the System
	//Expand any tildes and identify home directories.
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	return [documentsDir stringByAppendingPathComponent:@"hpReceipts.sqlite"];
}

- (void) removeItem:(hpReceipt *)itemObj {
	
	//Delete it from the database.
	[itemObj deleteItem];
	
	//Remove it from the array.
	[itemArray removeObject:itemObj];
}

- (void) addItem:(hpReceipt *)itemObj {
	
	//Add it to the database.
	[itemObj addItem];
	
	//Add it to the array.
	[itemArray addObject:itemObj];
}

- (void)saveAllData {
    
    //Save all the dirty item objects and free memory.
	[self.itemArray makeObjectsPerformSelector:@selector(saveAllData)];
}

@end
