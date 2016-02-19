//
//  NtwIntf.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 9/18/15.
//  Copyright (c) 2015 Ninan Thomas. All rights reserved.
//

#import "NtwIntf.h"

@implementation NtwIntf

-(instancetype) init
{
   self = [super init];
    isConnected = false;
    
    return self;
}

-(bool) sendMsg:(const char *)pMsg length:(int) len
{
    if (!isConnected)
    {
        if (![self connect])
        {
            NSLog(@"Failed to connect to server, failed to send message");
            return false;
        }
    }
    
    if (write(cfd, pMsg, len) != len)
    {
        NSLog(@"Failed to send message to server");
        return false;
    }
    NSLog(@"Send message to server");
    

    return true;
}


-(bool) getResp:(char*) buffer buflen:(int)blen msglen:(ssize_t*)len
{
    
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
    int ret = getaddrinfo("easygroclist.ddns.net", "16791", &hints, &result);
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
