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
#include <sys/time.h>

@protocol ShareMgrDelegate <NSObject>

-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;
-(void) storeThumbNailImage:(NSURL *)picUrl;
-(void) setShareId : (long long) shareId;

@optional
-(void) updateEasyMainLstVwCntrl;

@end

@interface ShareMgr : NSThread<UIAlertViewDelegate>
{
    
    NSCondition *dataToSend;
    NSData *pGetIdReq;
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
    struct timeval nextIdReqTime;
     long tdelta;

}

@property (nonatomic) long long share_id;
@property (nonatomic, retain) NSString *friendList;
@property (nonatomic, retain) SHKeychainItemWrapper *kchain;
@property (nonatomic, retain) NtwIntf *pNtwIntf;
@property  (nonatomic, retain) id pTransl;
@property (nonatomic, retain) id pDecoder;
@property (nonatomic) bool appActive;
@property (strong, nonatomic) NSOperationQueue *ntwQ;

@property (nonatomic, weak) id<ShareMgrDelegate> shrMgrDelegate;

-(void) getIdIfRequired;
-(void) storedTrndIdInCloud;
-(void) updateFriendList;
-(void) storeDeviceToken:(NSString *)token;
-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len;
-(void) putPicInQ :(NSURL *)pPicToSend metaStr:(NSString *) picMetaStr;
- (instancetype)init;
-(void) shareItem:(NSString *) list listName: (NSString *) name shrId:(long long) shareId;
-(void) shareTemplItem:(NSString *) list listName: (NSString *) name shrId:(long long) shareId;
-(void) archiveItem:(NSString *) item itemName: (NSString *) name;

-(void) sharePicture:(NSURL *)picUrl metaStr:(NSString *)picMetaStr shrId:(long long) share_id;
-(void) getItems;
-(void) getItems:(bool) upd;
-(void ) setPicDetails:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName picLen:(long long) len;
-(void) storePicData:(NSData *)picData;
-(void ) mainProcessLoop:(bool) bNtwThread;
-(void) processItems;

@end
