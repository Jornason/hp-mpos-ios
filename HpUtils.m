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
#import "Currency.h"

@implementation HpUtils

+(NSString*)formatEFTTimestamp:(NSString*)EFTTimestamp
{
    //Todo: parse date from timestamp in regards of locale
    if (EFTTimestamp != NULL)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *date = [formatter dateFromString:EFTTimestamp];
        [formatter setDateFormat:@"dd/MM/YYYY"];
        NSString* formatedDate = [formatter stringFromDate:date];
        return formatedDate;
    }
    else
    {
<<<<<<< HEAD
        NSDateFormatter *date_formater=[[NSDateFormatter alloc]init];
        [date_formater setDateFormat:@"dd/MM/YYYY"];
        NSString *formatedDate=[date_formater stringFromDate:[NSDate date]];
        
        return formatedDate;
=======
        return @"Not available";
>>>>>>> FETCH_HEAD
    }
}

+(NSString*)formatAmount:(NSString*)amount forCurrency:(NSString*)currencyAlpha
{
    Currency* currency = [[Currency alloc] initWithAlpha:currencyAlpha];
    NSMutableString* amountString = [NSMutableString stringWithString:@""];
    if (!(amount) || !(currencyAlpha))
    {
        [amountString setString:@"0"];
        return amountString;
    }
    NSString* currencySymbol = currency.currencySymbol;
    if (currencySymbol)
    {
        NSNumberFormatter* formatter = [HpUtils currencyFormatter:currency];
        NSNumber* amountNumber = [NSNumber numberWithDouble:[amount doubleValue]/currency.divider];
        NSString* formatNumber = [formatter stringFromNumber:amountNumber];
        if (currency.infront){
            amountString = [NSMutableString stringWithFormat:@"%@%@", currencySymbol, formatNumber];
        } else {
            amountString = [NSMutableString stringWithFormat:@"%@%@", formatNumber, currencySymbol];
        }
    }
    else{
        [amountString setString:amount];
    }
    return amountString;
}

+(NSNumberFormatter*)currencyFormatter:(Currency*)currency{
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc]init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setPaddingPosition:NSNumberFormatterPadAfterPrefix];
    [formatter setCurrencySymbol:@""];
    [formatter setMaximumFractionDigits:currency.maxFractionDigits];
    [formatter setMinimumFractionDigits:currency.minFractionDigits];
    [formatter setUsesGroupingSeparator:YES];
    [formatter setCurrencyGroupingSeparator:currency.groupingSeparator];
    [formatter setCurrencyDecimalSeparator:currency.decimalSeparator];
    return formatter;
}

+(NSString*)currencyAlphafromISO:(NSString*)currencyIso{
    Currency* currency = [[Currency alloc] initWithCode:currencyIso];
    return currency.currencyAlpha;
}

+(NSInteger)formatSendableAmount:(NSInteger)amount withCurrency:(NSString*)currencyAlpha{
    Currency* currency = [[Currency alloc] initWithAlpha:currencyAlpha];
    if (currency.divider != 100){
        return amount*100;
    }
    return amount;
}


//TODO Move this from here
+ (BOOL)matchRegex:(NSString *)regex withString:(NSString *)text
{
    BOOL ret = false;
    if ([text rangeOfString:regex options:NSRegularExpressionSearch].location != NSNotFound)
        ret = true;
    return ret;
}


//TODO Move this from here
+ (UIImage *)getCardSchemeLogo:(NSString*)cardSchemeName
{
    NSString *result = @"credit.png";

    if(([self matchRegex:@"(?i).*ELECTRON.*" withString:cardSchemeName]) || ([self matchRegex:@"(?i).*DEBIT.*" withString:cardSchemeName])) {
        result = @"visa.png";
    } else if (([self matchRegex:@"(?i).*visa.*" withString:cardSchemeName]) || ([self matchRegex:@"(?i).*CREDIT.*" withString:cardSchemeName])) {
        result = @"visa.png";
    } else if ([self matchRegex:@"(?i).*mastercard" withString:cardSchemeName]) {
        result = @"mastercard.png";
    } else if ([self matchRegex:@"(?i).*MAESTRO.*" withString:cardSchemeName]) {
        result = @"maestro.png";
    } else if ([self matchRegex:@"(?i).*AMEX.*" withString:cardSchemeName]) {
        result = @"amex.png";
    } else if ([self matchRegex:@"(?i).*JCB.*" withString:cardSchemeName]) {
        result = @"jcb.png";
    } else if ([self matchRegex:@"(?i).*UNIONPAY.*" withString:cardSchemeName]) {
        result = @"credit.png";
    } else if ([self matchRegex:@"(?i).*DISCOVER.*" withString:cardSchemeName]) {
        result = @"discover.png";
    } else if ([self matchRegex:@"(?i).*DINERS.*" withString:cardSchemeName]) {
        result = @"diners.png";
    }

    return [UIImage imageNamed: result];
}


@end
