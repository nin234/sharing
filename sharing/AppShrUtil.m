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
@synthesize window;
@synthesize tabBarController;
@synthesize navViewController;
@synthesize selFrndCntrl;

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
        NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
        BOOL purch = [kvlocal boolForKey:@"Purchased"];
        if (purch == YES)
            purchased = true;

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

-(void) showShareView
{
    
    [self.window setRootViewController:self.tabBarController];
    return;
}

-(void) showTemplShareView
{
    
    [self.window setRootViewController:self.tabBarController];
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

-(void) initializeTabBarCntrl:(UINavigationController *)mainVwNavCntrl ContactsDelegate:(id)delegate
{
   tabBarController = [[UITabBarController alloc] init];
    HomeViewController *homeCntrl = [[HomeViewController alloc] init];
    [homeCntrl setDelegate:self];
    UIImage *imageHome = [UIImage imageNamed:@"802-dog-house@2x.png"];
    UIImage *imageHomeSel = [UIImage imageNamed:@"895-dog-house-selected@2x.png"];
    homeCntrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:imageHome selectedImage:imageHomeSel];
    selFrndCntrl = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    selFrndCntrl.pShrMgr = pShrMgr;
    selFrndCntrl.delegate = delegate;
    selFrndCntrl.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *selFrndNavCntrl = [[UINavigationController alloc] initWithRootViewController:selFrndCntrl];
    
    NSArray* controllers = [NSArray arrayWithObjects:mainVwNavCntrl, selFrndNavCntrl, homeCntrl, nil];
    
    tabBarController.viewControllers = controllers;
    return;
}

-(void) switchRootView
{
    [self.window setRootViewController:self.navViewController];
    tabBarController.selectedIndex = 0;
}


@end
