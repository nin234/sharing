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
@synthesize pShrMgr = _pShrMgr;
@synthesize window;
@synthesize tabBarController;
@synthesize navViewController;
@synthesize selFrndCntrl;
@synthesize controllersListView;
@synthesize controllersTemplListView;
@synthesize mainViewNavController ;
@synthesize homeCntrl;

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
        pNotificationHdlr = [[RemoteNotificationHandler alloc] init];
        return self;
    }
    return nil;
}

-(void) registerForRemoteNotifications
{
    [pNotificationHdlr registerForRemoteNotifications];
    
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
    [pNotificationHdlr didRegisterForRemoteNotification:deviceToken];
    return;
}

-(void) setPShrMgr:(ShareMgr *)pShrMgr
{
    if (!pNotificationHdlr)
    {
        pNotificationHdlr = [[RemoteNotificationHandler alloc] init];
    }
    pNotificationHdlr.pShrMgr = pShrMgr;
    _pShrMgr = pShrMgr;
}

-(void) pushAlbumContentsViewController:(id) albumVwCntrl title:(NSString *)title
{
    [mainViewNavController pushViewController:albumVwCntrl animated:NO];
    mainViewNavController.navigationBar.topItem.title = title;
    return;
}



-(void) initializeTabBarCntrl:(UINavigationController *)mainVwNavCntrl templNavCntrl:(UINavigationController*) mainTemplVwNavCntrl ContactsDelegate:(id)delegate
{
    mainViewNavController = mainVwNavCntrl;
   tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    homeCntrl = [[HomeViewController alloc] init];
    [homeCntrl setDelegate:self];
    UIImage *imageHome = [UIImage imageNamed:@"802-dog-house@2x.png"];
    UIImage *imageHomeSel = [UIImage imageNamed:@"895-dog-house-selected@2x.png"];
    homeCntrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:imageHome selectedImage:imageHomeSel];
    selFrndCntrl = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    selFrndCntrl.pShrMgr = _pShrMgr;
    selFrndCntrl.delegate = delegate;
    
    selFrndCntrl.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *selFrndNavCntrl = [[UINavigationController alloc] initWithRootViewController:selFrndCntrl];
    
    controllersListView = [NSArray arrayWithObjects:mainVwNavCntrl, selFrndNavCntrl, homeCntrl, nil];
    controllersTemplListView = [NSArray arrayWithObjects:mainTemplVwNavCntrl, selFrndNavCntrl, homeCntrl, nil];
    
    tabBarController.viewControllers = controllersListView;
    selFrndCntrl.tabBarController = tabBarController;
    return;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   selFrndCntrl.eViewCntrlMode = eModeContactsMgmt;
    return;
}

-(void) hideTabBar
{
  
}

-(void ) showTabBar
{
  
}

-(void) switchRootView
{
   //return;
   
  self.tabBarController.selectedIndex = 0;
   
    [self.window setRootViewController:self.navViewController];
    
}


@end
