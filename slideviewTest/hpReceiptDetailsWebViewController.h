//
//  hpReceiptDetailsWebViewController.h
//  mPOS-withSlideView
//
//  Created by Jón Hilmar Gústafsson on 6.5.2013.
//  Copyright (c) 2013 Handpoint ehf. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface hpReceiptDetailsWebViewController : UIViewController
{
    NSString* receiptHtmlString;
}
@property (strong, nonatomic) IBOutlet UIWebView *receiptWebView;
@property (nonatomic) NSString* receiptHtmlString;
@end
