//
//  ShareMgr.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/22/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "ShareMgr.h"



@implementation ShareMgr

@synthesize friendList;
@synthesize share_id;
@synthesize kchain;
@synthesize pNtwIntf;
@synthesize pTransl;
@synthesize pDecoder;
@synthesize shrMgrDelegate;


-(void) storeDeviceToken:(NSString *)token
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [pTransl storeDeviceToken:share_id deviceToken:token msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}


-(void) setShare_id:(long long)shrid
{
    share_id = shrid;
    NSNumber *shrNumb = [NSNumber numberWithLongLong:share_id];
    
    NSString  *shridStr = [shrNumb stringValue];
    kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sharing"];
    
    [kchain setObject:shridStr forKey:(__bridge id)kSecValueData];
    NSLog(@"Setting shareid %@ into keychain kSecValueData", shridStr);
    return;
    
}

-(void) storedTrndIdInCloud
{
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    [kvlocal setBool:YES forKey:@"TrnIdInCloud"];
    return;
}

-(void) getIdIfRequired
{
    char *pMsgToSend = NULL;
    int len =0;
    /*
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    
    NSString *transactionId = [kvlocal objectForKey:@"TransactionId"];

    if (transactionId == nil)
    {
        
        NSLog(@"In app purchase incomplete TransactionId object nil in user defaults");
        return;
    }
    if (share_id)
    {
        BOOL bTokPut = [kvlocal boolForKey:@"TrnIdInCloud"];
        if (bTokPut == NO)
        {
            pMsgToSend = [pTransl storeTrnIdRequest:transactionId share_id:share_id msgLen:&len];
        }
    }
    else
    {
                pMsgToSend = [pTransl createIdRequest:transactionId msgLen:&len];
    }
     */
    
    if (!share_id)
    {
        NSLog(@"Creating share_id request");
        pMsgToSend = [pTransl createIdRequest:@"1000" msgLen:&len];
       pGetIdReq=  [NSData dataWithBytes:pMsgToSend length:len];
    }
    
    
        return;
}

-(void) updateFriendList
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [pTransl updateFriendListRequest:share_id msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

-(void) shareItem:(NSString *) list listName:(NSString *)name
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl shareItemMsg:self.share_id shareList:list listName:name msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

-(void) shareTemplItem:(NSString *) list listName: (NSString *) name
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl shareTemplItemMsg:self.share_id shareList:list listName:name msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
}


-(void) sharePicture:(NSURL *)picUrl metaStr:(NSString *)picMetaStr
{
    [self putPicInQ:picUrl metaStr:picMetaStr];
    return;
}

-(void) archiveItem:(NSString *) item itemName: (NSString *) name
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl archiveItemMsg:self.share_id itemName:name item:item msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

-(void) getItems
{
    char *pMsgToSend = NULL;
    int len =0;
    pMsgToSend = [self.pTransl getItems:self.share_id msgLen:&len];
    [self putMsgInQ:pMsgToSend msgLen:len];
    return;
}

-(void) putPicInQ:(NSURL *)pPicToSend metaStr:(NSString *)picMetaStr
{
    if (pPicToSend)
    {
        [dataToSend lock];
        pImgsToSend[picInsrtIndx] = pPicToSend;
        pImgsMetaData[picInsrtIndx] = picMetaStr;
        ++picInsrtIndx;
        if (picInsrtIndx == BUFFER_BOUND)
            picInsrtIndx =0;
        [dataToSend signal];
        [dataToSend unlock];
    }
    return;
}

-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len
{
    if (pMsgToSend)
    {
        [dataToSend lock];
        pMsgsToSend[insrtIndx] = [NSData dataWithBytes:pMsgToSend length:len];
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        free(pMsgToSend);
        [dataToSend signal];
        [dataToSend unlock];
    }
    return;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        pGetIdReq = NULL;
        dataToSend = [[NSCondition alloc] init];
        gettimeofday(&nextIdReqTime, NULL);
        
        pNtwIntf = [[NtwIntf alloc] init];
        tdelta = 5;
        sendIndx =0;
        insrtIndx =0;
        picIndx =0;
        picInsrtIndx =0;
        waitTime = 5;
        for (int i=0; i < BUFFER_BOUND; ++i)
            upOrDown[i] = false;
        
        kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sharing"];
        
        
       NSString *share_id_str = [kchain objectForKey:(__bridge id)kSecValueData];
     /*
        if (share_id_str != nil)
            share_id = [share_id_str intValue];
        else
      */
            share_id = 0;
        
        NSLog (@"Share id value %lld", share_id);
        
        friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
        if (friendList != nil)
            NSLog(@"Friendlist %@", friendList);
    }
    return self;
}

-(void ) sendGetIdRequest
{
    if (pGetIdReq)
    {
        struct timeval now;
        gettimeofday(&now, NULL);
        if (now.tv_sec > nextIdReqTime.tv_sec)
        {
            if (![pNtwIntf sendMsg:pGetIdReq])
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

-(void) main
{
    NSData *pMsgToSend;
    NSURL *pImgToSend;
    NSString *pImgMetaData;
    [self getIdIfRequired];
    for(;;)
    {
        [dataToSend lock];
        pMsgToSend = NULL;
        pImgToSend = NULL;
        pImgMetaData = NULL;
        if (sendIndx == insrtIndx || picIndx == picInsrtIndx)
        {
            // NSLog(@"Waiting for work\n");
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [dataToSend waitUntilDate:checkTime];
        }
        if (sendIndx != insrtIndx)
        {
            pMsgToSend = pMsgsToSend[sendIndx];
            NSLog(@"Sending message at Index=%d insrtIndx=%d", sendIndx, insrtIndx);
            ++sendIndx;
            if (sendIndx == BUFFER_BOUND)
                sendIndx =0;
        }
        
        if (picIndx != picInsrtIndx)
        {
            pImgToSend = pImgsToSend[picIndx];
            pImgMetaData = pImgsMetaData[picIndx];
            ++picIndx;
            if (picIndx == BUFFER_BOUND)
                picIndx = 0;
        }
        [dataToSend unlock];
        if (pMsgToSend)
            [self sendMsg:pMsgToSend];
        if (pImgToSend)
        {
            [self sendPic:pImgToSend metaStr:pImgMetaData];
        }
        [self sendGetIdRequest];
        [self processResponse];
    }
    
    return;
}

-(void) sendPic :(NSURL *)picUrl metaStr:(NSString *)picMetaStr
{
    char *pMsgToSend = NULL;
    int len =0;
    
    NSData *picData = [NSData dataWithContentsOfURL:picUrl];
   
    pMsgToSend = [self.pTransl sharePicMetaDataMsg:self.share_id name:picUrl picLength:[picData length]  metaStr:picMetaStr msgLen:&len];
    [self sendMsg:[NSData dataWithBytes:pMsgToSend length:len]];
    free(pMsgToSend);
    NSUInteger indx = 0;
    for (;;)
    {
        NSData *pPicToSend = [pTransl sharePicMsg:picData dataIndx:&indx];
        if (pPicToSend == nil)
            break;
        [self sendMsg:pPicToSend];
    }
 
    return;
}

-(void ) setPicDetails:(long long ) shareId picName:(NSString *) name itemName:(NSString *) iName picLen:(long long) len
{
    
    picSaveUrl  = [shrMgrDelegate getPicUrl:shareId picName:name itemName:iName];
    picLen = len;
    picSoFar = 0;
    if (picSaveUrl == nil)
    {
        NSLog(@"Cannot obtain picUrl for picName=%@ itemName=%@", name, iName);
        return;
    }
    NSError *error;
    pFilHdl = [NSFileHandle fileHandleForWritingToURL:picSaveUrl error:&error];
    if (pFilHdl == nil)
        NSLog(@"Cannot open file handle for url=%@ , error=%@", picSaveUrl, error);
    return;
}

-(void) storePicData:(NSData *)picData
{
    if(pFilHdl != nil)
    {
        [pFilHdl seekToEndOfFile];
        [pFilHdl writeData:picData];
        picSoFar += [picData length];
        if (picSoFar >= picLen)
        {
            NSLog(@"Closing file descriptor as Image transfer complete ");
            [pFilHdl closeFile];
            pFilHdl = nil;
            picSoFar =0;
            picLen = 0;
            [shrMgrDelegate storeThumbNailImage:picSaveUrl];
            
        }
        
    }
    return;
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
            more = [pDecoder processMessage:rcvbuf msglen:len];
        }
        else
        {
            break;
        }
    }

}

-(void) sendMsg:(NSData *)pMsg
{
    if (![pNtwIntf sendMsg:pMsg])
    {
        
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Share Failed" message:@"Failed to share/download item, try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                           [pAvw show];
                           
                       });
        
    }
    
    
    //char *pMsg =
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

@end
