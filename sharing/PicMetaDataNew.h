//
//  PicMetaDataNew.h
//  sharing
//
//  Created by Ninan Thomas on 12/5/20.
//  Copyright © 2020 Sinacama. All rights reserved.
//

#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface PicMetaDataNew : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic) int index;

@end

NS_ASSUME_NONNULL_END
