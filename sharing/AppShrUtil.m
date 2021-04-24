//
//  AppShrUtil.m
//  sharing
//
//  Created by Ninan Thomas on 3/14/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import "AppShrUtil.h"


@implementation AppShrUtil


@synthesize pShrMgr = _pShrMgr;
@synthesize window;
@synthesize tabBarController;
@synthesize navViewController;
@synthesize selFrndCntrl;
@synthesize controllersListView;
@synthesize controllersTemplListView;
@synthesize mainViewNavController ;
@synthesize homeCntrl;
@synthesize delegate;
@synthesize shareViewNavController;



-(instancetype) init
{
    self = [super init];
    if (self)
    {
        
        
        
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
    [shareViewNavController pushViewController:albumVwCntrl animated:NO];
    shareViewNavController.navigationBar.topItem.title = title;
    return;
}



-(void) initializeTabBarCntrl:(UINavigationController *)mainShareVwNavCntrl mainNavCntrl:(UINavigationController*) mainVwNavCntrl checkListCntrl:(UINavigationController *)checkListNavCntrl ContactsDelegate:(id)delegate
{
    shareViewNavController = mainShareVwNavCntrl;
    mainViewNavController = mainVwNavCntrl;
   tabBarController = [[UITabBarController alloc] init];
    tabBarController.delegate = self;
    homeCntrl = [[HomeViewController alloc] init];
    [homeCntrl setDelegate:self];
    UIImage *imageHome = [UIImage imageNamed:@"802-dog-house@2x.png"];
    UIImage *imageHomeSel = [UIImage imageNamed:@"895-dog-house-selected@2x.png"];
    
  //  UIImage *imageHome = [UIImage imageNamed:@"ic_event_note_white_36pt"];
   // UIImage *imageHomeSel = [UIImage imageNamed:@"ic_event_note_white_36pt"];
    
    // UIImage *imageHome = [UIImage imageNamed:@"ic_list_white_36pt"];
   //  UIImage *imageHomeSel = [UIImage imageNamed:@"ic_list_white_36pt"];
    homeCntrl.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Home" image:imageHome selectedImage:imageHomeSel];
    selFrndCntrl = [[ContactsViewController alloc] initWithNibName:nil bundle:nil];
    selFrndCntrl.pShrMgr = _pShrMgr;
    selFrndCntrl.delegate = delegate;
    
    selFrndCntrl.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
    UINavigationController *selFrndNavCntrl = [[UINavigationController alloc] initWithRootViewController:selFrndCntrl];
    
    controllersListView = [NSArray arrayWithObjects:mainShareVwNavCntrl, selFrndNavCntrl, checkListNavCntrl, mainVwNavCntrl, nil];
   
    tabBarController.viewControllers = controllersListView;
    selFrndCntrl.tabBarController = tabBarController;
     self.tabBarController.selectedIndex = 3;
   [self.window setRootViewController:self.tabBarController];
    return;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   selFrndCntrl.eViewCntrlMode = eModeContactsMgmt;
  if (tabBarController.selectedIndex == 0)
  {
      [delegate refreshShareView];
  }
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
   
   // [self.window setRootViewController:self.navViewController];
    
}


@end
