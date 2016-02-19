//
//  FriendDetails.m
//  Shopper
//
//  Created by Ninan Thomas on 7/8/13.
//
//

#import "FriendDetails.h"

@implementation FriendDetails

@synthesize name;
@synthesize deviceId;
@synthesize deviceType;
@synthesize nickName;

-(id) initWithString:(NSString *)str
{
    self = [super init];
    if (self)
    {
        NSArray *arr = [str componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":"]];
        NSUInteger cnt = [arr count];
        if (cnt ==4)
        {
            nickName = [arr objectAtIndex:3];
        }
    
        name = [arr objectAtIndex:0];
        deviceId = [arr objectAtIndex:1];
        deviceType = [arr objectAtIndex:2];
    }
    
    return self;
}

@end
