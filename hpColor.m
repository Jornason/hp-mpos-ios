//
//  hpColor.m
//  mPOS
//
//  Created by Haukur Páll on 9/23/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "hpColor.h"

@implementation UIColor (Extensions)

+ (UIColor *)hpOrange {
    return [UIColor colorWithRed:255/255.0f
                           green:117/255.0f
                            blue:40/255.0f
                           alpha:1.0f];
}

+ (UIColor *)hpRed {
    return [UIColor colorWithRed:227/255.0f
                           green:59/255.0f
                            blue:48/255.0f
                           alpha:1.0f];
}

+ (UIColor *)hpBlack {
    return [UIColor colorWithRed:43/255.0f
                           green:46/255.0f
                            blue:38/255.0f
                           alpha:1.0f];
}

+ (UIColor *)hpBlue {
    return [UIColor colorWithRed:81/255.0f
                           green:182/255.0f
                            blue:177/255.0f
                           alpha:1.0f];
}

@end
