//
//  MessageDecoder.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/27/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "MessageDecoder.h"
#import "ShareMgr.h"


@implementation MessageDecoder

@synthesize pShrMgr;

-(instancetype) init
{
    self = [super init];
    start = true;
    bufIndx =0;
    return self;
}

-(bool) bufferOverFlowCheck:(ssize_t)remaining
{
    if (MSG_AGGR_BUF_LEN - bufIndx < remaining)
    {
        NSLog(@"Invalid message received remaining=%zd, bufIndx=%d %s %d", remaining, bufIndx , __FILE__, __LINE__);
        bufIndx =0;
        start = true;
        return true;
    }
    return false;
}

-(bool) processFragmentedMessage:(char*)buffer msglen:(ssize_t)mlen remain:(ssize_t)remaining length:(int)len
{
  bool bMore = false;
    bool next =true;
    int msglen = len;
    while (next)
    {
        if (remaining == msglen-bufIndx)
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            [self decodeMessage:aggrbuf msglen:msglen];
            bufIndx = 0;
            
            NSLog(@"bufIndx=%d mlen=%zd remaining=%zd len=%d %s %d", bufIndx, mlen, remaining, msglen,  __FILE__, __LINE__);
            start = true;
            break;
        }
        else if (remaining < (msglen -bufIndx))
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            bufIndx += remaining;
            
            NSLog(@"bufIndx=%d mlen=%zd remaining=%zd msglen=%d %s %d", bufIndx, mlen, remaining, msglen, __FILE__, __LINE__);
            bMore = true;
            break;
            
        }
        else
        {
            if([self bufferOverFlowCheck:msglen-bufIndx])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, msglen-bufIndx);
            [self decodeMessage:aggrbuf msglen:msglen];
            remaining -= msglen - bufIndx;
            bufIndx =0;
            NSLog(@"bufIndx=%d mlen=%zd remaining=%zd msglen=%d %s %d", bufIndx, mlen, remaining, msglen, __FILE__, __LINE__);
            if (remaining > sizeof(int))
            {
                memcpy(&msglen, buffer+mlen-remaining, sizeof(int));
            }
            else
            {
                memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
                bufIndx += remaining;
                bMore = true;
                break;
            }
        }
    }

    return bMore;
}

-(bool) processFreshMessage:(char*)buffer msglen:(ssize_t)mlen
{
    bool bMore = false;
    bool next =true;
    ssize_t remaining = mlen;
    while (next)
    {
        if (remaining < sizeof(int))
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            bufIndx += remaining;
            
            NSLog(@"bufIndx=%d mlen=%zd remaining=%zd %s %d", bufIndx, mlen, remaining, __FILE__, __LINE__);
            bMore = true;
            start = false;
            break;
        }
        int len =0;
        memcpy(&len, buffer + mlen - remaining, sizeof(int));
        NSLog(@"Decoding message mlen=%zd remaining=%zd len=%d %s %d", mlen, remaining, len, __FILE__, __LINE__);
        if (remaining == len)
        {
            [self decodeMessage:buffer+mlen-remaining msglen:remaining];
            break;
        }
        else if (remaining < len)
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            bufIndx += remaining;
            NSLog(@"bufIndx=%d mlen=%zd remaining=%zd len=%d %s %d", bufIndx, mlen, remaining, len, __FILE__, __LINE__);
            bMore = true;
            start = false;
            break;
            
        }
        else
        {
            [self decodeMessage:buffer+mlen-remaining msglen:len];
            remaining -= len;
        }
    }
    return bMore;
    
}

-(bool) processMessage:(char*)buffer msglen:(ssize_t)mlen
{
    bool bMore = false;
    if(start)
    {
        bMore = [self processFreshMessage:buffer msglen:mlen];
    }
    else
    {
       if (bufIndx >= sizeof(int))
       {
           int len = 0;
           memcpy(&len, aggrbuf, sizeof(int));
           
           ssize_t remaining = mlen;
           bMore = [self processFragmentedMessage:buffer msglen:mlen remain:remaining length:len];
        }
        else
        {
            int len = 0;
            ssize_t remaining = mlen;
            if (remaining +bufIndx < sizeof(int))
            {
                bMore = true;
                memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
                bufIndx += remaining;
                NSLog(@"bufIndx=%d mlen=%zd remaining=%zd", bufIndx, mlen, remaining);
                NSLog(@"bufIndx=%d mlen=%zd remaining=%zd %s %d", bufIndx, mlen, remaining, __FILE__, __LINE__);
            }
            else
            {
                int lenRmng = sizeof(int) - bufIndx;
                memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, lenRmng);
                remaining -= lenRmng;
                bufIndx += lenRmng;
                memcpy(&len, aggrbuf, sizeof(int));
                 NSLog(@"bufIndx=%d mlen=%zd remaining=%zd %s %d", bufIndx, mlen, remaining, __FILE__, __LINE__);
                 bMore = [self processFragmentedMessage:buffer msglen:mlen remain:remaining length:len];
            }

        }
    }
    return bMore;
}

-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen
{
    bool bRet = true;
    int msgTyp;
    memcpy(&msgTyp, buffer+sizeof(int), sizeof(int));
    
    switch (msgTyp)
    {
        case GET_SHARE_ID_RPLY_MSG:
        {
            bRet = [self processShareIdMessage:buffer msglen:mlen];
        }
        break;
            
        case STORE_TRNSCTN_ID_RPLY_MSG:
        {
            bRet = [self processStoreIdMessage:buffer msglen:mlen];
        }
        break;
            
        case PIC_METADATA_MSG:
        {
            NSLog(@"Received pic_metadata_msg mlen=%zd %s %d",mlen,  __FILE__, __LINE__);
            bRet = [self processPicMetaDataMessage:buffer msglen:mlen];
        }
            break;
            
        case PIC_MSG:
        {
            NSLog(@"Received pic_msg mlen=%zd %s %d",mlen,  __FILE__, __LINE__);
            bRet = [self processPicMessage:buffer msglen:mlen];
        }
            break;
            
        case SHOULD_UPLOAD_MSG:
        {
            NSLog(@"Received  SHOULD_UPLOAD_MSG mlen=%zd %s %d",mlen,  __FILE__, __LINE__);
            bRet = [self processShouldUploadMessage:buffer msglen:mlen];

        }
        break;
            
        case STORE_DEVICE_TKN_RPLY_MSG:
        {
            NSLog (@"Received STORE_DEVICE_TKN_RPLY_MSG");
            [self.pShrMgr updateDeviceTknStatus];
        }
        break;
            
        case TOTAL_PIC_LEN_MSG:
        {
            NSLog(@"Received TOTAL_PIC_LEN_MSG  mlen=%zd %s %d",mlen,  __FILE__, __LINE__);
            bRet = [self processTotalPicLenMessage:buffer msglen:mlen];
        }
        break;
            
        default:
            NSLog(@"Message of type=%d not handled here %s %d", msgTyp, __FILE__, __LINE__);
            bRet = true;
            break;
    }
    
    return bRet;
}

-(bool) processTotalPicLenMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int offset = 2*sizeof(int);
    long long picTotLen =0;
    memcpy(&picTotLen, buffer+offset, sizeof(long long));
    
    [pShrMgr setNTotalDownLoadSize:picTotLen];
    return true;
}

-(bool) processShouldUploadMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int upload;
    memcpy(&upload, buffer + 3*sizeof(int) + sizeof(long), sizeof(int));
    int picOffset;
    memcpy (&picOffset, buffer + 4*sizeof(int) + sizeof(long), sizeof(int));
    [self.pShrMgr setUploadPicOffset:picOffset];
    [self.pShrMgr processShouldUploadMsg:upload];
    return  true;
}

-(bool) processPicMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int msgLen=0;
    memcpy(&msgLen, buffer, sizeof(int));
    int header = 2*sizeof(int);
    msgLen -= 2*sizeof(int);
    NSData *picDat = [NSData dataWithBytes:buffer + header length:msgLen];
    
    [self.pShrMgr storePicData:picDat];
    return true;
}

-(bool) processPicMetaDataMessage:(char *)buffer msglen:(ssize_t)mlen
{
    
    long long shareId;
    memcpy(&shareId,  buffer + 2*sizeof(int), sizeof(long long));
    int picNameLenOffset = 2*sizeof(int) + sizeof(long long);
    int picNameLen;
    long long picLen;
    memcpy(&picNameLen, buffer+ picNameLenOffset,  sizeof(int));
    int picNameOffset = picNameLenOffset+sizeof(int);
    NSString *picNameArr = [NSString stringWithCString:(buffer + picNameOffset) encoding:NSASCIIStringEncoding];
    int picLenOffset = picNameOffset+picNameLen;
    memcpy(&picLen, buffer + picLenOffset, sizeof(long long));
     int picOffset = picLenOffset + sizeof(long long);
    int picSoFar =0;
    memcpy(&picSoFar, buffer + picOffset, sizeof(int));
    NSArray *pArr = [picNameArr componentsSeparatedByString:@";"];
    NSUInteger cnt = [pArr count];
    if (cnt != 2)
    {
        NSLog(@"Invalid picName %@", picNameArr);
        return false;
    }
    NSString *picName = [pArr objectAtIndex:0];
    NSString  *itemName = [pArr objectAtIndex:1];
    
    [self.pShrMgr setPicDetails:shareId picName:picName itemName:itemName picLen:picLen picOffset:picSoFar];
    
    
    
    return true;
}



-(bool) processStoreIdMessage:(char *)buffer msglen:(ssize_t)mlen
{
    [pShrMgr storedTrndIdInCloud];
    return true;
}

-(bool) processShareIdMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int offset = 2*sizeof(int);
    long long shareId =0;
    memcpy(&shareId, buffer+offset, sizeof(long long));
    
    [pShrMgr setShare_id:shareId];
    
    return true;
}

@end
