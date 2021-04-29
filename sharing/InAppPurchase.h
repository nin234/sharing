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
   
    
    bool bPurchased;
    int delta;
    unsigned long long firstUseTime;
    bool bRestore;
    NSString *productId;
    bool bPurchasing;
}

-(void) start;

@property (nonatomic) int appId;

-(void) stop;
-(bool) canContinue:(UIViewController *) vwCntrl;

-(void) buy;
-(void) restore;

@end
