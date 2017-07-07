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
@synthesize controllersListView;
@synthesize controllersTemplListView;

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
        return self;
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
    NSLog(@"Register for remote notification %s %d", __FILE__, __LINE__);
    return;
}

-(void) showShareView
{
    NSLog(@"showShareView setting tabBarController as the root view controller %s %d", __FILE__, __LINE__);
    selFrndCntrl.bTemplShare = false;
    tabBarController.viewControllers = controllersListView;
    [self.window setRootViewController:self.tabBarController];
    return;
}

-(void) showTemplShareView
{
    NSLog(@"showTemplShareView setting tabBarController as the root view controller %s %d", __FILE__, __LINE__);
    selFrndCntrl.bTemplShare = true;
    tabBarController.viewControllers = controllersTemplListView;
    [self.window setRootViewController:self.tabBarController];
    return;
}



-(void) didRegisterForRemoteNotification:(NSData *)deviceToken
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSData *tokenNow = [kvlocal dataForKey:@"NotNToken"];
    NSLog(@"Did register for remote notification with token %@ tokenNow=%@ %s %d", deviceToken, tokenNow, __FILE__, __LINE__);
    bool bChange = true;
    if (tokenNow == nil)
    {
        [kvlocal setObject:deviceToken forKey:@"NotNToken"];
        bChange = true;
    }
    else
    {
        if (![deviceToken isEqualToData:tokenNow])
        {
            [kvlocal setObject:deviceToken forKey:@"NotNToken"];
            bChange = true;
        }
    }
    
    if (bChange)
    {
        NSString *dToken = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        
        dToken = [dToken stringByReplacingOccurrencesOfString:@" " withString:@""];
      //  dToken = [dToken uppercaseString];
        NSLog(@"device token %@", dToken);
        [pShrMgr storeDeviceToken:dToken];
    }

    return;
}

-(void) initializeTabBarCntrl:(UINavigationController *)mainVwNavCntrl templNavCntrl:(UINavigationController*) mainTemplVwNavCntrl ContactsDelegate:(id)delegate
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
    
    controllersListView = [NSArray arrayWithObjects:mainVwNavCntrl, selFrndNavCntrl, homeCntrl, nil];
    controllersTemplListView = [NSArray arrayWithObjects:mainTemplVwNavCntrl, selFrndNavCntrl, homeCntrl, nil];
    
    tabBarController.viewControllers = controllersListView;
    selFrndCntrl.tabBarController = tabBarController;
    return;
}

-(void) switchRootView
{
    [self.window setRootViewController:self.navViewController];
    tabBarController.selectedIndex = 0;
}


@end
