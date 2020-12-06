//
//  ShareItemDBIntf.m
//  sharing
//
//  Created by Ninan Thomas on 10/24/17.
//  Copyright © 2017 Sinacama. All rights reserved.
//

#import "ShareItemDBIntf.h"
#import "ShareItemNew.h"
#import "PicMetaDataNew.h"
#import "PicUrlNew.h"

@implementation ShareItemDBIntf



@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


-(instancetype) init
{
    self = [super init];
    if (self)
    {
        itemDictonary = [[NSMutableDictionary alloc] init];
        picMetaDataDictonary = [[NSMutableDictionary alloc] init];
        picUrlDictonary = [[NSMutableDictionary alloc] init];
        
    }
    return  self;
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    return;
}

-(NSMutableDictionary *) refreshItemData
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"ShareItemNew" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    NSArray *shareItems = [moc executeFetchRequest:req error:&error];
    for (ShareItemNew *shareItem in shareItems)
    {
        [itemDictonary setObject:shareItem forKey:[NSNumber numberWithInt:shareItem.index]];
    }
    
    [self saveContext];
    return itemDictonary;
}

-(NSMutableDictionary *) refreshPicUrls
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"PicUrlNew" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    NSArray *picUrls = [moc executeFetchRequest:req error:&error];
    for (PicUrlNew *picUrl in picUrls)
    {
        [picUrlDictonary setObject:picUrl forKey:[NSNumber numberWithInt:picUrl.index]];
    }
    
    [self saveContext];
    return picUrlDictonary;
}

-(NSMutableDictionary *) refreshPicMetaData
{
    NSManagedObjectContext *moc = self.managedObjectContext;
    NSEntityDescription *descr = [NSEntityDescription entityForName:@"PicMetaDataNew" inManagedObjectContext:moc];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:descr];
    NSError *error = nil;
    NSArray *picMetaDatas = [moc executeFetchRequest:req error:&error];
    for (PicMetaDataNew *picMetaData in picMetaDatas)
    {
        [picMetaDataDictonary setObject:picMetaData forKey:[NSNumber numberWithInt:picMetaData.index]];
    }
    
    [self saveContext];
    return picMetaDataDictonary;
    
}



-(void) storeItem : (NSData *) item index:(int)indx upord:(bool) upd
{
    NSManagedObjectModel *managedObjectModel =
    [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *shareItemEntity = [ent objectForKey:@"ShareItemNew"];
    ShareItemNew *shareItem = [[ShareItemNew alloc] initWithEntity:shareItemEntity insertIntoManagedObjectContext:self.managedObjectContext];
    shareItem.value = item;
    shareItem.index = indx;
    shareItem.upord = upd;
    NSLog(@"Storing item in ShareItemDB item index=%d upord=%d",  indx, upd);
    [itemDictonary setObject:shareItem forKey:[NSNumber numberWithInt:indx]];
    [self saveContext];
    
}

-(void) deleteItem : (int) index
{
    ShareItemNew *shareItem = [itemDictonary objectForKey:[NSNumber numberWithInt:index]];
    if (shareItem != nil)
    {
        [self.managedObjectContext deleteObject:shareItem];
        [itemDictonary removeObjectForKey:[NSNumber numberWithInt:index]];
        [self saveContext];
    }
    
}


-(void) storePicUrlData : (NSString *) item index:(int)indx
{
    NSManagedObjectModel *managedObjectModel =
    [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *picUrlEntity = [ent objectForKey:@"PicUrlNew"];
    PicUrlNew *picUrl = [[PicUrlNew alloc] initWithEntity:picUrlEntity insertIntoManagedObjectContext:self.managedObjectContext];
    picUrl.value = item;
    picUrl.index = indx;
    
    [picUrlDictonary setObject:picUrl forKey:[NSNumber numberWithInt:indx]];
    [self saveContext];
}

-(void) deletePicUrlData : (int) index
{
    PicUrlNew *picUrl = [picUrlDictonary objectForKey:[NSNumber numberWithInt:index]];
    if (picUrl != nil)
    {
        [self.managedObjectContext deleteObject:picUrl];
        [picUrlDictonary removeObjectForKey:[NSNumber numberWithInt:index]];
        [self saveContext];
    }

}

-(void) storePicMetaData : (NSString *) item index:(int)indx
{
    NSManagedObjectModel *managedObjectModel =
    [[self.managedObjectContext persistentStoreCoordinator] managedObjectModel];
    NSDictionary *ent = [managedObjectModel entitiesByName];
    printf("entity count %lu\n", (unsigned long)[[ent allKeys] count]);
    NSEntityDescription *picMetaDataEntity = [ent objectForKey:@"PicMetaDataNew"];
    PicMetaDataNew *picMetaDataItem = [[PicMetaDataNew alloc] initWithEntity:picMetaDataEntity insertIntoManagedObjectContext:self.managedObjectContext];
    picMetaDataItem.value = item;
    picMetaDataItem.index = indx;
    
    [picMetaDataDictonary setObject:picMetaDataItem forKey:[NSNumber numberWithInt:indx]];
    [self saveContext];

}

-(void) deletePicMetaData : (int) index
{
    PicMetaDataNew *picMetaDataItem = [picMetaDataDictonary objectForKey:[NSNumber numberWithInt:index]];
    if (picMetaDataItem != nil)
    {
        [self.managedObjectContext deleteObject:picMetaDataItem];
        [picMetaDataDictonary removeObjectForKey:[NSNumber numberWithInt:index]];
        [self saveContext];
    }
 
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error while saving MOC %@, %@", error, [error userInfo]);
            // abort();
        }
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    
   
    
    if (__managedObjectContext != nil) {
        return __managedObjectContext;
    }
    NSLog(@"getting moc1 for sharing_new");
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    
    if (coordinator != nil)
    {
        // Make life easier by adopting the new NSManagedObjectContext concurrency API
        // the NSMainQueueConcurrencyType is good for interacting with views and controllers since
        // they are all bound to the main thread anyway
        NSManagedObjectContext* moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        
        [moc performBlockAndWait:^{
            // even the post initialization needs to be done within the Block
            [moc setPersistentStoreCoordinator: coordinator];
            
        }];
        __managedObjectContext = moc;
    }
    [__managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"sharing_new" withExtension:@"momd"];
    NSLog(@"Setting modelURL to %@", modelURL);
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
    
    
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    NSLog(@"getting psc");
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    NSLog(@"getting psc1");
    NSError *error = nil;
    NSString *dbName = @"sharing_new";
    NSString *storeUrlPath = [dbName stringByAppendingString:@".sqlite"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:storeUrlPath];
    
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSLog(@"Setting URL to %@", storeURL);
    
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        
        
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        UIAlertView *pAvw = [[UIAlertView alloc] initWithTitle:@"System error" message:@"Restart the app. If Delete the app and reinstall and  restart." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [pAvw show];
    }
    return __persistentStoreCoordinator;
    
    
}


#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}



@end
