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
#import "ShareItemDBIntf.h"
#include <sys/time.h>

@protocol ShareMgrDelegate <NSObject>

-(NSURL *) getPicUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;
-(void) storeThumbNailImage:(NSURL *)picUrl;
-(void) setShareId : (long long) shareId;
-(void) displayAlert:(NSString *)msg;

@optional
-(void) updateEasyMainLstVwCntrl;
-(NSURL *) getShareUrl:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName;
-(void) scheduleBackGroundTask;
-(void) updateTotalUpload:(long)uploaded;
-(void) startDownLoadProgressVw;
-(void) updateTotalDownLoaded:(long)downloaded;

@end

@interface ShareMgr : NSObject<UIAlertViewDelegate>
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
    int picMetaIndx;
    int picInsrtIndx;
    int waitTime;
    NSURL *picSaveUrl;
    NSURL *picShareUrl;
    long long picLen;
    long long picSoFar;
    NSFileHandle *pFilHdl;
    struct timeval nextIdReqTime;
     long tdelta;
    ShareItemDBIntf *pShareDBIntf;
    NSData *picData;
    long long lastPicRcvdTime;
   
    unsigned long long lastIdSentTime;
    unsigned long long lastRemoteHostSentTime;
    unsigned long long lastTokenUpdateSentTime;
    bool bNtwConnected;
    struct timeval lastNtwActvtyTime;
    bool stop;
    bool shouldStart;
    NSMutableArray *appHostPortArr;
    bool bGetRemoteHostPort;
  
}

@property (nonatomic) long long share_id;
@property (nonatomic, retain) NSString *friendList;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) SHKeychainItemWrapper *kchain;
@property (nonatomic, retain) NtwIntf *pNtwIntf;
@property  (nonatomic, retain) id pTransl;
@property (nonatomic, retain) id pDecoder;

@property (nonatomic) long long maxShareId;

@property  int appId;

@property (nonatomic, weak) id<ShareMgrDelegate> shrMgrDelegate;
@property (nonatomic) bool bSendPic;


@property (nonatomic)  bool bUpdateToken;
@property (nonatomic) NSUInteger uploadPicOffset;

@property (nonatomic)  bool bSendAlert;

@property (nonatomic)  bool bBackGroundMode;

@property (nonatomic, retain) dispatch_queue_t sharingQueue;

@property (nonatomic) UIBackgroundTaskIdentifier bgTaskId;

@property (nonatomic) long nTopUpload;
@property (nonatomic) long nTotalFileSize;

@property (nonatomic) long long nTotalDownLoadSize;
@property (nonatomic) long long nDownLoadedSoFar;

- (void) endBackgroundUpdateTask;
- (void) beginBackgroundUpdateTask;

-(void) resetUploadStats;

@property (nonatomic, retain) NSString * alertMsg;

-(void )updateDeviceTknStatus;

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

-(void ) setPicDetails:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
                picLen:(long long) len picOffset:(int)pSoFar;
-(void) storePicData:(NSData *)picData;
-(void ) mainProcessLoop:(bool) bNtwThread;
-(void) processItems;
-(void) processShouldUploadMsg:(bool) upload;
-(void) setNewToken:(NSString *)token;
-(void) start;
-(void) startBackGroundTask;
-(void) stopBackGroundTask;
-(void) setHostPort:(NSString *) host port:(int) prt;


@end
