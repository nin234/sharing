//
//  MessageTranslator.m
//  sharing
//
//  Created by Ninan Thomas on 2/1/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import "MessageTranslator.h"
#include "Consts.h"
#import "SHKeychainItemWrapper.h"

@implementation MessageTranslator

-(char *) getItems:(long long)shareId msgLen:(int *)len msgId:(int)msgid
{
    NSUUID *devId = [[UIDevice currentDevice] identifierForVendor];
    NSString *devIdStr = [devId UUIDString];
    int devIdLen = (int)[devIdStr length] +1;
    int msglen = 16 + devIdLen;
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    memcpy(pGetIdMsg+4, &msgid, sizeof(int));
    memcpy(pGetIdMsg + 8, &shareId, sizeof(long long));
    [devIdStr getCString:(pGetIdMsg+16) maxLength:devIdLen encoding:NSASCIIStringEncoding];
    *len = msglen;
    return pGetIdMsg;
}


-(char *) createIdRequest:(NSString *) transactionId msgLen :(int *) len
{
    int tridLen = sizeof(long long);
    long long trid = [transactionId longLongValue];
    int msglen =  tridLen + 8;
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    int shareMsgId = GET_SHARE_ID_MSG;
    memcpy(pGetIdMsg+4, &shareMsgId, sizeof(int));
    memcpy(pGetIdMsg + 8, &trid, sizeof(long long));
    *len = msglen;
    return pGetIdMsg;
}

-(char *) storeTrnIdRequest:(NSString *) transactionId share_id:(long long) shareId msgLen :(int *) len
{
    int tridLen = (int)[transactionId length]+1;
    int msglen = tridLen + 16;
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    int storeTrnMsgId =STORE_TRNSCTN_ID_MSG;
    memcpy(pGetIdMsg+4, &storeTrnMsgId, sizeof(int));
    memcpy(pGetIdMsg+8, &shareId, sizeof(long long));
    [transactionId getCString:(pGetIdMsg+16) maxLength:tridLen encoding:NSASCIIStringEncoding];
    *len = msglen;
    return pGetIdMsg;
    
}

-(char *) storeDeviceToken: (long long) shareId deviceToken:(NSString *)token msgLen:(int *)len
{
    int devTknLen = (int) [token length] +1;
    NSUUID *devId = [[UIDevice currentDevice] identifierForVendor];
    NSString *devIdStr = [devId UUIDString];
    int devIdLen = (int)[devIdStr length] +1;
    
    int msglen = devTknLen + devIdLen + 16;
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    int storeDevTknMsgId = STORE_EASYGROC_DEVICE_TKN_MSG;
    memcpy(pGetIdMsg+4, &storeDevTknMsgId, sizeof(int));
    memcpy(pGetIdMsg+8, &shareId, sizeof(long long));
    [token getCString:(pGetIdMsg+16) maxLength:devTknLen encoding:NSASCIIStringEncoding];
    [devIdStr getCString:(pGetIdMsg+16 + devTknLen) maxLength:devIdLen encoding:NSASCIIStringEncoding];
    
    *len = msglen;
    return pGetIdMsg;
}

-(char *) updateFriendListRequest: (long long) shareId  msgLen:(int *) len
{
    if (!shareId)
        return NULL;
    SHKeychainItemWrapper *kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sharing"];
    
    NSString* friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    if (friendList == nil)
        return  NULL;
    int frndLen = (int) [friendList length] + 1;
    int msglen = frndLen + 8 + sizeof(long long);
    char *pStoreFrndMsg = (char *)malloc(msglen);
    memcpy(pStoreFrndMsg, &msglen, sizeof(int));
    int storeFrndListMsg = STORE_FRIEND_LIST_MSG;
    memcpy(pStoreFrndMsg + sizeof(int), &storeFrndListMsg, sizeof(int));
    memcpy(pStoreFrndMsg+8, &shareId, sizeof(long long));
    [friendList getCString:(pStoreFrndMsg + 2*sizeof(int)+sizeof(long long)) maxLength:frndLen encoding:NSASCIIStringEncoding];
    *len = msglen;
    return pStoreFrndMsg;
    
}



@end
