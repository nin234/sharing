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


-(char *) getItems:(long long)shareId msgLen:(int *)len
{
    return [self getItems:shareId msgLen:len msgId:GET_ITEMS];
}


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
    int storeDevTknMsgId = STORE_DEVICE_TKN_MSG;
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

-(char *) sharePicMetaDataMsg:(long long) shareId name:(NSURL *)picUrl picLength:(NSUInteger) length metaStr:(NSString *)picMetaStr msgLen:(int *)len
{
    NSArray *pathcomps = [picUrl pathComponents];
    NSString *picName = [pathcomps lastObject];
    NSArray *pArr = [picMetaStr componentsSeparatedByString:@";"];
    NSUInteger cnt = [pArr count];
    NSString *objName = [pArr objectAtIndex:cnt-1];
    NSString *picMetaStr1 = [[NSString alloc] init];
    for (NSUInteger i=0; i < cnt-1; ++i)
    {
        picMetaStr1 = [picMetaStr1 stringByAppendingString:[pArr objectAtIndex:i]];
        picMetaStr1 = [picMetaStr1 stringByAppendingString:@";"];
    }
    picName = [picName stringByAppendingString:@";"];
    picName = [picName stringByAppendingString:objName];
    
    int nameLen = (int)[picName length] + 1;
    int metaStrLen = (int)[picMetaStr1 length]+ 1;
    int msglen = 5*sizeof(int) + nameLen  + sizeof(long long) + metaStrLen;
    *len = msglen;
    
    int sharePicMetaMsgId = PIC_METADATA_MSG;
    char *pStoreMsg = (char *)malloc(msglen);
    memcpy(pStoreMsg, &msglen, sizeof(int));
    memcpy(pStoreMsg+sizeof(int), &sharePicMetaMsgId, sizeof(int));
    memcpy(pStoreMsg + 2*sizeof(int), &shareId, sizeof(long long));
    int namelenoffset = 2*sizeof(int) + sizeof(long long);
    memcpy(pStoreMsg+ namelenoffset, &nameLen, sizeof(int));
    
    int nameoffset = namelenoffset + sizeof(int);
    [picName getCString:(pStoreMsg+nameoffset) maxLength:nameLen encoding:NSASCIIStringEncoding];
    int lenghtoffset = nameoffset + nameLen;
    int piclen = (int) length;
    memcpy(pStoreMsg + lenghtoffset, &piclen, sizeof(int));
    int metastrlenoffset = lenghtoffset + sizeof(int);
    memcpy(pStoreMsg + metastrlenoffset, &metaStrLen, sizeof(int));
    int metastroffset = metastrlenoffset+sizeof(int);
     [picMetaStr1 getCString:(pStoreMsg+metastroffset) maxLength:metaStrLen encoding:NSASCIIStringEncoding];
        return pStoreMsg;

}

-(NSData *) sharePicMsg:(NSData *) picData dataIndx:(NSUInteger *)indx
{
    NSUInteger picLen = [picData length];
    if (*indx >= picLen)
        return nil;
    char buf[MAX_BUF];
    int msgLen = MAX_BUF;
    memcpy(buf, &msgLen, sizeof(int));
    int msgId = PIC_MSG;
    memcpy(buf+sizeof(int), &msgId, sizeof(int));
   
    int spaceInBuf = MAX_BUF - 2*sizeof(int);
    NSUInteger toSent = picLen - *indx;
    NSUInteger canSent = spaceInBuf;
    if (toSent < spaceInBuf)
        canSent = toSent;
    NSRange aR;
    aR.location = *indx;
    aR.length = canSent;
    [picData getBytes:buf+2*sizeof(int) range:aR];
    NSData *pPicDataChunkToSend = [NSData dataWithBytes:buf length:canSent+2*sizeof(int)];
    
    *indx += canSent;
    return pPicDataChunkToSend ;
    
}

-(char *) shareItemMsg:(long long) shareId shareList: (NSString *) shareLst listName:(NSString *)name msgLen:(int *)len
{
    int nameLen = (int)[name length] + 1;
    int listLen = (int) [shareLst length] +1;
    int msglen = 4*sizeof(int) + nameLen + listLen + sizeof(long long);
    *len = msglen;
    int shareListMsgId = SHARE_ITEM_MSG;
    char *pStoreLst = (char *)malloc(msglen);
    memcpy(pStoreLst, &msglen, sizeof(int));
    memcpy(pStoreLst+sizeof(int), &shareListMsgId, sizeof(int));
    memcpy(pStoreLst + 2*sizeof(int), &shareId, sizeof(long long));
    int namelenoffset = 2*sizeof(int) + sizeof(long long);
    memcpy(pStoreLst+ namelenoffset, &nameLen, sizeof(int));
    int listlenoffset = namelenoffset+sizeof(int);
    memcpy(pStoreLst+listlenoffset, &listLen, sizeof(int));
    int nameoffset = listlenoffset + sizeof(int);
    [name getCString:(pStoreLst+nameoffset) maxLength:nameLen encoding:NSASCIIStringEncoding];
    int shareoff = nameoffset+nameLen;
    [shareLst getCString:(pStoreLst+shareoff) maxLength:listLen encoding:NSASCIIStringEncoding];
    return pStoreLst;
}

-(char *) archiveItemMsg:(long long) shareId  itemName:(NSString *)name item:(NSString*) storeLst msgLen:(int *) len
{
    if (!shareId)
        return NULL;
        int storeLen = (int)[storeLst length] + 1;
    int msglen = storeLen + 2*sizeof(int) + sizeof(long long);
    char *pStoreLst = (char *)malloc(msglen);
    memcpy(pStoreLst, &msglen, sizeof(int));
    int storeLstMsgId = ARCHIVE_ITEM_MSG;
    memcpy(pStoreLst + sizeof(int), &storeLstMsgId, sizeof(int));
    memcpy(pStoreLst + 2*sizeof(int), &shareId, sizeof(long long));
    int nameLen = (int)[name length];
    int nameoffset = 2*sizeof(int)+sizeof(long long);
    memcpy(pStoreLst + nameoffset, &nameLen, sizeof(int));
    int templLstLen = (int)([storeLst length] - nameLen);
    int storelenoffset = 3*sizeof(int)+sizeof(long long);
    memcpy(pStoreLst + storelenoffset, &templLstLen, sizeof(int));
    int storelstoffset = 4*sizeof(int)+sizeof(long long);
    [storeLst getCString:(pStoreLst + storelstoffset) maxLength:storeLen encoding:NSASCIIStringEncoding];
    *len = msglen;
    return pStoreLst;
    
}


@end
