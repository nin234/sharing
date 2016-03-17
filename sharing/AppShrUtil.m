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



@end
