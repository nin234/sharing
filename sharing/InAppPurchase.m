//
//  InAppPurchase.m
//  Shopper
//
//  Created by Ninan Thomas on 2/28/15.
//
//

#import "InAppPurchase.h"
#include <sys/time.h>
#import "SHKeychainItemWrapper.h"
#import "Consts.h"

#define YES_TO_PAY 1

@implementation InAppPurchase

@synthesize appId;

-(void) stop
{
    [productsRequest cancel];
    return;
}

-(bool) canContinue:(UIViewController *) vwCntrl
{
    if (!bInited)
    {
        return true;
    }
    
    if (bPurchased || bPurchasing)
    {
        return true;
    }
   
    if (product == nil)
    {
        return true;
    }
    struct timeval now;
    gettimeofday(&now, NULL);
   if ((now.tv_sec - firstUseTime) < delta)
    {
        if (now.tv_sec > 1619706125)
        {
            return true;
        }
    }
    NSString *errString = @"Purchase to continue using Nshare apps. All our Apps EasyGrocList, OpenHouses, nsharelist and AutoSpree can be used with one purchase";
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Purchase"
                               message:errString
                               preferredStyle:UIAlertControllerStyleAlert];
 
    UIAlertAction* buyAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
   handler:^(UIAlertAction * action) {
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.quantity = 1;
        NSLog(@"Purchasing subscription");
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        bPurchasing = true;
    }];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
   handler:^(UIAlertAction * action) {
    }];
 
    [alert addAction:buyAction];
    [alert addAction:cancelAction];
    [vwCntrl presentViewController:alert animated:YES completion:nil];
    return false;
}

-(void) showTransactionAsInProgress:(SKPaymentTransaction *) transaction deferred: (BOOL) value
{
 
    return;
}

-(void) failedTransaction:(SKPaymentTransaction *) transaction
{
     [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    bIgnoreAlertVwClck = true;
    bPurchasing = false;
    NSLog(@"Transaction failed %@", [transaction.error localizedDescription]);
    
    return;
}

-(void) completeTransaction:(SKPaymentTransaction *) transaction
{

    NSLog(@"Purchased  %@ %@", transaction.originalTransaction.transactionIdentifier, transaction.payment.productIdentifier);
    if ([transaction.payment.productIdentifier isEqualToString:productId])
    {
        [self setPurchased];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    return;
}

-(void) restoreTransaction:(SKPaymentTransaction *) transaction
{
    NSLog(@"Restored the transaction %@ %@", transaction.originalTransaction.transactionIdentifier, transaction.payment.productIdentifier);
    if ([transaction.payment.productIdentifier isEqualToString:productId])
    {
        [self setPurchased];
        bIgnoreAlertVwClck = true;
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    return;
}

- (void)paymentQueue:(SKPaymentQueue *)queue
 updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        NSLog(@"Received transaction state %@", @(transaction.transactionState));
        switch (transaction.transactionState)
        {
                // Call the appropriate custom method for the transaction state.
            case SKPaymentTransactionStatePurchasing:
                [self showTransactionAsInProgress:transaction deferred:NO];
                break;
            case SKPaymentTransactionStateDeferred:
                [self showTransactionAsInProgress:transaction deferred:YES];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
            default:
                // For debugging
                bPurchasing = false;
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
    return;
}

-(NSString *) getProductId:(int) appId
{
    switch (appId) {
        case EASYGROCLIST_ID:
        {
            productId = @"com.rekhaninan.easygroclist_yearly";
            delta = 3600*24*30;
            //delta = 20;
            return productId;
        }
        break;
            
        case NSHARELIST_ID:
        {
            productId = @"com.rekhaninan.nsharelist_yearly";
            delta = 3600*24*30;
           // delta = 100;
            return productId;
        }
        break;
            
        case OPENHOUSES_ID:
        {
            productId = @"com.rekhaninan.openhouses_yearly";
            delta = 3600*24*7;
            //delta = 100;
            return productId;
        }
        break;
            
        case AUTOSPREE_ID:
        {
            productId = @"com.rekhaninan.autospree_yearly";
           delta = 3600*24*7;
           // delta = 100;
            return productId;
        }
        break;
            
        default:
            break;
    }
    
    NSLog(@"Cannot find productId for appId=%d", appId);
    
    return @"Invalid app";
}

-(InAppPurchase *) init
{
    self = [super init];
    bInited = false;
    bRestore = false;
    productId = [self getProductId:appId];
    
    bPurchasing = false;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSNumber *firstUse = [kvlocal objectForKey:@"FirstUseTime"];
    if (firstUse == nil)
    {
        struct timeval now;
        gettimeofday(&now, NULL);
        [kvlocal setObject:[NSNumber numberWithLongLong:now.tv_sec] forKey:@"FirstUseTime"];
        firstUseTime = now.tv_sec;
        bRestore = true;
        return self;
        
    }
    else
    {
        firstUseTime = [firstUse longLongValue];
    }
    
    struct timeval now;
    gettimeofday(&now, NULL);
    NSLog(@"Time now=%ld", now.tv_sec);
   if ((now.tv_sec - firstUseTime) < delta - 1800) //if ((now.tv_sec - firstUseTime) < delta - 50)// (test)
    {
        if (now.tv_sec > 1619706125)
        {
            return self;
        }
    }
    
    NSSet * productIdentifiers = [NSSet setWithObjects:
                                  productId, nil];
    productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    
    bIgnoreAlertVwClck = false;
    
    SHKeychainItemWrapper *kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    
    NSString *purchased = [kchain objectForKey:(__bridge id)kSecAttrLabel];
    bPurchased = false;
    if (purchased == nil)
    {
        bPurchased = false;
    }
    else if ([purchased isEqualToString:@"YES"])
    {
        bPurchased = true;
        NSLog(@"App is subscribed");
    }
        
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [self start:true];
    bInited = true;
    return self;
    
}

-(void) setPurchased
{
    bPurchasing = false;
    
    SHKeychainItemWrapper *kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    [kchain setObject:@"YES" forKey:(__bridge id)kSecAttrLabel];
}

-(void) start :(bool) purchase
{
    bPurchase = purchase;
   // bPurchased = false;
    if (!bPurchased)
    {
        NSLog(@"Starting products request");
        [productsRequest start];
    }
//    [productsRequest start];
}



- (void)productsRequest:(SKProductsRequest *)request
     didReceiveResponse:(SKProductsResponse *)response
{
    
    
    for (SKProduct *result in response.products)
    {
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [numberFormatter setLocale:result.priceLocale];
        NSString *formattedString = [numberFormatter stringFromNumber:result.price];
        NSLog(@"Received product response %@ price=%@ identifier=%@ title=%@ description=%@", result, formattedString, result.productIdentifier, result.localizedTitle, result.localizedDescription);
        //assumption here is that there is only one product in the response as we have requested
        //for only one product
        product = result;
        
        
    }
    
    if (bRestore)
    {
        NSLog(@"Restoring completed app purchases");
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
    
    for (NSString *invalid in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product identifiers %@", invalid);
    }
    
   
    return;
}



@end
