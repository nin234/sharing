//
//  ContactsViewController.h
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/11/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHKeychainItemWrapper.h"

@protocol ContactViewControllerDelegate <NSObject>

-(void) shareNow:(NSString *) shareStr;

@end

@interface ContactsViewController : UITableViewController
{
    NSEnumerator *itr;
    NSMutableDictionary *rownoFrndDetail;
    NSString *share_id_str;
    NSMutableArray *seletedItems;
}

@property (nonatomic, retain) SHKeychainItemWrapper *kchain;
@property (nonatomic, retain) NSString *friendList;
@property (nonatomic) bool bModeShare;

-(void) populateData;

@property  (nonatomic, retain) id pShrMgr;

@property (nonatomic, strong) NSMutableDictionary *frndDic;
@property (nonatomic, weak) id<ContactViewControllerDelegate> delegate;

-(void) shareNow;


@end
