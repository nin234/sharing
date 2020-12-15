//
//  ShareMgr.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/22/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "ShareMgr.h"
#import "ShareItem.h"
#import "PicUrl.h"
#import "PicMetaData.h"
#import <BackgroundTasks/BackgroundTasks.h>


@implementation ShareMgr

@synthesize friendList;
@synthesize share_id;
@synthesize kchain;
@synthesize pNtwIntf;
@synthesize pTransl;
@synthesize pDecoder;
@synthesize shrMgrDelegate;
@synthesize bSendPic;
@synthesize uploadPicOffset;
@synthesize token;
@synthesize bUpdateToken;
@synthesize bSendAlert;
@synthesize alertMsg;
@synthesize sharingQueue;
@synthesize bgTaskId;
@synthesize bBackGroundMode;
@synthesize nTopUpload;
@synthesize nTotalFileSize;
@synthesize nDownLoadedSoFar;
@synthesize nTotalDownLoadSize;

-(void) setNewToken:(NSString *)tkn
{
    tkn = token;
}

-(void) resetUploadStats
{
    nTopUpload = 0;
    nTotalFileSize = 0;
}

-(void) setNTotalDownLoadSize:(long long)nTotDwnldBytes
{
    nTotalDownLoadSize = nTotDwnldBytes;
    NSLog(@"Setting total download size=%lld and starting Progress View", nTotalDownLoadSize);
    nDownLoadedSoFar = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
    [shrMgrDelegate startDownLoadProgressVw];
    });
}


-(void) initializeTokenUpdate
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    BOOL tokenInServ = [kvlocal boolForKey:@"TokenInServ"];
    if (tokenInServ == YES)
    {
        bUpdateToken = false;
    }
    else
    {
        bUpdateToken = true;
    }
    NSData *tokenNow = [kvlocal dataForKey:@"NotNToken"];
    if (tokenNow == nil)
    {
        bUpdateToken = false;
    }
    token = [[tokenNow description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(void )updateDeviceTknStatus
{
    NSLog (@"Updating device token status to bUpdateToken is false and TokenInServ YES ");
    bUpdateToken = false;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"TokenInServ"];
}

-(void) shareDeviceToken
{
    char *pMsgToSend = NULL;
    int len =0;
    if (share_id == 0)
        return;
    
    if (!bUpdateToken)
        return;
    
    struct timeval now;
    gettimeofday(&now, NULL);
    if (lastTokenUpdateSentTime > 0)
    {
        if (now.tv_sec < lastTokenUpdateSentTime + 120)
            return;
    }
    lastTokenUpdateSentTime = now.tv_sec;
    
    pMsgToSend = [pTransl storeDeviceToken:share_id deviceToken:token msgLen:&len];
    NSLog(@"Sending device token message to server share_id=%lld token=%@", share_id, token);
    if (pMsgToSend)
    {
        [self putMsgInQNoLock:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent storeDeviceToken message null pointer");
        return;
    }
    NSLog(@"Put device token msg in send Queue");
}

-(void) storeDeviceToken:(NSString *)tkn
{
    bUpdateToken = true;
    token = tkn;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:NO forKey:@"TokenInServ"];
    
    return;
}


-(void) setShare_id:(long long)shrid
{
    share_id = shrid;
    [shrMgrDelegate setShareId:share_id];
    NSNumber *shrNumb = [NSNumber numberWithLongLong:share_id];
    
    NSString  *shridStr = [shrNumb stringValue];
    //kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"com.rekhaninan.frndlst"];
    
    [kchain setObject:shridStr forKey:(__bridge id)kSecValueData];
    NSLog(@"Setting shareid %@ into keychain kSecValueData", shridStr);
    bUpdateToken = true;
    [self shareDeviceToken];
    return;
    
}


-(void ) clearShareId
{
    kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSNumber *shrNumb = [NSNumber numberWithLongLong:0];
    
    NSString  *shridStr = [shrNumb stringValue];
    //kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"com.rekhaninan.frndlst"];
    
    [kchain setObject:shridStr forKey:(__bridge id)kSecValueData];
    [kvlocal setBool:NO forKey:@"TokenInServ"];
    [NSThread sleepForTimeInterval:1.0f];
    exit(1);
}

-(void) storedTrndIdInCloud
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"TrnIdInCloud"];
    return;
}

-(void) getIdIfRequired
{
   
    if (share_id > 0)
    {
        return;
    }
    
    struct timeval now;
    gettimeofday(&now, NULL);
    if (lastIdSentTime > 0)
    {
            if (now.tv_sec < lastIdSentTime + 120)
            return;
    }
    lastIdSentTime = now.tv_sec;
    char *pMsgToSend = NULL;
    int len =0;
    
    if (!share_id)
    {
        NSLog(@"Creating share_id request");
        pMsgToSend = [pTransl createIdRequest:@"1000" msgLen:&len];
       pGetIdReq=  [NSData dataWithBytes:pMsgToSend length:len];
        if (![self sendMsg:pGetIdReq])
        {
                    NSLog (@"Failed to send get Id request");
        }
        else
        {
            NSLog (@"Successfully send get Id request");
            pGetIdReq = NULL;
        }

    }
    
    
        return;
}

-(void) updateFriendList
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [pTransl updateFriendListRequest:share_id msgLen:&len];
    if (pMsgToSend)
    {
        [self putMsgInQ:pMsgToSend msgLen:len upd:true];
    }
    else
    {
        NSLog(@"Failed to sent updateFriendList message null pointer");
    }

    return;
}

-(void) shareItem:(NSString *) list listName:(NSString *)name shrId:(long long) shareId
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl shareItemMsg:self.share_id shareList:list listName:name msgLen:&len];
    
    if (pMsgToSend)
    {
        [self putMsgInQ:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent shareItem message null pointer");
    }

    return;
}

-(void) shareTemplItem:(NSString *) list listName: (NSString *) name shrId:(long long) shareId
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl shareTemplItemMsg:shareId  shareList:list listName:name msgLen:&len];
    if (pMsgToSend)
    {
        [self putMsgInQ:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent shareTemplItem message null pointer");
    }

}


-(void) sharePicture:(NSURL *)picUrl metaStr:(NSString *)picMetaStr shrId:(long long) shareid
{
    NSLog(@"Sharing picture URL=%@ metaStr=%@ shareId=%lld", picUrl, picMetaStr, shareid);
    NSString *pPicMetaStr = [NSString stringWithFormat:@"%@:::]%lld", picMetaStr, shareid];
    nTotalFileSize += [self picUrlFileSize:picUrl];
    [self putPicInQ:picUrl metaStr:pPicMetaStr];
    
    return;
}

-(long) picUrlFileSize:(NSURL *) picUrl
{
    NSNumber *fileSizeValue = nil;
    NSError *fileSizeError = nil;
    [picUrl getResourceValue:&fileSizeValue
                       forKey:NSURLFileSizeKey
                        error:&fileSizeError];
    if (fileSizeValue) {
        NSLog(@"File size of picture  for %@ is %ld", picUrl, [fileSizeValue longValue]);
    }
    else {
        NSLog(@"error getting size for url %@ error was %@", picUrl, fileSizeError);
    }
    return [fileSizeValue longValue];
}


-(void) archiveItem:(NSString *) item itemName: (NSString *) name
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl archiveItemMsg:self.share_id itemName:name item:item msgLen:&len];
    if (pMsgToSend)
    {
        [self putMsgInQ:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent archiveItem message null pointer");
    }

    return;
}

-(void) getItemsInLoop
{
    if (!self.share_id)
    {
        return;
    }
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl getItems:self.share_id msgLen:&len];
    
    if (pMsgToSend)
    {
        [self putMsgInQNoLock:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent getItems message null pointer");
    }
    
    
    return;
}

-(void) getItems
{
    if (!self.share_id)
    {
        NSLog(@"No share Id too early to send getItems");
        return;
    }
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    
    if ([kvlocal boolForKey:@"ToDownload"] == NO)
        return;
    
    [kvlocal setBool:NO forKey:@"ToDownload"];
    
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl getItems:self.share_id msgLen:&len];
    
    if (pMsgToSend)
    {
        [self putMsgInQNoLock:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent getItems message null pointer");
    }
    

    return;
}




-(void) picDoneMsg
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl picDone:self.share_id msgLen:&len];
    if (pMsgToSend)
    {
        NSLog(@"Sending picDoneMsg");
        [self putMsgInQ:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent picDone message null pointer");
    }
    
    return;
}


-(void) putPicInQ:(NSURL *)pPicToSend metaStr:(NSString *)picMetaStr
{
    if (pPicToSend)
    {
        [dataToSend lock];
        pImgsToSend[picInsrtIndx] = pPicToSend;
        pImgsMetaData[picInsrtIndx] = picMetaStr;
        [pShareDBIntf storePicMetaData:picMetaStr index:picInsrtIndx];
        [pShareDBIntf storePicUrlData:[pPicToSend absoluteString] index:picInsrtIndx];
        ++picInsrtIndx;
        if (picInsrtIndx == BUFFER_BOUND)
            picInsrtIndx =0;
        [dataToSend signal];
        [dataToSend unlock];
    }
    return;
}

-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len upd:(bool) upord
{
    if (pMsgToSend)
    {
        [dataToSend lock];
        NSData *pMsg =[NSData dataWithBytes:pMsgToSend length:len];
        pMsgsToSend[insrtIndx] = pMsg;
        upOrDown[insrtIndx] = upord;
        [pShareDBIntf storeItem:pMsg index:insrtIndx upord:upord];
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        free(pMsgToSend);
        [dataToSend signal];
        [dataToSend unlock];
    }
    return;
}



-(void) putMsgInQNoLock :(char*) pMsgToSend msgLen:(int) len
{
    if (pMsgToSend)
    {
        NSData *pMsg =[NSData dataWithBytes:pMsgToSend length:len];
        pMsgsToSend[insrtIndx] = pMsg;
        upOrDown[insrtIndx] = false;
        [pShareDBIntf storeItem:pMsg index:insrtIndx upord:false];
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        free(pMsgToSend);
    }
    return;
}

-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len
{
    if (pMsgToSend)
    {
        [dataToSend lock];
        NSData *pMsg =[NSData dataWithBytes:pMsgToSend length:len];
        pMsgsToSend[insrtIndx] = pMsg;
        upOrDown[insrtIndx] = false;
        [pShareDBIntf storeItem:pMsg index:insrtIndx upord:false];
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        free(pMsgToSend);
        [dataToSend signal];
        [dataToSend unlock];
    }
    return;
}

-(void) stopBackGroundTask
{
    stop = true;
    shouldStart = true;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
     //   [self clearShareId];
        bSendAlert = false;
        pGetIdReq = NULL;
        dataToSend = [[NSCondition alloc] init];
        gettimeofday(&nextIdReqTime, NULL);
        
        pNtwIntf = [[NtwIntf alloc] init];
        tdelta = 5;
        sendIndx =0;
        insrtIndx =0;
        picIndx =0;
        picMetaIndx = 0;
        picInsrtIndx =0;
        uploadPicOffset = 0;
        lastPicRcvdTime =0;
        lastIdSentTime = 0;
        lastTokenUpdateSentTime = 0;
        waitTime = 1;
        bBackGroundMode = false;
        shouldStart = true;
        stop = false;
        
        bSendPic = false;
        for (int i=0; i < BUFFER_BOUND; ++i)
            upOrDown[i] = false;
        
        kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
                
       NSString *share_id_str = [kchain objectForKey:(__bridge id)kSecValueData];
    
        if (share_id_str != nil)
            share_id = [share_id_str intValue];
        else
            share_id = 0;
        
        NSLog (@"Share id value %lld", share_id);
        
        friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
        if (friendList != nil)
            NSLog(@"Friendlist %@", friendList);
        
        [self initializeTokenUpdate];
        
        pShareDBIntf = [[ShareItemDBIntf alloc] init];
        
        [self initializeShareObjs];
        sharingQueue = dispatch_queue_create("sharing", NULL);
    }
    return self;
}

-(void) initializeShareObjs
{
    NSMutableDictionary *shareItemDic = [pShareDBIntf refreshItemData];
    int lindx = BUFFER_BOUND + 10;
    int hindx = -1;
    NSMutableArray *itemsToDelete = [[NSMutableArray alloc] init];
    for (NSNumber *key in shareItemDic)
    {
        ShareItem *shareItem = [shareItemDic objectForKey:key];
        NSLog(@"Archived message to send index=%d message=%@", shareItem.index, shareItem.value);
        if (shareItem.value == NULL)
        {
            [itemsToDelete addObject:[NSNumber numberWithInt:shareItem.index]];
            
            continue;
        }
        pMsgsToSend[shareItem.index] = shareItem.value;
        upOrDown[shareItem.index] = shareItem.upord;
        if (shareItem.index < lindx)
            lindx = shareItem.index;
        if (shareItem.index > hindx)
            hindx = shareItem.index;
    }
    
    for (NSNumber *item in itemsToDelete)
    {
        [pShareDBIntf deleteItem:[item intValue]];
    }
    
    if (hindx != -1)
    {
        sendIndx = lindx;
        insrtIndx = hindx + 1;
        lindx = BUFFER_BOUND + 10;
        hindx = -1;
    }
    
    NSMutableDictionary *picUrlDictionary = [pShareDBIntf refreshPicUrls];
    for (NSNumber *key in picUrlDictionary)
    {
        PicUrl *picUrl = [picUrlDictionary objectForKey:key];
        pImgsToSend[picUrl.index] = [NSURL URLWithString:picUrl.value];
        if (picUrl.index < lindx)
            lindx = picUrl.index;
        if (picUrl.index > hindx)
            hindx = picUrl.index;
    }
    
    if (hindx != -1)
    {
        picIndx = lindx;
        picMetaIndx = lindx;
        picInsrtIndx = hindx + 1;
        
    }
    NSMutableDictionary *picMetaDataDic = [pShareDBIntf refreshPicMetaData];
    for (NSNumber *key in picMetaDataDic)
    {
        PicMetaData *picMetaData = [picMetaDataDic objectForKey:key];
        pImgsMetaData[picMetaData.index] = picMetaData.value;
    }

    
}

-(void ) sendGetIdRequest
{
    if (pGetIdReq)
    {
        struct timeval now;
        gettimeofday(&now, NULL);
        if (now.tv_sec > nextIdReqTime.tv_sec)
        {
            if (![self sendMsg:pGetIdReq])
            {
                nextIdReqTime.tv_sec = now.tv_sec + tdelta;
                tdelta *=2;
                NSLog (@"Failed to send get Id request setting next attempt at %ld", nextIdReqTime.tv_sec);
            }
            else
            {
                NSLog (@"Successfully send get Id request at %ld", nextIdReqTime.tv_sec);
                pGetIdReq = NULL;
            }
        }
    }
}

-(void) processItems
{
    
}

-(void) displayAlertIfReqd
{
    if (!bSendAlert)
    {
        return;
    }
    if (sendIndx == insrtIndx && picIndx == picInsrtIndx)
    {
        NSLog(@"Displaying sent item alert");
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *msg = [NSString stringWithFormat:@"Sent item %@", alertMsg];
            //msg = [msg stringByAppendingString:alertMsg];
            [shrMgrDelegate displayAlert:msg];
        });
    }
    bSendAlert = false;
}

-(void ) mainProcessLoop:(bool) bNtwThread
{
      bool upd;
    NSData *pMsgToSend;
    NSURL *pImgToSend;
    NSString *pImgMetaData;
    
    NSLog(@"Entering main processing loop of ShareMgr");
    for(;;)
    {
        if (stop)
            break;
        [dataToSend lock];
        [self getIdIfRequired];
        [self shareDeviceToken];
        pMsgToSend = NULL;
        pImgToSend = NULL;
        pImgMetaData = NULL;
        upd = false;
        [self getItems];
        if (((sendIndx == insrtIndx && picIndx == picInsrtIndx) || pNtwIntf.connecting)
            && bNtwThread)
        {
            [self displayAlertIfReqd];
           // NSLog(@"Waiting for work\n");
            if (pNtwIntf.connecting)
            {
                waitTime = 1;
            }
            else
            {
                waitTime = 3;
            }
           
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
        //     NSLog(@"Waiting waitTime=%d bNtwConnected=%d connecting=%d", waitTime, //bNtwConnected, pNtwIntf.connecting);
            [dataToSend waitUntilDate:checkTime];
        }
        if (sendIndx != insrtIndx)
        {
            pMsgToSend = pMsgsToSend[sendIndx];
            upd = upOrDown[sendIndx];
            NSLog(@"Sending message at Index=%d insrtIndx=%d upd=%d", sendIndx, insrtIndx, upd);
            if (!pMsgToSend)
                [self updateMsgIndx];
        }
        
        if (picIndx != picInsrtIndx)
        {
            pImgToSend = pImgsToSend[picIndx];
            bool bNoMeta = false;
            if (picIndx == picMetaIndx)
            {
                pImgMetaData = pImgsMetaData[picMetaIndx];
                if (!pImgMetaData)
                    bNoMeta = true;
                
            }
            if (!pImgToSend || bNoMeta)
                [self updatePicIndx];
            
        }
        
        [dataToSend unlock];
        if (pMsgToSend)
        {
           if( [self sendMsg:pMsgToSend])
           {
               bNtwConnected = true;
               [self updateMsgIndx];
           }
            else
            {
                bNtwConnected = false;
            }
        }
        if (pImgMetaData)
        {
            [self sendPicMetaData:pImgToSend metaStr:pImgMetaData];
        }
        if (bSendPic)
        {
            if ([self sendPic])
            {
                [self updatePicIndx];
            }
            
        }
        
        [self processResponse];
        [[NSRunLoop  currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2.0]];
        
        
        
    }
    

}

-(void) updateMsgIndx
{
    [pShareDBIntf deleteItem:sendIndx];
    ++sendIndx;
    if (sendIndx == BUFFER_BOUND)
        sendIndx =0;
}

-(bool) doneBackGroundProcessing
{
   
    struct timeval now;
    
    gettimeofday(&now, NULL);
    
    if (now.tv_sec - lastNtwActvtyTime.tv_sec > MAX_IDLE_TIME)
        return true;
    
    return false;
}

-(void) updatePicIndx
{
    [pShareDBIntf deletePicMetaData:picIndx];
    [pShareDBIntf deletePicUrlData:picIndx];
    ++picIndx;
    if (picIndx == BUFFER_BOUND)
        picIndx = 0;
    picMetaIndx = picIndx;
    bSendPic = false;
}

-(void) processShouldUploadMsg : (bool) upload
{
    if (upload)
    {
        bSendPic = true;
        NSLog(@"Shoud upload picture at offset %lu %s %d", (unsigned long)uploadPicOffset, __FILE__, __LINE__);
    }
    else
    {
        NSLog(@"Don't upload picture %s %d",  __FILE__, __LINE__);
        nTopUpload += [picData length];
        [self updateTotalUpload];
        [self updatePicIndx];
    }
    
}

-(void) start
{
    
    dispatch_async(sharingQueue, ^{
        if (!shouldStart)
            return;
        shouldStart = false;
        stop = false;
        [self beginBackgroundUpdateTask];
        bNtwConnected = true;
        [shrMgrDelegate setShareId:share_id];
        [self getIdIfRequired];
        [self mainProcessLoop:true];
        [self endBackgroundUpdateTask];
    });
    
       return;
}

-(void) startBackGroundTask
{
    dispatch_async(sharingQueue, ^{
        if (!shouldStart)
            return;
        shouldStart = false;
        stop = false;
        bNtwConnected = true;
        [shrMgrDelegate setShareId:share_id];
        [self getIdIfRequired];
        [self mainProcessLoop:true];
    });
}

- (void) beginBackgroundUpdateTask
{
    NSLog(@"Background task started");
    bgTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [self endBackgroundUpdateTask];
    }];
}

- (void) endBackgroundUpdateTask
{
    stop = true;
    shouldStart = true;
    NSLog(@"Sharing extended background execution ended");
    if (![self doneBackGroundProcessing])
    {
        NSLog(@"Scheduling background task");
        [shrMgrDelegate scheduleBackGroundTask];
    }
    [[UIApplication sharedApplication] endBackgroundTask: bgTaskId];
    bgTaskId = UIBackgroundTaskInvalid;
}

-(void) sendPicMetaData:(NSURL *)picUrl metaStr:(NSString *)picMetaStr
{
    char *pMsgToSend = NULL;
    int len =0;
    picData = [NSData dataWithContentsOfURL:picUrl];
    
    NSArray *pArr = [picMetaStr componentsSeparatedByString:@":::]"];
    NSUInteger cnt = [pArr count];
    if (cnt != 2)
    {
        NSLog(@"Invalid picture metastr %@ %s %d", picMetaStr, __FILE__, __LINE__);
        return;
    }
    NSString *picMetaStrR = [pArr objectAtIndex:0];
    long long shareId = [[pArr objectAtIndex:1] longLongValue];
    
    pMsgToSend = [self.pTransl sharePicMetaDataMsg:shareId  name:picUrl picLength:[picData length]  metaStr:picMetaStrR msgLen:&len];
    if ([self sendMsg:[NSData dataWithBytes:pMsgToSend length:len]])
    {
        bNtwConnected = true;
        NSLog(@"Sent picture metadata msg share_id=%lld picUrl=%@ picLength=%lu metaStr=%@ msgLen=%d %s %d", shareId, picUrl, (unsigned long)[picData length], picMetaStrR, len, __FILE__, __LINE__);
        ++picMetaIndx;
        if (picMetaIndx == BUFFER_BOUND)
            picMetaIndx = 0;
    }
    else
    {
        bNtwConnected = false;
        NSLog(@"Failed to Sent picture metadata msg share_id=%lld picUrl=%@ picLength=%lu metaStr=%@ msgLen=%d %s %d", shareId, picUrl, (unsigned long)[picData length], picMetaStrR, len, __FILE__, __LINE__);
    }

    
    
    free(pMsgToSend);

}



-(bool) sendPic
{
   
        NSUInteger indx = uploadPicOffset;
    
    for (;;)
    {
        NSLog(@"Sending picture at Index %lu", (unsigned long)indx);
        NSUInteger oldIndx = indx;
        NSData *pPicToSend = [pTransl sharePicMsg:picData dataIndx:&indx];
        
        if (pPicToSend == nil)
        {
            uploadPicOffset = 0;
            break;
        }
        SendStatus status = [pNtwIntf sendMsg:pPicToSend];
        if (status == SEND_FAIL)
        {
            bNtwConnected = false;
            uploadPicOffset = 0;
            return false;
        }
        else if (status == SEND_SUCCESS)
        {
            gettimeofday(&lastNtwActvtyTime, NULL);
            nTopUpload += (indx - oldIndx);
            [self updateTotalUpload];
            uploadPicOffset = indx;
        }
        else if (status == SEND_TRY_AGAIN)
        {
            indx = oldIndx;
            continue;
        }
    }
    bNtwConnected = true;
    return true;
}

-(void) updateTotalUpload
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [shrMgrDelegate updateTotalUpload:nTopUpload];
    
    });
}

-(void ) setPicDetails:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName
                picLen:(long long) len picOffset:(int)pSoFar
{
    
    picSaveUrl  = [shrMgrDelegate getPicUrl:shareId picName:name itemName:iName];
    if (picSaveUrl == nil)
    {
        //To account for a weird race condition when the pictures are already uploaded and the items is downloaded followed immediatly by picMetaDataMsg
         NSLog(@"Sleeping to obtain picUrl for picName=%@ itemName=%@ shareId=%lld %s %d", name, iName, shareId, __FILE__, __LINE__);
        for (int i=0; i < 3; ++i)
        {
            [NSThread sleepForTimeInterval:1.0f];
            picSaveUrl  = [shrMgrDelegate getPicUrl:shareId picName:name itemName:iName];
            if (picSaveUrl != nil)
                break;
        }
    }
    picShareUrl = [shrMgrDelegate getShareUrl:shareId picName:name itemName:iName];
    picLen = len;
    struct timeval tv;
    gettimeofday(&tv, NULL);
    lastPicRcvdTime = tv.tv_sec;
    if (picSaveUrl == nil)
    {
        NSLog(@"Cannot obtain picUrl for picName=%@ itemName=%@ shareId=%lld %s %d", name, iName, shareId, __FILE__, __LINE__);
        [self shouldDownload:shareId picName:name shldDownload:false picLength:len];
        return;
    }
    bool shouldDownLoad = true;
    picSoFar = pSoFar;
    NSError *error;
    NSLog(@"Setting picMetaData shareId=%lld picName=%@ itemName=%@ picLen=%lld", shareId, name, iName, len);
    pFilHdl = [NSFileHandle fileHandleForWritingToURL:picSaveUrl error:&error];
    if (pFilHdl == nil)
    {
        picSoFar = 0;
        if ([[NSFileManager defaultManager] createFileAtPath:[picSaveUrl path] contents:nil attributes:nil] == YES)
        {
            pFilHdl = [NSFileHandle fileHandleForWritingAtPath:[picSaveUrl path]];
            if (pFilHdl != nil)
                NSLog(@"Created file handle for url=%@", picSaveUrl);
            else
                 NSLog(@"Failed to create file handle for url=%@ , error=%@", picSaveUrl, error);
                
        }
        
    }
    else
    {
        if (picSoFar > 0)
        {
            unsigned long long fileSize = [pFilHdl seekToEndOfFile];
            if (picSoFar < fileSize)
            {
                [pFilHdl seekToFileOffset:picSoFar];
            }
        }
        else
        {
            unsigned long long fileSize = [pFilHdl seekToEndOfFile];
            if (fileSize >= len)
            {
                shouldDownLoad = false;
            }
        }
    }
    
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setInteger:(NSInteger)len forKey:@"PicLen"];
    [kvlocal setInteger:shareId forKey:@"PicShareId"];
    [kvlocal setObject:name forKey:@"PicName"];
    [kvlocal setObject:[picSaveUrl path] forKey:@"PicUrl"];
    [kvlocal setInteger:picSoFar forKey:@"PicLenStored"];
    [self shouldDownload:shareId picName:name shldDownload:shouldDownLoad picLength:len];
    
    return;
}

-(void) shouldDownload:(long long ) shareId picName:(NSString *) name shldDownload:(bool) shDwnld picLength:(long long)pLen
{
    if (!shDwnld)
    {
        nDownLoadedSoFar += pLen;
        NSLog (@"Increasing total downloaded size=%lld for picture not downloaded", nDownLoadedSoFar);
        dispatch_async(dispatch_get_main_queue(), ^{
            [shrMgrDelegate updateTotalDownLoaded:nDownLoadedSoFar];
        
        });
    }
    
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl shouldDownload:shareId picName:name shldDownload:shDwnld msgLen:&len];
    
    if (pMsgToSend)
    {
        NSLog(@"Sending should download msg for shareId=%lld picName=%@ download=%d", shareId, name, shDwnld);
        [self putMsgInQ:pMsgToSend msgLen:len];
    }
    else
    {
        NSLog(@"Failed to sent shouldDownload message null pointer");
    }

}

-(void) storePicData:(NSData *)picData1
{
    if(pFilHdl != nil)
    {
        [pFilHdl seekToEndOfFile];
        [pFilHdl writeData:picData1];
        picSoFar += [picData1 length];
        nDownLoadedSoFar += [picData1 length];
        NSLog (@"Storing picData picSoFar=%lld total downloaded=%lld", picSoFar, nDownLoadedSoFar);
        dispatch_async(dispatch_get_main_queue(), ^{
            [shrMgrDelegate updateTotalDownLoaded:nDownLoadedSoFar];
        
        });
        NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
        [kvlocal setInteger:picSoFar forKey:@"PicLenStored"];
        struct timeval tv;
        gettimeofday(&tv, NULL);
        lastPicRcvdTime = tv.tv_sec;
        if (picSoFar >= picLen)
        {
            [self storePicturePostProcessing];
        }
        
    }
    return;
}

-(void) storePicturePostProcessing
{
    NSLog(@"Closing file descriptor as Image transfer complete ");
    [pFilHdl closeFile];
    pFilHdl = nil;
    picSoFar =0;
    picLen = 0;
    lastPicRcvdTime = 0;
    [shrMgrDelegate storeThumbNailImage:picSaveUrl];
    if ([shrMgrDelegate respondsToSelector:@selector(updateEasyMainLstVwCntrl)] == YES)
    {
        [shrMgrDelegate updateEasyMainLstVwCntrl];
    }
    [self picDoneMsg];
    NSError *error;
    
    if ([[NSFileManager defaultManager] copyItemAtURL:picSaveUrl toURL:picShareUrl error:&error] == YES)
    {
        NSLog(@"Stored picture=%@ in sharing file=%@", picSaveUrl, picShareUrl);
    }
    else
    {
        NSLog(@"Failed to store picture=%@ in sharing file=%@ error=%@", picSaveUrl, picShareUrl, error);
    }
}

-(void) processResponse
{
    ssize_t len;
    char rcvbuf[RCV_BUF_LEN];
    bool more = true;
    while (more)
    {
        if ([pNtwIntf getResp:rcvbuf buflen:RCV_BUF_LEN msglen:&len])
        {
            gettimeofday(&lastNtwActvtyTime, NULL);
            [pDecoder processMessage:rcvbuf msglen:len];
        }
        else
        {
            break;
        }
    }

}

-(bool) sendMsg:(NSData *)pMsg
{
    if ([pNtwIntf sendMsg:pMsg] == SEND_SUCCESS)
    {
        gettimeofday(&lastNtwActvtyTime, NULL);
        return true;
    }
    
    NSLog(@"Failed to send Message");
    //char *pMsg =
    return false;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

@end
