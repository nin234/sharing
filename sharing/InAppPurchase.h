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

@protocol InAppPurchaseDelegate <NSObject>

@required
-(void) setPurchsd:(NSString *)trid;

@end

@interface InAppPurchase : NSObject<UIAlertViewDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>
{
    SKProduct *product;
    SKProductsRequest *productsRequest;
    bool bIgnoreAlertVwClck;
    bool bPurchase;
}

-(void) start:(bool) purchase;
@property(nonatomic, weak) id<InAppPurchaseDelegate> delegate;
@property (nonatomic, strong) NSString *productId;
-(void) stop;

@end
