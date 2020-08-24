//
//  AppShrUtil.h
//  sharing
//
//  Created by Ninan Thomas on 3/14/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "ShareMgr.h"
#import "HomeViewController.h"
#import "ContactsViewController.h"
#import "RemoteNotificationHandler.h"

@protocol AppShrUtilDelegate <NSObject>

-(void) refreshShareView;

@end

@interface AppShrUtil : NSObject<HomeViewControllerDelegate, UITabBarControllerDelegate>
{
    RemoteNotificationHandler *pNotificationHdlr;
}

@property bool purchased;
@property (nonatomic, retain) ShareMgr *pShrMgr;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain)  UITabBarController  *tabBarController;
@property (nonatomic, retain) IBOutlet UINavigationController *navViewController;
@property (nonatomic, retain) ContactsViewController  *selFrndCntrl;
@property (nonatomic, retain) NSArray* controllersListView;
@property (nonatomic, retain) NSArray* controllersTemplListView;
@property (nonatomic, retain) UINavigationController *mainViewNavController;
@property (nonatomic, retain)  HomeViewController *homeCntrl;

@property (nonatomic, weak) id<AppShrUtilDelegate> delegate;

-(void) setPurchsdTokens:(NSString *)trid;
-(void) registerForRemoteNotifications;
-(void) didRegisterForRemoteNotification:(NSData *)deviceToken;
-(void) showShareView;
-(void) showTemplShareView;
-(void) initializeTabBarCntrl:(UINavigationController *)mainShareVwNavCntrl mainNavCntrl:(UINavigationController*) mainVwNavCntrl checkListCntrl:(UINavigationController *)checkListNavCntrl  ContactsDelegate:(id)delegate;
-(void) pushAlbumContentsViewController:(id) albumVwCntrl title:(NSString *) title;

-(void) hideTabBar;

@end
