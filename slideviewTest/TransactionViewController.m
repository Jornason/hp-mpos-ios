//
//  TransactionViewController.m
//  headstart
//

#import "TransactionViewController.h"
#import "hpHeftService.h"
#import <QuartzCore/QuartzCore.h>

@interface TransactionViewController ()
@property(nonatomic) eTransactionType type;
@end

@implementation TransactionViewController{
    __weak IBOutlet UILabel* statusLabel;
	__weak IBOutlet UIImageView* statusImageLarge;
	__weak IBOutlet UIButton* cancelButton;
    __weak IBOutlet UIImageView *statusImageTop;
    __weak IBOutlet UIImageView *statusImageMiddle;
    __weak IBOutlet UIImageView *statusImageBottom;
}

@synthesize type;

NSString* const kCardReader = @"ped.png";
NSString* const kBank = @"bank.png";
NSString* const kMobile = @"mobile.png";
NSString* const kCard = @"card2.png";

NSString* sufix[eTransactionNum] = {@"dsc", @"sale", @"sale", @"init", @"init", @"init"};
const int imagesCount[eTransactionNum] = {4, 2, 2, 4, 4, 4};

+ (id)transactionWithType:(eTransactionType)type storyboard:(UIStoryboard*)storyboard{
	TransactionViewController* result = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass(self)];
	result.type = type;
	return result;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    switch (self.type) {
        case eTransactionRefund:
        case eTransactionSale:
            [self insertCard];
            break;
        case eTransactionVoid:
            [self connectTo:kBank with:kCard];
            break;
        case eTransactionFinInit:
            [self connectTo:kBank with:kCardReader];
            break;
        case eTransactionGetLog:
            [self connectTo:kMobile with:kCardReader];
            break;
        default:
            [self insertCard];
            break;
    }

}

- (void)setStatusMessage:(NSString*)message andStatusCode:(int)statusCode{
	statusLabel.text = message;
    
    switch (self.type) {
        case eTransactionRefund:
        case eTransactionSale:
            switch (statusCode) {
                case EFT_PP_STATUS_WAITING_HOST_CONNECT:
                    [self connectTo:kBank with:kCard];
                    break;
                case EFT_PP_STATUS_WAITING_CARD_REMOVAL:
                case EFT_PP_STATUS_WAITING_CARD:
                    [self insertCard];
                    break;
                case EFT_PP_STATUS_PIN_INPUT:
                    [self enterPin];
                    break;
                case EFT_PP_STATUS_PIN_INPUT_COMPLETED:
                    [self pinComplete];
                    break;
                case EFT_PP_STATUS_CARD_INSERTED:
                    [self cardDetected];
                default:
                    break;
            }
            break;
            
        case eTransactionVoid:
            break;
        case eTransactionFinInit:
            break;
        case eTransactionGetLog:
            break;
        default:
            break;
    }

}

- (void)allowCancel:(BOOL)fAllowed{
	cancelButton.enabled = fAllowed;
    if (fAllowed) {
        cancelButton.backgroundColor = [UIColor redColor];
    }
    else{
        cancelButton.backgroundColor = [UIColor darkGrayColor];
    }
}

- (void)connectTo:(NSString*)device1 with:(NSString*)device2{
    
    [self clearImages];
    statusImageBottom.image = [UIImage imageNamed:device1];
    statusImageTop.contentMode = UIViewContentModeScaleAspectFit;
    statusImageTop.image = [UIImage imageNamed:device2];
    statusImageMiddle.contentMode = UIViewContentModeCenter;
    statusImageMiddle.image = [UIImage imageNamed:@"arrowsSmall.png"];
    
    if ([statusImageMiddle.layer animationForKey:@"SpinAnimation"] == nil) {
        CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithFloat:0.0f];
        animation.toValue = [NSNumber numberWithFloat: -2*M_PI];
        animation.duration = 2.0f;
        animation.repeatCount = INFINITY;
        [statusImageMiddle.layer addAnimation:animation forKey:@"SpinAnimation"];
    }
    
}

- (void)insertCard{
    
    [self clearImages];
    NSMutableArray* images = [NSMutableArray array];
	NSString* path = [NSString stringWithFormat:@"transaction.%@.", sufix[type]];
	for(int i = 0; i < imagesCount[type]; ++i){
		UIImage* image = [UIImage imageNamed:[path stringByAppendingFormat:@"%d.png",i]];
		[images addObject:image];
	}
    
	statusImageLarge.animationImages = images;
	statusImageLarge.animationDuration = 1;
	[statusImageLarge startAnimating];
}

- (void)cardDetected{
    [self clearImages];
    statusImageLarge.image = [UIImage imageNamed:@"transaction.sale.1.png"];
}

- (void)pinComplete{
    [self clearImages];
    statusImageMiddle.image = [UIImage imageNamed:@"pin_item.3.png"];
}

- (void)enterPin{
    
    [self clearImages];
    NSMutableArray* images = [NSMutableArray array];
	NSString* path = @"pin_item.";
	for(int i = 0; i < 4; ++i){
		UIImage* image = [UIImage imageNamed:[path stringByAppendingFormat:@"%d.png",i]];
		[images addObject:image];
	}
	statusImageMiddle.animationImages = images;
	statusImageMiddle.animationDuration = 2;
	[statusImageMiddle startAnimating];
    
}
- (void)clearImages{
    [statusImageMiddle.layer removeAnimationForKey:@"SpinAnimation"];
    [statusImageLarge stopAnimating];
    [statusImageTop stopAnimating];
    [statusImageMiddle stopAnimating];
    [statusImageBottom stopAnimating];
    statusImageLarge.image = nil;
    statusImageTop.image = nil;
    statusImageMiddle.image = nil;
    statusImageBottom.image = nil;
}

#pragma mark IBAction

- (IBAction)cancel{
    hpHeftService* sharedHeftService =[hpHeftService sharedHeftService];
    if (sharedHeftService.heftClient != nil)
    {
        [[sharedHeftService heftClient] cancel];
    }
    else
    {
        [self dismissViewController:self];
    }
}


- (void)addFadeTransition{
	CATransition* transition = [CATransition animation];
	transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
}

- (void)showViewController:(UIViewController*)viewController{
	[self addFadeTransition];
    UIView* topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
	[topView addSubview:viewController.view];
}

- (void)dismissViewController:(UIViewController*)viewController{
	[self addFadeTransition];
	[viewController.view removeFromSuperview];
}



@end
