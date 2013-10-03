//
//  hpButton.m
//  mPOS
//
//  Created by Juan Nuñez on 9/20/13.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import "hpButton.h"

@implementation hpButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)viewDidLoad
{

}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder: decoder])
    {
        UIFont* defaultFont = [UIFont fontWithName:@"RobotoLight" size:self.titleLabel.font.pointSize];
        //self.titleLabel.font = defaultFont;
        [self.titleLabel setFont:defaultFont];
    }
    return self;
}

@end
