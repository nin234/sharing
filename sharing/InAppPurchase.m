//
//  InAppPurchase.m
//  Shopper
//
//  Created by Ninan Thomas on 2/28/15.
//
//

#import "InAppPurchase.h"


#define YES_TO_PAY 1

@implementation InAppPurchase

@synthesize delegate;
@synthesize productId;

-(void) stop
{
    [productsRequest cancel];
    return;
}

-(void) showTransactionAsInProgress:(SKPaymentTransaction *) transaction deferred: (BOOL) value
{
 
    return;
}

-(void) failedTransaction:(SKPaymentTransaction *) transaction
{
     [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    bIgnoreAlertVwClck = true;
    NSLog(@"Transaction failed %@", [transaction.error localizedDescription]);
    UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Upgrade failed" message:[transaction.error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [pAvw show];

    return;
}

-(void) completeTransaction:(SKPaymentTransaction *) transaction
{

    NSLog(@"Purchased  %@ %@", transaction.originalTransaction.transactionIdentifier, transaction.payment.productIdentifier);
    if ([transaction.payment.productIdentifier isEqualToString:productId])
    {
        [delegate setPurchsd:transaction.transactionIdentifier];
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    return;
}

-(void) restoreTransaction:(SKPaymentTransaction *) transaction
{
    NSLog(@"Restored the transaction %@ %@", transaction.originalTransaction.transactionIdentifier, transaction.payment.productIdentifier);
    if ([transaction.payment.productIdentifier isEqualToString:productId])
    {
        [delegate setPurchsd:transaction.transactionIdentifier];
        bIgnoreAlertVwClck = true;
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Restored feature to add unlimited number of items" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
        [pAvw show];

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
                NSLog(@"Unexpected transaction state %@", @(transaction.transactionState));
                break;
        }
    }
    return;
}
-(InAppPurchase *) init
{
    self = [super init];
    NSSet * productIdentifiers = [NSSet setWithObjects:
                                  productId, nil];
    productsRequest = [[SKProductsRequest alloc]
                                          initWithProductIdentifiers:productIdentifiers];
    productsRequest.delegate = self;
    
    bIgnoreAlertVwClck = false;
    return self;
    
}

-(void) start :(bool) purchase
{
    bPurchase = purchase;
    [productsRequest start];   
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (bIgnoreAlertVwClck)
    {
        NSLog(@"Ignoring  alertview click");
        bIgnoreAlertVwClck = false;
        return;
    }
    
    NSLog(@"Clicked button at index %ld", (long)buttonIndex);
    switch (buttonIndex)
    {
        case YES_TO_PAY:
        {
            SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
            payment.quantity = 1;
            if (bPurchase)
            {
                NSLog(@"Purchasing unlock");
                [[SKPaymentQueue defaultQueue] addPayment:payment];
            }
            else
            {
                 NSLog(@"Restoring unlock");
                [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
            }
        }
        break;
            
        default:
            NSLog(@"Customer refused to pay for upgrade");
        break;
    }
    return;
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
        NSString* messageStr;
        if (bPurchase)
            messageStr =[NSString stringWithFormat:@"Purchase %@", result.localizedDescription];
        else
            messageStr = [NSString stringWithFormat:@"Restore %@", result.localizedDescription];
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:result.localizedTitle message:[messageStr stringByAppendingFormat:@" for %@", formattedString] delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        
        [pAvw show];
    }
    
    for (NSString *invalid in response.invalidProductIdentifiers)
    {
        NSLog(@"Invalid product identifiers %@", invalid);
    }
    NSLog(@"Cancelling products request");
   
    return;
}



@end
