//
//  AppShrUtil.m
//  sharing
//
//  Created by Ninan Thomas on 3/14/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import "AppShrUtil.h"

@implementation AppShrUtil

@synthesize purchased;
@synthesize pShrMgr;

-(void) setPurchsdTokens:(NSString *) trid
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"Purchased"];
    [kvlocal setObject:trid forKey:@"TransactionId"];
    
}

-(instancetype) init
{
    self = [super init];
    if (self)
    {
        purchased = false;
    }
    return nil;
}

-(void) registerForRemoteNotifications
{
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    // Register for remote notifications.
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    return;
}

-(void) didRegisterForRemoteNotification:(NSData *)deviceToken
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSData *tokenNow = [kvlocal dataForKey:@"NotToken"];
    NSLog(@"Did register for remote notification with token %@ tokenNow=%@", deviceToken, tokenNow);
    bool bChange = false;
    if (tokenNow == nil)
    {
        [kvlocal setObject:deviceToken forKey:@"NotToken"];
        bChange = true;
    }
    else
    {
        if (![deviceToken isEqualToData:tokenNow])
        {
            [kvlocal setObject:deviceToken forKey:@"NotToken"];
            bChange = true;
        }
    }
    
    if (bChange && purchased)
    {
        NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        
        dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"device token %@", dToken);
        [pShrMgr storeDeviceToken:dToken];
    }

    return;
}


@end
