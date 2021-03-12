//
//  MessageTranslator.h
//  sharing
//
//  Created by Ninan Thomas on 2/1/16.
//  Copyright © 2016 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MessageTranslator : NSObject

@property (nonatomic) int appId;

-(char *) createIdRequest:(NSString *) transactionId msgLen :(int *) len;
-(char *) storeTrnIdRequest:(NSString *) transactionId share_id:(long long) shareId msgLen :(int *) len;

-(char *) storeDeviceToken: (long long) shareId deviceToken:(NSString *)token msgLen:(int *)len;
-(char *) updateFriendListRequest: (long long) shareId  msgLen :(int *) len;
-(char *) getItems:(long long) shareId msgLen:(int *)len msgId:(int) msgid;
-(char *) picDone:(long long) shareId msgLen:(int *)len;
-(char *) shareItemMsg:(long long) shareId shareList:(NSString *) shareLst  listName: (NSString* ) name msgLen:(int *)len;
-(char *) shareTemplItemMsg:(long long) shareId shareList:(NSString *) shareLst  listName: (NSString* ) name msgLen:(int *)len;
-(char *) sharePicMetaDataMsg:(long long) shareId name:(NSURL *)picUrl picLength:(NSUInteger) length metaStr:(NSString* ) picMetaStr msgLen:(int *)len;

-(char *) archiveItemMsg:(long long) shareId  itemName:(NSString *)name item:(NSString*) storeLst msgLen:(int *) len;
-(char *) getItems:(long long) shareId msgLen:(int *)len;
-(char *) shouldDownload:(long long ) shareId picName:(NSString *) name shldDownload:(bool) shDwnld msgLen:(int *) len;
-(NSData *) sharePicMsg:(NSData *) picData dataIndx:(NSUInteger *)indx;

-(char *) getRemoteHostPort:(long long) shareId appName:(int) appId msgLen:(int *) len;

@end
