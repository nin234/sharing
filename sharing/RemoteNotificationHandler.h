//
//  RemoteNotificationHandler.h
//  sharing
//
//  Created by Ninan Thomas on 3/19/18.
//  Copyright © 2018 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"
#import "ShareMgr.h"

@interface RemoteNotificationHandler : NSObject

@property (nonatomic, retain) ShareMgr *pShrMgr;

-(void) didRegisterForRemoteNotification:(NSData *)deviceToken;
-(void) registerForRemoteNotifications;

@end
