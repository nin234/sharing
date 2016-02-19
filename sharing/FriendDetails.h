//
//  FriendDetails.h
//  Shopper
//
//  Created by Ninan Thomas on 7/8/13.
//
//

#import <Foundation/Foundation.h>

@interface FriendDetails : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *deviceId;
@property (nonatomic, strong) NSString *deviceType;
@property (nonatomic, strong) NSString *nickName;

-(id) initWithString:(NSString *)str;

@end
