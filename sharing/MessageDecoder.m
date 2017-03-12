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
        NSLog(@"Invalid message received remaining=%zd, bufIndx=%d", remaining, bufIndx );
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
    while (next)
    {
        if (remaining == len-bufIndx)
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            [self decodeMessage:aggrbuf msglen:len];
            bufIndx = 0;
            start = true;
            break;
        }
        else if (remaining < (len -bufIndx))
        {
            if([self bufferOverFlowCheck:remaining])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, remaining);
            bufIndx += remaining;
            bMore = true;
            break;
            
        }
        else
        {
            if([self bufferOverFlowCheck:len-bufIndx])
                break;
            memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, len-bufIndx);
            [self decodeMessage:aggrbuf msglen:len];
            remaining -= len - bufIndx;
            bufIndx =0;
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
            bMore = true;
            start = false;
            break;
        }
        int len =0;
        memcpy(&len, buffer, sizeof(int));
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
            }
            else
            {
                int lenRmng = sizeof(int) - bufIndx;
                memcpy(aggrbuf+bufIndx, buffer+mlen-remaining, lenRmng);
                remaining -= lenRmng;
                bufIndx += lenRmng;
                memcpy(&len, aggrbuf, sizeof(int));
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
            bRet = [self processPicMetaDataMessage:buffer msglen:mlen];
        }
            break;
            
        case PIC_MSG:
        {
            bRet = [self processPicMessage:buffer msglen:mlen];
        }
            break;

            
        default:
            bRet = true;
            break;
    }
    
    return bRet;
}

-(bool) processPicMessage:(char *)buffer msglen:(ssize_t)mlen
{
    int msgLen;
    memcpy(buffer, &msgLen, sizeof(int));
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
    int picNameLenOffset = 2*sizeof(int) + sizeof(long);
    int picNameLen;
    long long picLen;
    memcpy(&picNameLen, buffer+ picNameLenOffset,  sizeof(int));
    int picNameOffset = picNameLenOffset+sizeof(int);
    NSString *picNameArr = [NSString stringWithCString:(buffer + picNameOffset) encoding:NSASCIIStringEncoding];
    int picLenOffset = picNameOffset+picNameLen;
    memcpy(&picLen, buffer + picLenOffset, sizeof(long long));
    NSArray *pArr = [picNameArr componentsSeparatedByString:@";"];
    NSUInteger cnt = [pArr count];
    if (cnt != 2)
    {
        NSLog(@"Invalid picName %@", picNameArr);
        return false;
    }
    NSString *picName = [pArr objectAtIndex:0];
    NSString  *itemName = [pArr objectAtIndex:1];
    
    [self.pShrMgr setPicDetails:shareId picName:picName itemName:itemName picLen:picLen];
    
    
    
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
    int shareId =0;
    memcpy(&shareId, buffer+offset, sizeof(int));
    
    [pShrMgr setShare_id:shareId];
    
    return true;
}

@end
