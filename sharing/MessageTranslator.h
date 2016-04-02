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

-(char *) createIdRequest:(NSString *) transactionId msgLen :(int *) len;
-(char *) storeTrnIdRequest:(NSString *) transactionId share_id:(long long) shareId msgLen :(int *) len;

-(char *) storeDeviceToken: (long long) shareId deviceToken:(NSString *)token msgLen:(int *)len;
-(char *) updateFriendListRequest: (long long) shareId  msgLen :(int *) len;
-(char *) getItems:(long long) shareId msgLen:(int *)len msgId:(int) msgid;
-(char *) shareItemMsg:(long long) shareId shareList:(NSString *) shareLst  listName: (NSString* ) name msgLen:(int *)len;

-(char *) archiveItemMsg:(long long) shareId  itemName:(NSString *)name item:(NSString*) storeLst msgLen:(int *) len;
-(char *) getItems:(long long) shareId msgLen:(int *)len;

@end
