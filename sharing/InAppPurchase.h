//
//  InAppPurchase.h
//  Shopper
//
//  Created by Ninan Thomas on 2/28/15.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <UIKit/UIKit.h>


@interface InAppPurchase : NSObject<UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *product;
    SKProductsRequest *productsRequest;
    bool bIgnoreAlertVwClck;
    bool bPurchase;
    
    bool bPurchased;
    int delta;
    unsigned long long firstUseTime;
    bool bRestore;
    NSString *productId;
    bool bInited;
    bool bPurchasing;
}

-(void) start:(bool) purchase;

@property (nonatomic) int appId;

-(void) stop;
-(bool) canContinue:(UIViewController *) vwCntrl;

@end
