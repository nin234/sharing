//
//  NtwIntf.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/18/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <sys/types.h>
#include <netdb.h>

@interface NtwIntf : NSObject
{
    int cfd;
    bool isConnected;
}

-(instancetype) init;
@property (nonatomic, retain) NSString *connectAddr;
@property (nonatomic, retain) NSString *connectPort;

-(bool) sendMsg:(NSData *)pMsg;
-(bool) connect;
-(void) disconnect;
-(bool) getResp:(char*) buffer buflen:(int) blen msglen:(ssize_t*)len;

@end
