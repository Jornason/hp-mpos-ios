//
//  Currency.h
//  mPOS
//
//  Created by Haukur Páll on 9/17/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Currency : NSObject{
    
    NSInteger maxFractionDigits;
    NSInteger minFractionDigits;
    NSString* currencyCode;
    NSString* currencyAlpha;
    NSString* currencySymbol;
    NSString* groupingSeparator;
    NSString* decimalSeparator;
    Boolean   infront;
    NSInteger divider;
}

@property NSInteger maxFractionDigits;
@property NSInteger minFractionDigits;
@property NSString* currencyCode;
@property NSString* currencyAlpha;
@property NSString* currencySymbol;
@property NSString* groupingSeparator;
@property NSString* decimalSeparator;
@property Boolean   infront;
@property NSInteger divider;

- (Currency*) initWithAlpha:(NSString*)alpha;
- (Currency*) initWithCode:(NSString*)code;

@end
