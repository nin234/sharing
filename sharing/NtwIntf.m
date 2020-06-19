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
@synthesize useNSStream;
@synthesize port;

-(instancetype) init
{
   self = [super init];
    isConnected = false;
    useNSStream = true;
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
    
    if (useNSStream)
    {
        return [self sendStreamMsg:pMsg];
    }
    
    
    NSUInteger len = [pMsg length];
    
     NSLog(@"Sending message to server length=%lu %s %d",(unsigned long)len, __FILE__, __LINE__);
    
    if (write(cfd, [pMsg bytes], len) != len)
    {
        NSLog(@"Failed to send message to server %d %s, %s %d", errno, strerror(errno), __FILE__, __LINE__);
        close(cfd);
        return false;
    }
    NSLog(@"Send message to server length=%lu %s %d",(unsigned long)len, __FILE__, __LINE__);
    

    return true;
}

-(bool) sendStreamMsg:(NSData *)pMsg
{
     NSUInteger len = [pMsg length];
    NSStreamStatus status =  [outputStream streamStatus];
    NSLog(@"Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
    if (status == NSStreamStatusClosed || status == NSStreamStatusError)
    {
         NSLog(@"1 Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
        isConnected = false;
        return false;
    }
    
    if (status != NSStreamStatusOpen)
    {
         NSLog(@" 2 Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
        return false;
    }
    
     NSLog(@"3 Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
    if ([outputStream hasSpaceAvailable] == YES)
    {
         NSLog(@"4 Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
        if ([outputStream write:[pMsg bytes] maxLength:[pMsg length]] <= 0)
        {
            [inputStream close];
            [outputStream close];
            isConnected = false;
             NSLog(@"Failed to send message outputStream write failed");
            return false;
        }
        else
        {
             NSLog(@"Send message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
            return true;
        }
    }
    else
    {
        NSLog(@"Failed to send message output stream busy");
        return false;
    }
   
     NSLog(@"5 Sending message to server length=%lu StreamStatus=%lu %s %d",(unsigned long)len, (unsigned long)status, __FILE__, __LINE__);
     return true;
}

-(bool) getStreamResp:(char*) buffer buflen:(int)blen msglen:(ssize_t*)len
{
    NSStreamStatus status =  [inputStream streamStatus];
    if (status == NSStreamStatusClosed)
    {
        isConnected = false;
        return false;
    }
    
    if ([inputStream hasBytesAvailable] == YES)
    {
        *len = [inputStream read:(uint8_t*)buffer maxLength:blen];
        if (*len>0)
        {
             NSLog(@"Received message of length %zd %s %d", *len, __FILE__, __LINE__);
            return true;
        }
        if (*len == -1)
        {
            NSLog(@"Failed to receive message %zd", *len);
            [inputStream close];
            [outputStream close];
            isConnected = false;
        }
        return false;
    }
    
    return false;
}

-(bool) getResp:(char*) buffer buflen:(int)blen msglen:(ssize_t*)len
{
     if (!isConnected)
         return false;
    if (useNSStream)
    {
        return [self getStreamResp:buffer buflen:blen msglen:len];
    }
    
  
    //NSLog(@"Waiting for message");
    *len = recvfrom(cfd, buffer, blen, 0, NULL, NULL);
    if (*len >0)
    {
        NSLog(@"Received message of length %zd %s %d", *len, __FILE__, __LINE__);
        return true;
    }
    else if (*len ==0)
    {
        close(cfd);
        isConnected = false;
        NSLog(@"Failed to receive message %zd %d %s %d", *len, errno, __FILE__, __LINE__);
        return false;
    }
    else
    {
        if (errno != EAGAIN)
        {
            close(cfd);
            isConnected = false;
            NSLog(@"Failed to receive message %zd %d", *len, errno);
            return false;
        }
        else
        {
           // NSLog(@"Message recvd failed with EAGAIN trying again");
            return false;
        }
        
        
    }
    return true;
}

-(bool) streamConnect
{
    /*
            CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)connectAddr, port, &readStream, &writeStream);
           inputStream = (__bridge_transfer NSInputStream *)readStream;
           outputStream = (__bridge_transfer NSOutputStream *)writeStream;
          // [inputStream setProperty:NSStreamSocketSecurityLevelSSLv3 forKey:NSStreamSocketSecurityLevelKey];
           // [outputStream setProperty:NSStreamSocketSecurityLevelSSLv2 forKey:NSStreamSocketSecurityLevelKey];
    
    
    NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithCapacity:1];
    //   [settings setObject:(NSString *)NSStreamSocketSecurityLevelSSLv3 forKey:(NSString *)kCFStreamSSLLevel];
       [settings setObject:(id)kCFBooleanFalse forKey:(NSString *)kCFStreamSSLValidatesCertificateChain];
      
    //   inputStream.delegate  = self;
    //   outputStream.delegate = self;

      // [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
       //                           forMode:NSDefaultRunLoopMode];
   // [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];

       CFReadStreamSetProperty((CFReadStreamRef)inputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
       CFWriteStreamSetProperty((CFWriteStreamRef)outputStream, kCFStreamPropertySSLSettings, (CFTypeRef)settings);
    
    
           [inputStream open];
           [outputStream open];
    
    NSLog(@"Connected to server=%@ port=%d, %s %d",connectAddr, port, __FILE__, __LINE__);
    isConnected = true;
    
    
    */
    
   

   
    CFStreamCreatePairWithSocketToHost(NULL,
                                       (__bridge CFStringRef)connectAddr,
                                       port,
                                       &readStream,
                                       &writeStream);

    // Set this kCFStreamPropertySocketSecurityLevel before
    // setting kCFStreamPropertySSLSettings.
    // Setting kCFStreamPropertySocketSecurityLevel
    // appears to override previous settings in kCFStreamPropertySSLSettings
    
    
   
    NSDictionary *sslSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 (id)kCFBooleanFalse, kCFStreamSSLValidatesCertificateChain,
                                 kCFNull, kCFStreamSSLPeerName,
                                 (id)kCFBooleanFalse, kCFStreamSSLIsServer,
                                 kCFStreamSocketSecurityLevelNegotiatedSSL, kCFStreamSSLLevel,
                                 nil];

  CFReadStreamSetProperty(readStream,
                            kCFStreamPropertySSLSettings,
                            (__bridge CFTypeRef _Null_unspecified)(sslSettings));

    CFWriteStreamSetProperty(writeStream,
    kCFStreamPropertySSLSettings,
    (__bridge CFTypeRef _Null_unspecified)(sslSettings));
 
    inputStream = (__bridge NSInputStream *)readStream;
    outputStream = (__bridge NSOutputStream *)writeStream;
   
    
    [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                 forMode:NSDefaultRunLoopMode];
    [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop]forMode:NSDefaultRunLoopMode];
    inputStream.delegate = self;
    outputStream.delegate = self;
    [inputStream open];
    [outputStream open];
     NSLog(@"Connecting to server=%@ port=%d, %s %d",connectAddr, port, __FILE__, __LINE__);
    return true;
}

-(void) addSSLCertificate:(NSStream *) aStream
{
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"servercert" ofType:@"der"];

          NSData *iosTrustedCertDerData = [NSData dataWithContentsOfFile:filePath];
         SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef) iosTrustedCertDerData);

    SecCertificateRef certs[1] = { certificate };
     SecTrustRef trust;
              // #2
            
   /* SecTrustRef inputTrust = (__bridge SecTrustRef)([inputStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerTrust]);
    
    if (inputTrust == nil)
    {
        NSLog(@"Input stream trust object is nil");
        return;
    }
    
    SecTrustRef outputTrust = (__bridge SecTrustRef)([outputStream propertyForKey:(NSString *) kCFStreamPropertySSLPeerTrust]);
    
    if (outputTrust == nil)
    {
        NSLog(@"Outputstream stream trust object is nil");
        return;
    }
           */
    CFArrayRef array = CFArrayCreate(NULL, (const void **) certs, 1, NULL);
    SecPolicyRef policy   = SecPolicyCreateBasicX509();
       if(SecTrustCreateWithCertificates(array, policy, &trust) != errSecSuccess)
       {
           NSLog(@"Failed to create trust");
           return;
       }
             
              // #4
    SecTrustSetAnchorCertificates(trust, (__bridge CFArrayRef) [NSArray arrayWithObject:(__bridge id)certificate]);
      
    CFErrorRef error;
    SecTrustResultType result;
    if (@available(iOS 12.0, *))
    {
        NSLog(@"Evaluating trust");
        if (!SecTrustEvaluateWithError(trust, &error))
        {
            NSLog(@"Failed to evaluated inputTrust error=%@", error);
            return;
        }
        
      
    }
    else
    {
        SecTrustEvaluate(trust, &result);
         
        // Fallback on earlier versions
    }
    
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSLog(@"stream:handleEvent: is invoked... eventCode=%lu", (unsigned long)eventCode);
 
    switch(eventCode)
    {
        
        case NSStreamEventHasSpaceAvailable:
        {
            
          //  [self addSSLCertificate];
            isConnected = true;
             NSLog(@"Connected to server=%@ port=%d, %s %d",connectAddr, port, __FILE__, __LINE__);
        }
        break;
            
        case NSStreamEventOpenCompleted:
        {
            
          NSLog(@"Adding SSL certificate");
            [self addSSLCertificate:stream];
            isConnected = true;
             NSLog(@"Connected to server=%@ port=%d, %s %d",connectAddr, port, __FILE__, __LINE__);
            
        }
            break;
        // continued ...
            default:
            break;
    }
}


-(bool) connect
{
    if (useNSStream)
    {
        return [self streamConnect];
    }
    
    NSLog(@"Connecting to server %s %d", __FILE__, __LINE__);
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    memset(&hints, 0, sizeof(struct addrinfo));
    hints.ai_canonname = NULL;
    hints.ai_addr = NULL;
    hints.ai_addr = NULL;
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol   = 0;
    hints.ai_flags = AI_NUMERICSERV;
    
    char conaddr[256];
    [connectAddr getCString:conaddr maxLength:256 encoding:NSASCIIStringEncoding];
    char conport[128];
    [connectPort getCString:conport maxLength:128 encoding:NSASCIIStringEncoding];
    int ret = getaddrinfo(conaddr, conport, &hints, &result);
    if ( ret)
    {
        NSLog(@"getaddrinfo failed for %s %s %s",conaddr, conport,  gai_strerror(ret));
        return false;
    }
    for (rp = result; rp != NULL; rp = rp->ai_next)
    {
        cfd = socket (rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (cfd == -1)
            continue;
        if (connect(cfd, rp->ai_addr, rp->ai_addrlen) != -1) {
            NSLog(@"Connected to %s %d conport=%s %s %d ", inet_ntoa(((struct sockaddr_in*)rp->ai_addr)->sin_addr), ((struct sockaddr_in*)rp->ai_addr)->sin_port, conport, __FILE__, __LINE__);
            break;
        }
        close(cfd);
    }
        if (rp == NULL)
    {
        NSLog(@"Could not connect socket to any address");
        return false;
    }
    struct timeval tv;

    tv.tv_sec = 1;  /* 5 Secs Timeout */
    tv.tv_usec = 0;
    setsockopt(cfd, SOL_SOCKET, SO_RCVTIMEO,(struct timeval *)&tv,sizeof(struct timeval));
    /*
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
     */
    NSLog(@"Connected to server %s %d", __FILE__, __LINE__);
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
