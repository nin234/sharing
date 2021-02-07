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

typedef NS_ENUM(NSUInteger, SendStatus) {
    SEND_FAIL,
    SEND_SUCCESS,
    SEND_TRY_AGAIN
};

@interface NtwIntf : NSObject <NSStreamDelegate>
{
    int cfd;
   
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    NSInputStream *inputStream ;
    NSOutputStream *outputStream ;
    bool bInStreamOpened;
    bool bOutStreamOpened;
    bool bAddCertInOpen;
    bool bAddCertInHasSpace;
    long long connectingStartTime;
}

-(instancetype) init;
@property (nonatomic, retain) NSString *connectAddr;
@property (nonatomic, retain) NSString *connectPort;
@property(nonatomic) bool useNSStream;
@property(nonatomic) bool connecting; //either connected or connecting to true
@property(nonatomic)  bool isConnected;
@property uint32_t port;

-(SendStatus) sendMsg:(NSData *)pMsg;
-(bool) connect;
-(void) disconnect;
-(bool) getResp:(char*) buffer buflen:(int) blen msglen:(ssize_t*)len;
-(void) cleanUp;

@end
