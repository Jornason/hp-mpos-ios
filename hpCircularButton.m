//
//  hpCircularButton.m
//  mPOS
//
//  Created by Juan Nuñez on 9/21/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "hpCircularButton.h"
#import <QuartzCore/QuartzCore.h>

@implementation hpCircularButton


- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        self.layer.cornerRadius = self.frame.size.height / 2; // We calculate the border radius as the half of the height to make it circular
        self.clipsToBounds = NO;
        self.layer.borderColor = [[UIColor grayColor] CGColor];
        self.layer.borderWidth = 1;
        self.layer.shouldRasterize = YES;
        //For retina screens:
        self.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        

    }
    return self;
}

@end
