//
//  TransactionViewController.h
//  headstart
//

#import "hpAppDelegate.h"

typedef enum{
	eTransactionDiscovery
	, eTransactionSale
	, eTransactionRefund
	, eTransactionVoid
	, eTransactionFinInit
	, eTransactionGetLog
	, eTransactionNum
} eTransactionType;

@interface TransactionViewController : UIViewController
- (IBAction)cancel;

+ (id)transactionWithType:(eTransactionType)type storyboard:(UIStoryboard*)storyboard;
- (void)showViewController:(UIViewController*)viewController;
- (void)dismissViewController:(UIViewController*)viewController;
- (void)setStatusMessage:(NSString*)message andStatusCode:(int)statusCode;
- (void)allowCancel:(BOOL)fAllowed;

@end
