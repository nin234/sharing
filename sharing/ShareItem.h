//
//  ShareItem.h
//  sharing
//
//  Created by Ninan Thomas on 10/24/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface ShareItem : NSManagedObject

@property (nonatomic, retain) NSString * value;
@property (nonatomic) bool upord;
@property (nonatomic) int index;

@end
