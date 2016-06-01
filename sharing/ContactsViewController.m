//
//  ContactsViewController.m
//  EasyGrocList
//
//  Created by Ninan Thomas on 11/11/15.
//  Copyright © 2015 Ninan Thomas. All rights reserved.
//

#import "ContactsViewController.h"
#import "FriendDetails.h"
#import "AddFriendViewController.h"


const NSInteger SELECTION_INDICATOR_TAG = 53322;

@interface ContactsViewController ()

@end

@implementation ContactsViewController

@synthesize frndDic;
@synthesize kchain;
@synthesize friendList;
@synthesize bModeShare;
@synthesize pShrMgr;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
        if (self)
        {
            bModeShare = false;
            seletedItems = [[NSMutableArray alloc] init];
            kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.sharing"];
        }

    
    return self;
}

-(void) populateData
{
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

    
    NSUInteger cnt = [frndDic count];
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        [seletedItemsTmp addObject:[NSNumber numberWithBool:NO]];
    }
    seletedItems = seletedItemsTmp;

    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *title = @"Contacts";
    self.navigationItem.title = [NSString stringWithString:title];
    [self populateData];
    [self.tableView reloadData];
    if (bModeShare)
    {
        UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(shareNow) ];
        self.navigationItem.rightBarButtonItem = pBarItem1;
        return;
    }
    UIBarButtonItem *pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addContact) ];
    self.navigationItem.rightBarButtonItem = pBarItem1;
    
}


-(void) addContact
{
    NSLog(@"Adding new contact");
    AddFriendViewController *frndViewController = [AddFriendViewController alloc];
    frndViewController.frndDic = frndDic;
    frndViewController.pShrMgr = pShrMgr;
    frndViewController =  [frndViewController  initWithNibName:nil bundle:nil];
        
    [self.navigationController pushViewController:frndViewController animated:YES];
    return;
}

-(void) shareNow
{
    NSString *shareStr = [[NSString alloc] init];
    NSUInteger cnt = [frndDic count];
    bool bFnd = false;
    for (NSUInteger i=0; i < cnt ; ++i)
    {
        NSNumber *numbr = [seletedItems objectAtIndex:i];
        if ([numbr boolValue] == YES)
        {
            FriendDetails *frnd = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:i]];
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
    
    [delegate shareNow:shareStr];
    return;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

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
        if (bModeShare)
        {
            NSNumber* numbr = [seletedItems objectAtIndex:indexPath.row];
            if ([numbr boolValue] == YES)
            {
                  cell.textLabel.text= @"\u2705ME";

            }
            else
            {
                cell.textLabel.text = @"\u2B1CME";   
            }

            
        }
        else
        {
            cell.textLabel.text = @"ME";
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
        if (bModeShare)
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
    
    if (bModeShare)
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
    AddFriendViewController *frndViewController = [AddFriendViewController alloc];
    frndViewController.frndDic = frndDic;
    
    if (!indexPath.row)
    {
        frndViewController.userName = share_id_str;
        frndViewController.nickName = @"ME";
    }
    else
    {
        FriendDetails *item = [rownoFrndDetail objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.row-1]];
        frndViewController.userName = item.name;
        if (item.nickName != nil)
            frndViewController.nickName = item.nickName;
    }
    
    frndViewController =  [frndViewController  initWithNibName:nil bundle:nil];
    
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
