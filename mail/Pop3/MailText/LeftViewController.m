//
//  BaseViewController.h
//  MailText
//
//  Created by gao on 13-9-3.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "LeftViewController.h"
#import "SendMailViewController.h"
#import "SetMailViewController.h"
#import "ReceiveViewController.h"
#import "AppDelegate.h"
#import "LeftCell.h"

#import "RubbishBoxViewController.h"
#import "TempSendBoxViewController.h"
#import "SendBoxViewController.h"
#import "Util.h"

#import "LoginViewController.h"



@interface LeftViewController ()
{
    NSArray *_titleArray;
 
    UINavigationController *_navSend;
    UINavigationController *_navRubbishBox;
    UINavigationController *_navTempBox;
    UINavigationController *_navSendBox;
    UINavigationController *_navSet;
    
}
@end

@implementation LeftViewController

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginsuccess" object:nil];
    
    [_navRubbishBox release];
    if (_navTempBox) {
        [_navTempBox release];
    }
    [_navSendBox release];
    [_navSet release];
    [_navSend release];
    [_titleArray release];
    [super dealloc];
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogin) name:@"loginsuccess" object:nil];
    
//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
//    if ( IOS7_OR_LATER )
//    {
//        self.edgesForExtendedLayout = UIRectEdgeNone;
//        self.extendedLayoutIncludesOpaqueBars = NO;
//        self.modalPresentationCapturesStatusBarAppearance = NO;
//        self.navigationController.navigationBar.translucent = NO;
//    }
//#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000

    _titleArray = [[NSArray alloc] initWithObjects:@"收件箱",@"发件箱",@"编写邮件",@"草稿箱",@"垃圾箱",@"设置",@"注销",nil];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.tableView.frame];
    [self.tableView setBackgroundColor:[UIColor darkGrayColor]];
    [self.tableView setBackgroundView:bg];
    [bg release];
    
    [self.tableView setSeparatorColor:[UIColor lightGrayColor]];
    
    [self.tableView setScrollEnabled:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)handleLogin
{
    [self.revealSideViewController popViewControllerWithNewCenterController:self.receiv
                                                                   animated:NO
                                                                 completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _titleArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 13, tableView.frame.size.width, 31)];
    [bg setBackgroundColor:[UIColor clearColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 5 + 13, 300, 21)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:@"功能菜单"];
    [label setTextColor:[UIColor whiteColor]];
    [bg addSubview:label];
    [label setFont:[UIFont systemFontOfSize:14]];
    [label release];
    
    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(0, 31 + 15, 320, 1)];
    [bg addSubview:la];
    [la setBackgroundColor:[UIColor lightGrayColor]];
    [la release];
    
    return [bg autorelease];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    LeftCell *cell = (LeftCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"LeftCell" owner:nil options:nil] lastObject];
        [cell setBackgroundColor:[UIColor darkGrayColor]];
    }
    
    [cell.headerImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"left_%d",indexPath.row + 1]]];
    
    cell.titleLabel.text = [_titleArray objectAtIndex:indexPath.row];

    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        
//        [self.revealSideViewController popViewControllerWithNewCenterController:[[AppDelegate getDelegate] mainNav]
//                                                                       animated:YES
//                                                                     completion:NULL];
        
        [self.revealSideViewController popViewControllerWithNewCenterController:self.receiv
                                                                       animated:YES
                                                                     completion:NULL];
      
    }else if (indexPath.row == 2) {
        if (!_navSend) {
            NSString *nibName = @"SendMailViewController";
            if (iPhone5) {
                nibName = @"SendMailViewController_5";
            }
            SendMailViewController *sendView = [[SendMailViewController alloc] initWithNibName:nibName bundle:nil];
            _navSend = [[UINavigationController alloc] initWithRootViewController:sendView];
            [sendView release];
        }
        [self.revealSideViewController popViewControllerWithNewCenterController:_navSend animated:YES];
    }else if (indexPath.row == 3 || indexPath.row == 4 || indexPath.row==1) {
//        if (!_navTempBox) {
//            TempSendBoxViewController *temp = [[TempSendBoxViewController alloc] init];
//            _navTempBox = [[UINavigationController alloc] initWithRootViewController:temp];
//            [temp release];
//        }
        
        [_navTempBox release];
        _navTempBox = nil;
        TempSendBoxViewController *tempS = [[TempSendBoxViewController alloc] init];

        if (indexPath.row == 1) {
            [tempS setShowType:SENDBOXMAIL];
        }
         if (indexPath.row == 3) {
             [tempS setShowType:TEMPMAIL];
        }
        
        if (indexPath.row == 4) {
            [tempS setShowType:RUBBISHMAIL];
        }
       
        _navTempBox =[[UINavigationController alloc] initWithRootViewController:tempS];
        [self.revealSideViewController popViewControllerWithNewCenterController:_navTempBox animated:YES];
        
        [tempS release];
    }
    else if (indexPath.row == 5) {
        if (!_navSet){
            SetMailViewController *setView = [[SetMailViewController alloc] init];
            _navSet = [[UINavigationController alloc] initWithRootViewController:setView];
            [setView release];
        }
        [self.revealSideViewController popViewControllerWithNewCenterController:_navSet animated:YES];
    }else if (indexPath.row == 6)
    {
//    
//        [self.revealSideViewController popViewControllerWithNewCenterController:self.receiv
//                                                                       animated:YES
//                                                                     completion:NULL];
        
        [[AppDelegate getDelegate] rebuilSessions];
        
        [Util updateUserDefualt:@"0" key:LOGIN_STATU];
        [Util updateUserDefualt:@"0" key:IS_AUTO_LOGIN];
        NSString *nibName = @"LoginViewController";
        if (IS_IPAD) {
            nibName = @"LoginViewController_ipad";
        }
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:nibName bundle:nil];
        login.isPresent = YES;
        [self presentViewController:login
                           animated:YES
                         completion:^{
        }];
        
        [login release];
        

    }

    
    
    
//    if (indexPath.row == 0) {
//
//        [self.revealSideViewController popViewControllerWithNewCenterController:[[AppDelegate getDelegate] mainNav]
//                                                                       animated:YES
//                                                                     completion:NULL];
//    }else if (indexPath.row == 1) {
//        if (!_navSendBox) {
//            SendBoxViewController *sendBoxView = [[SendBoxViewController alloc] init];
//            _navSendBox = [[UINavigationController alloc] initWithRootViewController:sendBoxView];
//            [sendBoxView release];
//        }
//        [self.revealSideViewController popViewControllerWithNewCenterController:_navSendBox animated:YES];
//    }else if (indexPath.row == 2) {
//        if (!_navSend) {
//            SendMailViewController *sendView = [[SendMailViewController alloc] init];
//            _navSend = [[UINavigationController alloc] initWithRootViewController:sendView];
//            [sendView release];
//        }
//        [self.revealSideViewController popViewControllerWithNewCenterController:_navSend animated:YES];
//    }else if (indexPath.row == 3) {
//        if (!_navTempBox) {
//            TempSendBoxViewController *temp = [[TempSendBoxViewController alloc] init];
//            _navTempBox = [[UINavigationController alloc] initWithRootViewController:temp];
//            [temp release];
//        }
//        [self.revealSideViewController popViewControllerWithNewCenterController:_navTempBox animated:YES];
//    }else if (indexPath.row == 4) {
//        if (!_navRubbishBox) {
//            RubbishBoxViewController *rubbish = [[RubbishBoxViewController alloc] init];
//            _navRubbishBox = [[UINavigationController alloc] initWithRootViewController:rubbish];
//            [rubbish release];
//        }
//        [self.revealSideViewController popViewControllerWithNewCenterController:_navRubbishBox animated:YES];
//    }
//    else if (indexPath.row == 5) {
//        if (!_navSet){
//           SetMailViewController *setView = [[SetMailViewController alloc] init];
//            _navSet = [[UINavigationController alloc] initWithRootViewController:setView];
//            [setView release];
//        }
//        [self.revealSideViewController popViewControllerWithNewCenterController:_navSet animated:YES];
//    }
}

@end
