//
//  AddFriendViewController.m
//  Shopper
//
//  Created by Ninan Thomas on 7/2/13.
//
//

#import "AddFriendViewController.h"

#import "FriendDetails.h"
#import "ShareMgr.h"

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

@synthesize frndDic;
@synthesize  state;
@synthesize userName;
@synthesize nickName;
@synthesize displayMe;
@synthesize pShrMgr;
@synthesize bCanDelete;


//The states of AddFriendViewController
//Add a contact , edit a contact , display a contact
//Edit contact sub state delete a contact
//State transitions based on events
//SelectFriendViewController -> Add contact ->display contact
//SelectFriendViewController -> Add contact ->SelectFriend
//SelectFriendViewController->display contact->edit contact
//Edit contact->delete contact ->delete confirm

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        if (userName != nil)
            oldName = userName;
        kchain = [[SHKeychainItemWrapper alloc] initWithIdentifier:@"SharingData" accessGroup:@"3JEQ693MKL.com.rekhaninan.frndlst"];
        friendList = [kchain objectForKey:(__bridge id)kSecAttrComment];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSString *title;
    UIBarButtonItem *pBarItem = nil;
    UIBarButtonItem *pBarItem1 = nil;

    switch (state)
    {
        case eAddFrndStateAdd:
        {
          title = @"Add Contact";
        pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(contactsAddDone) ];
        pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(contactsAddCancel) ];
        }
        break;
            
        case eAddFrndStateDisplay:
        {
            title = @"Contact Details";
            if (bCanDelete)
            {
                pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(contactsEdit) ];
            }
        }
        break;
            
        case eAddFrndStateEdit:
        {
           title = @"Edit Contact";
            pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(contactsEditDone) ];
            pBarItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(contactsEditCancel) ];
        }
        break;
            
        default:
            break;
    }
    
    self.navigationItem.title = [NSString stringWithString:title];
    UITableViewHeaderFooterView *aTableViewHeaderFooterView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:@"AddFriendHeaderViewIdentifier"];
    
    [self.tableView registerClass:[aTableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"AddFriendHeaderViewIdentifier"];
    
    if (pBarItem !=nil)
        self.navigationItem.rightBarButtonItem = pBarItem;
    if (pBarItem1 != nil)
        self.navigationItem.leftBarButtonItem = pBarItem1;
   
    return;
    
}

-(void) deleteFriendInList
{
    
    NSArray* aFrndsArr = [friendList componentsSeparatedByString:@";"];
    NSInteger i = 0;
    NSInteger frndIndx = -1;
    NSString *newList = [[NSString alloc] init];
    for (NSString * frnd in  aFrndsArr)
    {
        if (frnd != nil && [frnd length] >0)
        {
            NSRange aR = [frnd rangeOfString:userName];
            if (aR.location == NSNotFound)
            {
                newList = [newList stringByAppendingFormat:@"%@;", frnd];
            }
            else
            {
                frndIndx = i;
                
            }
        }
        ++i;
    }
    
    if (frndIndx != -1)
    {
        friendList = newList;
        [kchain setObject:friendList forKey:(__bridge id)kSecAttrComment];
        [pShrMgr updateFriendList];
        
    }
}

-(void) contactsAddCancel
{
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

-(void) contactsEditCancel
{
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

-(void) setDisplayNavBar
{
    NSString* title = @"Contact Details";
    UIBarButtonItem* pBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(contactsEdit) ];
    self.navigationItem.title = title;
    self.navigationItem.rightBarButtonItem = pBarItem;
    self.navigationItem.leftBarButtonItem = nil;
    

    return;
}

-(void) contactsAddDone
{
    if (userName != nil)
    {
        FriendDetails *frndDet = [[FriendDetails alloc] init];
        frndDet.name  = userName;
        if (nickName != nil)
            frndDet.nickName =nickName;
        else
            frndDet.nickName = userName;
        [frndDic setObject:frndDet forKey:userName];
        state = eAddFrndStateDisplay;
        [self addFriendInList];
    }
    [self.navigationController popViewControllerAnimated:YES];
    return;
}

-(void) addFriendInList
{
    if (friendList != nil && [friendList length] > 0)
    {
        if (nickName != nil && [nickName length] >0)
        {
            friendList = [friendList stringByAppendingFormat:@"%@:%@;",userName,nickName];
        }
        else
        {
            friendList = [friendList stringByAppendingFormat:@"%@;",userName];
        }
    }
    else
    {
        if (nickName != nil && [nickName length] >0)
        {
            friendList = [NSString stringWithFormat:@"%@:%@;",userName, nickName];
        }
        else
        {
            friendList = [NSString stringWithFormat:@"%@;",userName];
        }
    }
    [kchain setObject:friendList forKey:(__bridge id)kSecAttrComment];
    [pShrMgr updateFriendList];

}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    NSLog(@"Clicked button at index %ld %s %d", (long)buttonIndex, __FILE__, __LINE__);
    if (buttonIndex == 0)
    {
        [self contactsEditDone];
    }
    
}
-(void) contactsEditDone
{
    if (userName != nil)
    {
        NSLog(@"Deleting contact %@ %s %d", userName, __FILE__, __LINE__);
        [frndDic removeObjectForKey:userName];
        [self deleteFriendInList];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
      [self.navigationController popViewControllerAnimated:YES];
    }
    return;
}


-(void) contactsEdit
{
    //printf("Launch UIActionSheet");
    NSLog(@"Touched delete contact button %s %d", __FILE__, __LINE__);
    UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil];
    [pSh showInView:self.tableView];
    [pSh setDelegate:self];
    
}

-(void) loadView
{
    [super loadView];
     CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
    CGRect tableRect = CGRectMake(0, 50, mainScrn.size.width, 430);
    UITableView *pTVw = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStyleGrouped];
    //[self.view insertSubview:self.pAllItms.tableView atIndex:1];
    self.tableView = pTVw;
    return;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    if (state == eAddFrndStateEdit)
        return 3;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section >= 2)
        return nil;
    static NSString *headerReuseIdentifier = @"AddFriendHeaderViewIdentifier";
    
    // Reuse the instance that was created in viewDidLoad, or make a new one if not enough.
    UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
    // Add any optional custom views of your own
    if (section ==0)
    {
        sectionHeaderView.textLabel.text = @"Share Id";
        
    }
    else
    {
        if (state == eAddFrndStateAdd)
        {
            sectionHeaderView.textLabel.text = @"Name (Optional)";
        }
        else
        {
            sectionHeaderView.textLabel.text = @"Name";
        }
    }
    
    return sectionHeaderView;
    
}

#pragma mark - TextField delegate , fns
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    
    [theTextField resignFirstResponder];
    
    return YES;
}



- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if (textField.tag == 2)
    {
        return YES;
    }
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
        
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return newLength <= 5;
}


-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    

    return YES;
}



- (void)textChanged:(id)sender
{
    UITextField *textField = (UITextField *)sender;
    UITableViewCell *cell = (UITableViewCell *)[[textField superview] superview];
    NSIndexPath *indPath = [self.tableView indexPathForCell:cell];
    
    if(indPath.section ==0)
    {
        userName = textField.text;
    }
    else if (indPath.section == 1)
    {
        nickName = textField.text;
    }
        
    return;
}





- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (buttonIndex == 1)
    {
        
        }
        else
        {
                    
    }

    return;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect mainScrn = [UIScreen mainScreen].applicationFrame;
    static NSString *CellIdentifier = @"AddFriendCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    else
    {
        NSArray *pVws = [cell.contentView subviews];
        NSUInteger cnt = [pVws count];
        for (NSUInteger i=0; i < cnt; ++i)
        {
            [[pVws objectAtIndex:i] removeFromSuperview];
        }
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    if (indexPath.section == 0 && indexPath.row ==0)
    {
        if (state == eAddFrndStateDisplay)
        {
            if (userName != nil)
                cell.textLabel.text = userName;
        }
        else
        {
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, mainScrn.size.width, 25)];
            NSLog(@"Textframe height %f", self.tableView.rowHeight);
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            if (userName != nil)
                textField.text = userName;
            textField.keyboardType = UIKeyboardTypeNumberPad;
            textField.userInteractionEnabled = YES;
            textField.tag = 1;
            [cell.contentView addSubview:textField];
        }
        
    }
    else if (indexPath.section == 1)
    {
        if (state == eAddFrndStateDisplay)
        {
            if (nickName != nil)
                cell.textLabel.text = nickName;
        }
        else
        {
            
            UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, mainScrn.size.width, 25)];
            textField.delegate = self;
            [textField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
            if (nickName != nil)
                textField.text = nickName;
            textField.tag = 2;
            [cell.contentView addSubview:textField];
        }
    }
    else if (indexPath.section == 2 && !indexPath.row && state == eAddFrndStateEdit)
    {
        cell.textLabel.text = @"Edit Contact";
    }
    
    
    return cell;
}




- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section <1)
        return 60.0;
    if (section == 1)
        return 70.0;
    
    return 30.0;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    if (state == eAddFrndStateEdit && indexPath.section == 2 && !indexPath.row)
    {
        UIActionSheet *pSh = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Contact" otherButtonTitles:nil];
        [pSh showInView:self.tableView];
        [pSh setDelegate:self];
    }
}

@end
