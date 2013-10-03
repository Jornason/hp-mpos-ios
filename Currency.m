//
//  Currency.m
//  mPOS
//
//  Created by Haukur Páll on 9/17/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "Currency.h"

@implementation Currency

@synthesize currencyCode, maxFractionDigits, minFractionDigits, currencyAlpha, groupingSeparator,
    decimalSeparator, currencySymbol, infront, divider;

- (Currency*) initWithAlpha:(NSString*)alpha{
    if (self = [super init]){
        if ([alpha isEqualToString:@"GBP"]){
            self.currencyCode       = @"0826";
            self.currencySymbol     = @"£";
            self.maxFractionDigits  = 2;
            self.minFractionDigits  = 2;
            self.currencyAlpha      = @"GBP";
            self.groupingSeparator  = @",";
            self.decimalSeparator   = @".";
            self.infront            = YES;
            self.divider            = 100;
        } else if ([alpha isEqualToString:@"USD"]){
            self.currencyCode       = @"0840";
            self.currencySymbol     = @"$";
            self.maxFractionDigits  = 2;
            self.minFractionDigits  = 2;
            self.currencyAlpha      = @"USD";
            self.groupingSeparator  = @",";
            self.decimalSeparator   = @".";
            self.infront            = YES;
            self.divider            = 100;
        } else if ([alpha isEqualToString:@"EUR"]){
            self.currencyCode       = @"0978";
            self.currencySymbol     = @"€";
            self.maxFractionDigits  = 2;
            self.minFractionDigits  = 2;
            self.currencyAlpha      = @"EUR";
            self.groupingSeparator  = @".";
            self.decimalSeparator   = @",";
            self.infront            = NO;
            self.divider            = 100;
        } else if ([alpha isEqualToString:@"ISK"]){
            self.currencyCode       = @"0352";
            self.currencySymbol     = @"Kr";
            self.maxFractionDigits  = 0;
            self.minFractionDigits  = 0;
            self.currencyAlpha      = @"ISK";
            self.groupingSeparator  = @".";
            self.decimalSeparator   = @",";
            self.infront            = NO;
            self.divider            = 1;
        }
    }
                    
    return self;
}

- (Currency*) initWithCode:(NSString*)code{
    if (self = [super init]){
        if ([code isEqualToString:@"0826"] || [code isEqualToString:@"826"]){
            return [[Currency alloc] initWithAlpha:@"GBP"];
        } else if ([code isEqualToString:@"0840"] || [code isEqualToString:@"840"]){
            return [[Currency alloc] initWithAlpha:@"USD"];
        } else if ([code isEqualToString:@"0978"] || [code isEqualToString:@"978"]){
            return [[Currency alloc] initWithAlpha:@"EUR"];
        } else if ([code isEqualToString:@"0352"] || [code isEqualToString:@"352"]){
            return [[Currency alloc] initWithAlpha:@"ISK"];
        }
    }
    
    return self;
}

@end
