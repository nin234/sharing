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

@interface AppShrUtil : NSObject

@property bool purchased;
@property (nonatomic, retain) ShareMgr *pShrMgr;
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain)  UITabBarController  *tabBarController;

-(void) setPurchsdTokens:(NSString *)trid;
-(void) registerForRemoteNotifications;
-(void) didRegisterForRemoteNotification:(NSData *)deviceToken;
-(void) showShareView;



@end
