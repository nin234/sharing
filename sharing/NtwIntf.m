//
//  NtwIntf.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/18/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "NtwIntf.h"

@implementation NtwIntf
@synthesize connectAddr;
@synthesize connectPort;

-(instancetype) init
{
   self = [super init];
    isConnected = false;
    
    return self;
}

-(bool) sendMsg:(NSData *)pMsg
{
    if (!isConnected)
    {
        if (![self connect])
        {
            NSLog(@"Failed to connect to server, failed to send message");
            return false;
        }
    }
    NSUInteger len = [pMsg length];
    
    if (write(cfd, [pMsg bytes], len) != len)
    {
        NSLog(@"Failed to send message to server");
        close(cfd);
        return false;
    }
    NSLog(@"Send message to server");
    

    return true;
}


-(bool) getResp:(char*) buffer buflen:(int)blen msglen:(ssize_t*)len
{
   if (!isConnected)
       return false;
    *len = recvfrom(cfd, buffer, blen, 0, NULL, NULL);
    if (*len >0)
        return true;
    else
    {
        close(cfd);
        isConnected = false;
        NSLog(@"Failed to receive message %zd %d", *len, errno);
        return false;
    }
    return true;
}

-(bool) connect
{
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    hints.ai_canonname = NULL;
    hints.ai_addr = NULL;
    hints.ai_addr = NULL;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_flags = AI_NUMERICSERV;
    
    char conaddr[256];
    [connectAddr getCString:conaddr maxLength:256 encoding:NSASCIIStringEncoding];
    char conport[128];
    [connectPort getCString:conport maxLength:128 encoding:NSASCIIStringEncoding];
    int ret = getaddrinfo(conaddr, conport, &hints, &result);
    if ( ret)
    {
        NSLog(@"getaddrinfo failed %s", gai_strerror(ret));
        return false;
    }
    for (rp = result; rp != NULL; rp = rp->ai_next)
    {
        cfd = socket (rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (cfd == -1)
            continue;
        if (connect(cfd, rp->ai_addr, rp->ai_addrlen) != -1) {
            break;
        }
        close(cfd);
    }
        if (rp == NULL)
    {
        NSLog(@"Could not connect socket to any address");
        return false;
    }
    int flags = fcntl(cfd, F_GETFL, 0);
    if (flags <0)
    {
        NSLog(@"Could not get flags for socket");
        close(cfd);
        return false;
    }
    flags |= O_NONBLOCK;
    if (fcntl(cfd, F_SETFL, flags) == -1)
    {
        NSLog(@"Setting non blocking mode for socket failed");
        return false;
    }

    isConnected = true;
    return true;
    
}

-(void) disconnect
{
    if (isConnected)
    {
        close(cfd);
        isConnected =false;
    }
    return;
}

@end
