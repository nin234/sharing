//
//  ContactsViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/11/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import "ContactsViewController.h"
#import "AddFriendViewController.h"


const NSInteger SELECTION_INDICATOR_TAG = 53322;

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize frndDic;
@synthesize kchain;
@synthesize friendList;
@synthesize eViewCntrlMode;
@synthesize pShrMgr;
@synthesize delegate;
@synthesize tabBarController;
@synthesize bTemplShare;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self)
        {
            eViewCntrlMode = eModeContactsMgmt;
            bTemplShare = false;
        }

    
    return self;
}

-(void) populateData
{
    seletedItems = [[NSMutableArray alloc] init];
    kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
    frndDic = [[NSMutableDictionary alloc] init];
    share_id_str = [kchain objectForKey:(__bridge id)kSecValueData];
    friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    if (friendList != nil  && [friendList length] > 0)
    {
        NSLog(@"Friendlist %@", friendList);
        NSArray *friends = [friendList componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@";"]];
        NSUInteger cnt = [friends count];
        if(cnt >1)
        {
            for (NSUInteger i=0; i < cnt-1; ++i)
            {
                NSString *frndStr = [friends objectAtIndex:i];
                if (frndStr != nil && [frndStr length] > 0)
                {
                    FriendDetails *frnd = [[FriendDetails alloc] initWithString:frndStr];
                    [frndDic setObject:frnd forKey:frnd.name];
                }
                
            }
        }
        
    }
    
    if ([frndDic count])
    {
        NSUInteger cnt = [frndDic count];
        rownoFrndDetail = [[NSMutableDictionary alloc] initWithCapacity:cnt];
        itr = [frndDic objectEnumerator];
        FriendDetails *frnd;
        NSUInteger i=0;
        
        while (frnd = [itr nextObject])
        {
            NSNumber *nmbr = [NSNumber numberWithUnsignedInteger:i];
            [rownoFrndDetail setObject:frnd forKey:nmbr];
            ++i;
        }
        
    }
    else
    {
        rownoFrndDetail = [[NSMutableDictionary alloc] init];
    }
    
    NSMutableArray *seletedItemsTmp = [[NSMutableArray alloc] init];

    
    NSUInteger cnt = [frndDic count] +1;
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        [seletedItemsTmp addObject:[NSNumber numberWithBool:NO]];
    }
    seletedItems = seletedItemsTmp;

    return;
}

-(void) setNavItemsForContactsMgmtViewMode
{
    NSString *title = @"Contacts";
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact) ];
    self.navigationItem.rightBarButtonItem = pBarItem1;
}

-(void) setNavItemsForShareToSelected
{
    NSString *title = @"Share to";
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(shareNow) ];
    self.navigationItem.rightBarButtonItem = pBarItem1;
}

-(void ) setNavItemsForSelectToShare
{
    NSString *title = @"Select ";
    self.navigationItem.title = [NSString stringWithString:title];
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(launchChatView) ];
    self.navigationItem.rightBarButtonItem = pBarItem1;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"ContactsViewController viewWillAppear %s %d", __FILE__, __LINE__);
    
    [self populateData];
    [self.tableView reloadData];
    switch (eViewCntrlMode)
    {
        case eModeContactsMgmt:
            [self setNavItemsForContactsMgmtViewMode];
        break;
            
        case eModeShareToSelected:
            [self setNavItemsForShareToSelected];
        break;
            
        case eModeSelectToShare:
            [self setNavItemsForSelectToShare];
        break;
            
        default:
            NSLog (@"Invalid view mode in ContactsViewController");
            break;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


-(void) addContact
{
    NSLog(@"Adding new contact");
    AddFriendViewController *frndViewController = [AddFriendViewController alloc];
    frndViewController.frndDic = frndDic;
    frndViewController.pShrMgr = pShrMgr;
    frndViewController.state = eAddFrndStateAdd;
    frndViewController =  [frndViewController  initWithNibName:nil bundle:nil];
        
    [self.navigationController pushViewController:frndViewController animated:YES];
    return;
}

-(void) launchChatView
{
    NSLog(@"Creating new chat for contact");
    NSUInteger cnt = [frndDic count] +1;
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        NSNumber *numbr = [seletedItems objectAtIndex:i];
        if ([numbr boolValue] == YES)
        {
            FriendDetails *frnd = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:i-1]];
            if (frnd != nil)
            {
                [delegate launchChat:frnd];
                return;
            }
        }
        
    }
}

-(void) shareNow
{
    NSString *shareStr = [[NSString alloc] init];
    NSUInteger cnt = [frndDic count] +1;
    bool bFnd = false;
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        NSNumber *numbr = [seletedItems objectAtIndex:i];
        if ([numbr boolValue] == YES)
        {
            FriendDetails *frnd = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:i-1]];
            if (frnd != nil)
            {
                shareStr = [shareStr stringByAppendingString:frnd.name];
                shareStr = [shareStr stringByAppendingString:@";"];
                bFnd = true;
            }
        }
        
    }
    
    if (!bFnd)
        return;
    if (bTemplShare)
    {
        [delegate shareTemplList:shareStr];
    }
    else
    {
          [delegate shareNow:shareStr];
    }
    tabBarController.selectedIndex = 0;
    eViewCntrlMode = eModeContactsMgmt;
    if (bTemplShare)
    {
        [delegate refreshTemplShareMainLst];
    }
    else
    {
        [delegate refreshShareMainLst];
    }
   
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) changeSelectionForShareToSelected:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
    [self.tableView cellForRowAtIndexPath:indexPath];
    UITextField *textField = (UITextField *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG];
    NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
    if ([numbr boolValue] == YES)
    {
        
        [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u2705" withString: @"\u2B1C"];
    }
    else
    {
        textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u2B1C" withString:@"\u2705" ];
        
        [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        NSUInteger cnt = [seletedItems  count];
        for (NSUInteger i=1; i < cnt; ++i)
        {
            if (i == indexPath.row)
            {
                continue;
            }
            NSNumber* othr_row_no = [seletedItems objectAtIndex:i];
            if ([othr_row_no boolValue] == YES)
            {
                UITableViewCell *othr_row_cell =
                [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                 UITextField *textField = (UITextField *)[othr_row_cell.contentView viewWithTag:SELECTION_INDICATOR_TAG];
                textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u2705" withString: @"\u2B1C"];
                [seletedItems replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:NO]];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Number of contacts %lu %s %d", 1 + [frndDic count], __FILE__, __LINE__);
    return 1 + [frndDic count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"ContactVwCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        int cnt = (int)[pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    // Configure the cell...
    
    if (!indexPath.row)
    {
        cell.textLabel.text = @"ME";
        if (eViewCntrlMode == eModeContactsMgmt)
        {
          cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    else
    {
        NSUInteger row = indexPath.row;
        FriendDetails *item = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:row-1]];
        NSString *labtxt;
        if (item != nil)
        {
            if (item.nickName != nil && [item.nickName length]>0)
            {
                labtxt = item.nickName;
            }
            else
            {
                labtxt  = item.name ;
            }
        }
        if (eViewCntrlMode != eModeContactsMgmt)
        {
            NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
            if ([numbr boolValue] == YES)
            {
                cell.textLabel.text = @"\u2705";
            }
            else
            {
                cell.textLabel.text = @"\u2B1C";
            }
            cell.textLabel.text = [cell.textLabel.text stringByAppendingString:labtxt];
            cell.textLabel.tag = SELECTION_INDICATOR_TAG;
            
        }
        else
        {
            cell.textLabel.text = labtxt;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    }
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    if (eViewCntrlMode == eModeShareToSelected)
    {
        UITableViewCell *cell =
        [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField = (UITextField *)[cell.contentView viewWithTag:SELECTION_INDICATOR_TAG];
        NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
        if ([numbr boolValue] == YES)
        {
            
            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:NO]];
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u2705" withString: @"\u2B1C"];
        }
        else
        {
            textField.text = [textField.text stringByReplacingOccurrencesOfString:@"\u2B1C" withString:@"\u2705" ];
            
            [seletedItems replaceObjectAtIndex:indexPath.row withObject:[NSNumber numberWithBool:YES]];
        }
        
        return;
    }
    else if (eViewCntrlMode == eModeSelectToShare)
    {
        [self changeSelectionForShareToSelected:indexPath];
        return;
    }
    AddFriendViewController *frndViewController = [AddFriendViewController alloc];
    frndViewController.frndDic = frndDic;
    
    if (!indexPath.row)
    {
        frndViewController.userName = share_id_str;
        frndViewController.nickName = @"ME";
        frndViewController.bCanDelete = false;
    }
    else
    {
        FriendDetails *item = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.row-1]];
        frndViewController.userName = item.name;
        frndViewController.bCanDelete = true;
        if (item.nickName != nil)
            frndViewController.nickName = item.nickName;
    }
    
    frndViewController =  [frndViewController  initWithNibName:nil bundle:nil];
    frndViewController.state = eAddFrndStateDisplay;
    frndViewController.pShrMgr = pShrMgr;
    
    [self.navigationController pushViewController:frndViewController animated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
