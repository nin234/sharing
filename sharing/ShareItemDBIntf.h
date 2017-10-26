//
//  ShareItemDBIntf.h
//  sharing
//
//  Created by Ninan Thomas on 10/24/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface ShareItemDBIntf : NSObject<UIAlertViewDelegate>
{
    NSMutableDictionary *itemDictonary;
    NSMutableDictionary *picMetaDataDictonary;
    NSMutableDictionary *picUrlDictonary;
}

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void) storeItem : (NSString *) item index:(int)indx upord:(bool) upd;
-(void) deleteItem : (int) index;

-(void) storePicMetaData : (NSString *) item index:(int)indx;
-(void) deletePicMetaData : (int) index;

-(void) storePicUrlData : (NSString *) item index:(int)indx;
-(void) deletePicUrlData : (int) index;


- (void)saveContext;

@end
