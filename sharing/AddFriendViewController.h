//
//  AddFriendViewController.h
//  Shopper
//
//  Created by Ninan Thomas on 7/2/13.
//
//

#import <UIKit/UIKit.h>
#import "SHKeychainItemWrapper.h"


enum eAddFrndState
{
    eAddFrndStateAdd,
    eAddFrndStateDisplay,
    eAddFrndStateEdit
};

@interface AddFriendViewController : UITableViewController<UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate>
{
    NSString *oldName;
    SHKeychainItemWrapper *kchain;
    NSString *friendList;
}


@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSMutableDictionary *frndDic;
@property  (nonatomic, retain) id pShrMgr;


@property enum eAddFrndState state;
@property bool displayMe;


-(void) contactsAddDone;
-(void) contactsEditDone;
-(void) contactsEdit;
-(void) contactsAddCancel;
-(void) contactsEditCancel;


@end
