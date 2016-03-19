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

-(void) setPurchsdTokens:(NSString *)trid;
-(void) registerForRemoteNotifications;
-(void) didRegisterForRemoteNotification:(NSData *)deviceToken;

@property (nonatomic, retain) ShareMgr *pShrMgr;

@end
