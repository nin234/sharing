//
//  ShareItemNew.h
//  sharing
//
//  Created by Ninan Thomas on 12/5/20.
//  Copyright © 2020 Sinacama. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShareItemNew : NSManagedObject

@property (nonatomic, retain) NSData *value;
@property (nonatomic) bool upord;
@property (nonatomic) int index;

@end

NS_ASSUME_NONNULL_END
