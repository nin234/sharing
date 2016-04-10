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
    
    [self putMsgInQ:pMsgToSend msgLen:len];
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


-(void) sharePicture:(NSURL *)picUrl
{
    [self putPicInQ:picUrl];
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

-(void) putPicInQ:(NSURL *)pPicToSend
{
    if (pPicToSend)
    {
        [dataToSend lock];
        ++picInsrtIndx;
        if (picInsrtIndx == BUFFER_BOUND)
            picInsrtIndx =0;
        pImgsToSend[picInsrtIndx] = pPicToSend;
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
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        pMsgsToSend[insrtIndx] = [NSData dataWithBytes:pMsgToSend length:len];
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
        dataToSend = [[NSCondition alloc] init];
        pNtwIntf = [[NtwIntf alloc] init];
        
        sendIndx =0;
        insrtIndx =0;
        picIndx =0;
        picInsrtIndx =0;
        waitTime = 5;
        for (int i=0; i < BUFFER_BOUND; ++i)
            upOrDown[i] = false;
        
        kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sharing"];
        
        
        NSString *share_id_str = [kchain objectForKey:(__bridge id)kSecValueData];
        if (share_id_str != nil)
            share_id = [share_id_str intValue];
        else
            share_id = 0;
        [self getIdIfRequired];
        friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
        if (friendList != nil)
            NSLog(@"Friendlist %@", friendList);
    }
    return self;
}

-(void) main
{
    NSData *pMsgToSend;
    NSURL *pImgToSend;
    for(;;)
    {
        [dataToSend lock];
        pMsgToSend = NULL;
        pImgToSend = NULL;
        if (sendIndx == insrtIndx || picIndx == picInsrtIndx)
        {
            // NSLog(@"Waiting for work\n");
            NSDate *checkTime = [NSDate dateWithTimeIntervalSinceNow:waitTime];
            [dataToSend waitUntilDate:checkTime];
        }
        if (sendIndx != insrtIndx)
        {
            pMsgToSend = pMsgsToSend[sendIndx];
            ++sendIndx;
        }
        
        if (picIndx != picInsrtIndx)
        {
            pImgToSend = pImgsToSend[picIndx];
            ++picIndx;
        }
        [dataToSend unlock];
        if (pMsgToSend)
            [self sendMsg:pMsgToSend];
        if (pImgToSend)
            [self sendPic:pImgToSend];
        [self processResponse];
    }
    
    return;
}

-(void) sendPic :(NSURL *)picUrl
{
    char *pMsgToSend = NULL;
    int len =0;
    NSArray *pathcomps = [picUrl pathComponents];
    NSString *picName = [pathcomps lastObject];
    NSData *picData = [NSData dataWithContentsOfURL:picUrl];
    [self.pTransl sharePicMetaDataMsg:self.share_id name:picName picLength:[picData length] msgLen:&len];
    [self sendMsg:[NSData dataWithBytes:pMsgToSend length:len]];
    [self sendMsg:picData];
 
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
