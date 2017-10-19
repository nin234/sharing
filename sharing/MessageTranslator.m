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
    const char *pDevIdStr = [devIdStr UTF8String];
    if (!pDevIdStr)
    {
        NSLog(@"Cannot encode devIdStr for getItems");
    }
    int devIdLen = (int)strlen(pDevIdStr) +1;
    NSUserDefaults* kvlocal = [NSUserDefaults standardUserDefaults];
    NSInteger picStored = [kvlocal integerForKey:@"PicLenStored"];
    NSInteger picLen = [kvlocal integerForKey:@"PicLen"];
    int picRemaining = (int) (picLen-picStored);
    if (picRemaining < 0)
        picRemaining = 0;
    NSString *name = [kvlocal objectForKey:@"PicName"];
    NSURL *picUrl = [kvlocal objectForKey:@"PicUrl"];
    NSError *error;
    NSFileHandle * pFilHdl = nil;
    if (picUrl != nil)
    {
        [NSFileHandle fileHandleForWritingToURL:picUrl error:&error];
    }
    if (pFilHdl == nil)
        picRemaining = 0;
    int namelen = 1;
    const char *pPicName = NULL;
    if (name != nil)
    {
        pPicName = [name UTF8String];
        namelen = (int)strlen(pPicName) +1;
    }
    int msglen = 16 + devIdLen + sizeof(int)+ namelen + sizeof(long long);
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    memcpy(pGetIdMsg+4, &msgid, sizeof(int));
    memcpy(pGetIdMsg + 8, &shareId, sizeof(long long));
    memcpy(pGetIdMsg+16, pDevIdStr, devIdLen);
    memcpy(pGetIdMsg+16+devIdLen, &picRemaining, sizeof(int));
    if (name != nil)
    {
        memcpy(pGetIdMsg+20 + devIdLen, pPicName, namelen);
    }
    else
    {
        memcpy(pGetIdMsg+20 + devIdLen, "", namelen);
    }
    long long picShareId = [kvlocal integerForKey:@"PicShareId"];
    int picshidoffset = 20 + devIdLen + namelen;
    memcpy(pGetIdMsg + picshidoffset, &picShareId, sizeof (long long));
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
    BOOL isSucess = [transactionId getCString:(pGetIdMsg+16) maxLength:tridLen encoding:NSASCIIStringEncoding];
    if (isSucess == NO)
    {
        NSLog(@"Failed to encode transactionId");
        return NULL;
    }
    *len = msglen;
    return pGetIdMsg;
    
}

-(char *) storeDeviceToken: (long long) shareId deviceToken:(NSString *)token msgLen:(int *)len
{
    
    const char *devIdStr = "ios";
    int devIdLen = (int)strlen(devIdStr) +1;
    const char *pDevTkn = [token UTF8String];
    if (!pDevTkn)
    {
        NSLog(@"Cannot encode device token");
        return NULL;
    }
    int devTknLen = (int)strlen(pDevTkn) + 1;
    int msglen = devTknLen + devIdLen + 16;
    char *pGetIdMsg = (char *)malloc(msglen);
    memcpy(pGetIdMsg, &msglen, sizeof(int));
    int storeDevTknMsgId = STORE_DEVICE_TKN_MSG;
    memcpy(pGetIdMsg+4, &storeDevTknMsgId, sizeof(int));
    memcpy(pGetIdMsg+8, &shareId, sizeof(long long));
    memcpy(pGetIdMsg+16, pDevTkn, devTknLen);
    memcpy(pGetIdMsg+16+devTknLen, devIdStr, 4);
    *len = msglen;
    return pGetIdMsg;
}

-(char *) updateFriendListRequest: (long long) shareId  msgLen:(int *) len
{
    if (!shareId)
        return NULL;
    SHKeychainItemWrapper *kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    
    NSString* friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    if (friendList == nil)
        return  NULL;
    const char *pFrndLst = [friendList UTF8String];
    if (!pFrndLst)
    {
        NSLog(@"Cannot encode friendlist");
        return NULL;
    }
    int frndLen = (int) strlen(pFrndLst)+ 1;
    int msglen = frndLen + 8 + sizeof(long long);
    char *pStoreFrndMsg = (char *)malloc(msglen);
    memcpy(pStoreFrndMsg, &msglen, sizeof(int));
    int storeFrndListMsg = STORE_FRIEND_LIST_MSG;
    memcpy(pStoreFrndMsg + sizeof(int), &storeFrndListMsg, sizeof(int));
    memcpy(pStoreFrndMsg+8, &shareId, sizeof(long long));
    memcpy(pStoreFrndMsg+2*sizeof(int)+sizeof(long long), pFrndLst, frndLen);
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
    const char *pPicName = [picName UTF8String];
    const char *pPicMetaStr = [picMetaStr1 UTF8String];
    int nameLen = (int)strlen(pPicName) + 1;
    int metaStrLen = (int)strlen(pPicMetaStr)+ 1;
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
    memcpy(pStoreMsg + nameoffset, pPicName, nameLen);
   
    int lenghtoffset = nameoffset + nameLen;
    int piclen = (int) length;
    memcpy(pStoreMsg + lenghtoffset, &piclen, sizeof(int));
    int metastrlenoffset = lenghtoffset + sizeof(int);
    memcpy(pStoreMsg + metastrlenoffset, &metaStrLen, sizeof(int));
    int metastroffset = metastrlenoffset+sizeof(int);
    memcpy(pStoreMsg+ metastroffset, pPicMetaStr, metaStrLen);
    
        return pStoreMsg;

}

-(NSData *) sharePicMsg:(NSData *) picData dataIndx:(NSUInteger *)indx
{
    NSUInteger picLen = [picData length];
    if (*indx >= picLen)
        return nil;
    char buf[MAX_BUF];
    int msgLen = MAX_BUF;
    
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
    msgLen = (int)canSent + 2*sizeof(int);
    memcpy(buf, &msgLen, sizeof(int));
    NSData *pPicDataChunkToSend = [NSData dataWithBytes:buf length:canSent+2*sizeof(int)];
    
    *indx += canSent;
    return pPicDataChunkToSend ;
    
}

-(char *) shareMsg:(long long) shareId shareList:(NSString *) shareLst  listName: (NSString* ) name msgLen:(int *)len msgId:(int) shareListMsgId
{
   
    const char *pShareLst = [shareLst UTF8String];
    const char *pName = [name UTF8String];
    if (!pShareLst || !pName)
    {
        NSLog(@"Failed to create shareMsg");
        return NULL;
    }
    int listLen = (int)strlen(pShareLst)+1;
     int nameLen = (int)strlen(pName) + 1;
    int msglen = 4*sizeof(int) + nameLen + listLen + sizeof(long long);
    *len = msglen;
    char *pStoreLst = (char *)malloc(msglen);
    memcpy(pStoreLst, &msglen, sizeof(int));
    memcpy(pStoreLst+sizeof(int), &shareListMsgId, sizeof(int));
    memcpy(pStoreLst + 2*sizeof(int), &shareId, sizeof(long long));
    int namelenoffset = 2*sizeof(int) + sizeof(long long);
    memcpy(pStoreLst+ namelenoffset, &nameLen, sizeof(int));
    int listlenoffset = namelenoffset+sizeof(int);
    memcpy(pStoreLst+listlenoffset, &listLen, sizeof(int));
    int nameoffset = listlenoffset + sizeof(int);
    memcpy(pStoreLst+nameoffset, pName, nameLen);
    int shareoff = nameoffset+nameLen;
    memcpy(pStoreLst +shareoff, pShareLst, listLen);
       NSLog(@"shareLst=%@", shareLst);
    NSLog(@"shareMsg nameLen=%d listLen=%d msglen=%d nameoffset=%d listoffset=%d", nameLen, listLen, msglen, nameoffset, shareoff);
   
    return pStoreLst;
}

-(char *) shareTemplItemMsg:(long long) shareId shareList:(NSString *) shareLst  listName: (NSString* ) name msgLen:(int *)len
{
    return [self shareMsg:shareId shareList:shareLst listName:name msgLen:len msgId:SHARE_TEMPL_ITEM_MSG];
    
}

-(char *) shareItemMsg:(long long) shareId shareList: (NSString *) shareLst listName:(NSString *)name msgLen:(int *)len
{
    return [self shareMsg:shareId shareList:shareLst listName:name msgLen:len msgId:SHARE_ITEM_MSG];
}

-(char *) archiveItemMsg:(long long) shareId  itemName:(NSString *)name item:(NSString*) storeLst msgLen:(int *) len
{
    if (!shareId)
        return NULL;
    
    const char *pStoreTemplLst = [storeLst UTF8String];
    const char *pName = [name UTF8String];
    if (!pStoreTemplLst || !pName)
    {
        NSLog(@"Failed to create archiveItemMsg");
        return NULL;
    }
    int storeLen = (int)strlen(pStoreTemplLst)+1;
    int nameLen = (int)strlen(pName) + 1;
    int msglen = storeLen + nameLen + 4*sizeof(int) + sizeof(long long);
    char *pStoreLst = (char *)malloc(msglen);
    memcpy(pStoreLst, &msglen, sizeof(int));
    int storeLstMsgId = ARCHIVE_ITEM_MSG;
    memcpy(pStoreLst + sizeof(int), &storeLstMsgId, sizeof(int));
    memcpy(pStoreLst + 2*sizeof(int), &shareId, sizeof(long long));
    int nameLenoffset = 2*sizeof(int)+sizeof(long long);
    memcpy(pStoreLst + nameLenoffset, &nameLen, sizeof(int));
    
    int storelenoffset = 3*sizeof(int)+sizeof(long long);
    memcpy(pStoreLst + storelenoffset, &storeLen, sizeof(int));
    int nameoffset =  4*sizeof(int)+sizeof(long long);
    memcpy(pStoreLst+nameoffset, pName, nameLen);
    int storelstoffset = 4*sizeof(int)+sizeof(long long) + nameLen;
    memcpy(pStoreLst + storelstoffset, pStoreTemplLst, storeLen);
    
    *len = msglen;
    return pStoreLst;
    
}


@end
