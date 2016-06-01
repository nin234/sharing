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

@protocol ShareMgrDelegate <NSObject>

-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;

@end

@interface ShareMgr : NSThread<UIAlertViewDelegate>
{
    
    NSCondition *dataToSend;
    NSData *pMsgsToSend[BUFFER_BOUND];
    NSURL *pImgsToSend[BUFFER_BOUND];
    NSString *pImgsMetaData[BUFFER_BOUND];
    bool upOrDown[BUFFER_BOUND];
    int sendIndx;
    int insrtIndx;
    int picIndx;
    int picInsrtIndx;
    int waitTime;
    NSURL *picSaveUrl;
    long long picLen;
    long long picSoFar;
    NSFileHandle *pFilHdl;

}

@property (nonatomic) long long share_id;
@property (nonatomic, retain) NSString *friendList;
@property (nonatomic, retain) SHKeychainItemWrapper *kchain;
@property (nonatomic, retain) NtwIntf *pNtwIntf;
@property  (nonatomic, retain) id pTransl;
@property (nonatomic, retain) id pDecoder;

@property (nonatomic, weak) id<ShareMgrDelegate> shrMgrDelegate;

-(void) getIdIfRequired;
-(void) storedTrndIdInCloud;
-(void) updateFriendList;
-(void) storeDeviceToken:(NSString *)token;
-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len;
-(void) putPicInQ :(NSURL *)pPicToSend metaStr:(NSString *) picMetaStr;
- (instancetype)init;
-(void) shareItem:(NSString *) list listName: (NSString *) name;
-(void) archiveItem:(NSString *) item itemName: (NSString *) name;

-(void) sharePicture:(NSURL *)picUrl metaStr:(NSString *)picMetaStr;
-(void) getItems;
-(void ) setPicDetails:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName picLen:(long long) len;
-(void) storePicData:(NSData *)picData;


@end
