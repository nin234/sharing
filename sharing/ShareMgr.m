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


-(void) putMsgInQ :(char*) pMsgToSend msgLen:(int) len
{
    if (pMsgToSend)
    {
        [dataToSend lock];
        ++insrtIndx;
        if (insrtIndx == BUFFER_BOUND)
            insrtIndx =0;
        pMsgsToSend[insrtIndx] = pMsgToSend;
        lenMsgsToSend[insrtIndx] = len;
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
    for(;;)
    {
        [dataToSend lock];
        
        [dataToSend wait];
        
        [dataToSend unlock];
        
        if(sendIndx == insrtIndx)
            continue;
        while (sendIndx != insrtIndx)
        {
            ++sendIndx;
            if (sendIndx == BUFFER_BOUND)
                sendIndx = 0;
            [self sendMsgAndProcessResponse];
        }
    }
    
    return;
}

-(void) sendMsgAndProcessResponse
{
    if (![pNtwIntf sendMsg:pMsgsToSend[sendIndx] length:lenMsgsToSend[sendIndx]])
    {
        sendIndx = insrtIndx;
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"Share Failed" message:@"Failed to share item, try again later" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                           [pAvw show];
                           
                       });
        
    }
    else
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
        
    //char *pMsg =
    return;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

@end
