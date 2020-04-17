//
//  RemoteNotificationHandler.m
//  sharing
//
//  Created by Ninan Thomas on 3/19/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import "RemoteNotificationHandler.h"

@implementation RemoteNotificationHandler

@synthesize pShrMgr;

-(void) didRegisterForRemoteNotification:(NSData *)deviceToken
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSData *tokenNow = [kvlocal dataForKey:@"NotNToken"];
    NSLog(@"Did register for remote notification with token %@ tokenNow=%@ %s %d", deviceToken, tokenNow, __FILE__, __LINE__);
    bool bChange = false;
    if (tokenNow == nil)
    {
        [kvlocal setObject:deviceToken forKey:@"NotNToken"];
        bChange = true;
    }
    else
    {
        if (![deviceToken isEqualToData:tokenNow] || [kvlocal boolForKey:@"TokenInServ"] == NO)
        {
            [kvlocal setObject:deviceToken forKey:@"NotNToken"];
            bChange = true;
        }
    }
  //  bChange = true;
    
    if (bChange)
    {
        NSString *dToken = [self stringFromDeviceToken:deviceToken];
        //  dToken = [dToken uppercaseString];
        NSLog(@"device token %@", dToken);
        [pShrMgr storeDeviceToken:dToken];
    }
    
    return;
}

- (NSString *)stringFromDeviceToken:(NSData *)deviceToken {
    NSUInteger length = deviceToken.length;
    if (length == 0) {
        return nil;
    }
    const unsigned char *buffer = deviceToken.bytes;
    NSMutableString *hexString  = [NSMutableString stringWithCapacity:(length * 2)];
    for (int i = 0; i < length; ++i) {
        [hexString appendFormat:@"%02x", buffer[i]];
    }
    return [hexString copy];
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
    NSLog(@"Register for remote notification %s %d", __FILE__, __LINE__);
    return;
}

@end
