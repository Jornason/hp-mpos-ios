//
//  hpHeftServiceStubManager.m
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

#import "hpHeftServiceStubManager.h"

@implementation hpHeftServiceStubManager
@synthesize client;

+ (NSObject*)sharedManager
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
        client = [[hpHeftServiceStubClient alloc]init];
        devices = [NSArray array];
    }
    return self;
}


@end
