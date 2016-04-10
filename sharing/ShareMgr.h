//
//  ShareMgr.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/22/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHKeychainItemWrapper.h"
#import "NtwIntf.h"
#import "MessageTranslator.h"
#import "MessageDecoder.h"
#include "Consts.h"


@interface ShareMgr : NSThread<UIAlertViewDelegate>
{
    NSCondition *dataToSend;
    NSData *pMsgsToSend[BUFFER_BOUND];
    NSURL *pImgsToSend[BUFFER_BOUND];
    bool upOrDown[BUFFER_BOUND];
    int sendIndx;
    int insrtIndx;
    int picIndx;
    int picInsrtIndx;
    int waitTime;
}

@property (nonatomic) long long share_id;
@property (nonatomic, retain) NSString *friendList;
@property (nonatomic, retain) SHKeychainItemWrapper *kchain;
@property (nonatomic, retain) NtwIntf *pNtwIntf;
@property  (nonatomic, retain) id pTransl;
@property (nonatomic, retain) id pDecoder;


-(void) getIdIfRequired;
-(void) storedTrndIdInCloud;
-(void) updateFriendList;
-(void) storeDeviceToken:(NSString *)token;
-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len;
-(void) putPicInQ :(NSURL *)pPicToSend;
- (instancetype)init;
-(void) shareItem:(NSString *) list listName: (NSString *) name;
-(void) archiveItem:(NSString *) item itemName: (NSString *) name;

-(void) sharePicture:(NSURL *)picUrl;
-(void) getItems;

@end
