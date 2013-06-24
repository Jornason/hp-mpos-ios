//
//  hpUtils.m
//  mPOS
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

#import "HpUtils.h"

@implementation HpUtils

+(NSString*)formatAmount:(NSString*)amount forCurrency:(NSString*)currency
{
    NSDictionary* currencySymbol = @{@"GBP":@"₤", @"USD":@"$", @"EUR":@"€", @"ISK":@"Kr"};
    NSMutableString* amountString = [NSMutableString stringWithString:@""];
    if (!(amount) || !(currency))
    {
        [amountString setString:@"0"];
        return amountString;
    }
    NSString* symbol = [currencySymbol objectForKey:currency];
    if (symbol)
    {
        amountString = [NSMutableString stringWithFormat:@"%@0.00 ", symbol];
        if (![amount isEqual:@"0"])
        {
            NSNumberFormatter* formatter = [[NSNumberFormatter alloc]init];
            [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [formatter setPaddingPosition:NSNumberFormatterPadAfterPrefix];
            [formatter setCurrencySymbol:@""];
            [formatter setMaximumFractionDigits:2];
            [formatter setMinimumFractionDigits:2];
            [formatter setUsesGroupingSeparator:YES];
            [formatter setCurrencyGroupingSeparator:@","];
            [formatter setCurrencyDecimalSeparator:@"."];

            NSNumber* amountNumber = [NSNumber numberWithDouble:[amount doubleValue]/100];
            NSString* formatNumber = [formatter stringFromNumber:amountNumber];
            amountString = [NSMutableString stringWithFormat:@"%@%@", symbol, formatNumber];
        }
    }
    else{
        [amountString setString:amount];
    }
    return amountString;
}

+(NSString*)currencyAlphafromISO:(NSString*)currencyIso{
    NSDictionary* currencySymbol = @{@"826":@"GBP", @"840":@"USD", @"978":@"EUR", @"357":@"ISK"};
    return [currencySymbol objectForKey:currencyIso];
}

@end
