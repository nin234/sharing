//
//  MessageDecoder.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/27/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Consts.h"

@interface MessageDecoder : NSObject
{
    bool start;
    char aggrbuf[MSG_AGGR_BUF_LEN];
    int bufIndx;
}

@property  (nonatomic, retain) id pShrMgr;

-(instancetype) init;
-(bool) processMessage:(char*)buffer msglen:(ssize_t)mlen;
-(bool) decodeMessage:(char*)buffer msglen:(ssize_t)mlen;

@end
