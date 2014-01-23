//
//  ReceiveViewController.m
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "ReceiveViewController.h"
#import "InBoxCell.h"
#import "ReceiveDetailViewController.h"
#import "LeftViewController.h"
#import "LoginViewController.h"
#import "Util.h"

#import "AppDelegate.h"
#import "ReceiveBiz.h"
#import "PopMail.h"
#import "NSString+EncodingUTF8Additions.h"

#define SIZEOFPAGE 20
#define UIDKEY @"uidKey"
#define POPHEADERKEY @"popHeaderKey"
#define POPINDEX @"popIndex"

@interface ReceiveViewController ()
{
    UIWebView *_web;
    NSInteger _totalMailCount;//总邮件
    UITableView *_mainTable;
    BOOL _isLoading;
    UILabel *_titleLable;
    NSInteger _unreadCount;
    
    NSInteger _curListCount;//当前信息的条数
    
    __block NSInteger reqeustCount;

}

@property (nonatomic, retain) __block NSMutableArray *resultMailList;
@property (nonatomic, retain) NSMutableDictionary *detailHadFormatDict;
@property (nonatomic, retain) NSMutableDictionary *readFlagDict;

@property (nonatomic, retain) __block NSMutableArray *containerMailList;//装载临时的邮件。
@end

@implementation ReceiveViewController

- (void)dealloc
{
    [_readFlagDict release];
    [_titleLable release];
    [_detailHadFormatDict release];
    [_mainTable release];
    [_resultMailList release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"收件箱";
    
    self.resultMailList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    self.readFlagDict = [[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
    
    self.containerMailList = [[[NSMutableArray alloc] initWithCapacity:0] autorelease];
    
    LeftViewController *left = [[[LeftViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    left.receiv = self.navigationController;
    [self.revealSideViewController preloadViewController:left forSide:PPRevealSideDirectionLeft];
    
    //蓝色头部
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    [headerView setBackgroundColor:[UIColor colorWithRed:LIGHT_BLUE_R / 255.0 green:LIGHT_BLUE_G / 255.0 blue:LIGHT_BLUE_B / 255.0 alpha:1.0]];
    
    _titleLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 13, 300, 21)];
    [_titleLable setText:@""];
    [_titleLable setFont:[UIFont systemFontOfSize:15.0]];
    [_titleLable setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:_titleLable];
    
    [self.view addSubview:headerView];
    [headerView release];
    

    CGFloat delta = -20;
   
    if (IS_IPAD) {
        delta = 20;
    }else{
        if (IOS7_OR_LATER) {
            delta = 0;
        }
    }
    _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height - 44 - 44 - delta) style:UITableViewStylePlain];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_mainTable setDelegate:self];
    [_mainTable setDataSource:self];
    [self.view addSubview:_mainTable];
    
    //初始化下拉刷新控件
    _refreshTableView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0 - _mainTable.bounds.size.height, self.view.frame.size.width, _mainTable.bounds.size.height)];
    [_refreshTableView setDelegate:self];
    //将下拉刷新控件作为子控件添加到UITableView中
    [_mainTable addSubview:_refreshTableView];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.requestSessionType == TYPEIMAP) {
        [[[AppDelegate getDelegate] popSession] setCheckCertificateEnabled:NO];
        [[[AppDelegate getDelegate] popSession] setConnectionType:MCOConnectionTypeTLS];
//        BOOL flag = NO;
        if (![[Util getObjFromUserDefualt:LOGIN_STATU] isEqualToString:@"1"]) {
//            flag = YES;
            NSString *nibName = @"LoginViewController";
            if (IS_IPAD) {
                nibName = @"LoginViewController_ipad";
            }
            LoginViewController *login = [[LoginViewController alloc] initWithNibName:nibName bundle:nil];
            login.isPresent = YES;
            [self presentModalViewController:login animated:NO];
            [login release];
        }else{
            if (!_isLoading && self.resultMailList.count == 0)
                [self loadReceiveMail:SIZEOFPAGE];
        }

    }else{

        [[[AppDelegate getDelegate] popSession] setCheckCertificateEnabled:NO];
        [[[AppDelegate getDelegate] popSession] setConnectionType:MCOConnectionTypeClear];
       
//        BOOL flag = NO;
        if (![[Util getObjFromUserDefualt:LOGIN_STATU] isEqualToString:@"1"]) {
//            flag = YES;
            NSString *nibName = @"LoginViewController";
            if (IS_IPAD) {
                nibName = @"LoginViewController_ipad";
            }
            LoginViewController *login = [[LoginViewController alloc] initWithNibName:nibName bundle:nil];
            login.isPresent = YES;
            [self presentModalViewController:login animated:NO];
            [login release];
        }else{
            if (!_isLoading && self.resultMailList.count == 0)
                [self loadPop3DetailMsg];
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadReceiveMail:(NSInteger)nMessages
{
    _isLoading = YES;
    [self showLoadingWithTips:@"获取邮件中..."];
    
     NSString *folder = @"INBOX";
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
	(MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindStructure |
	 MCOIMAPMessagesRequestKindInternalDate | MCOIMAPMessagesRequestKindHeaderSubject |
	 MCOIMAPMessagesRequestKindFlags);
    
    MCOIMAPFolderInfoOperation *inboxFolderInfo = [[[AppDelegate getDelegate] imapSession] folderInfoOperation:folder];
    [inboxFolderInfo start:^(NSError *error, MCOIMAPFolderInfo *info) {
        //记录是否新邮件
        BOOL totalNumberOfMessagesDidChange = _totalMailCount != [info messageCount];
        _totalMailCount = [info messageCount];
        NSUInteger numberOfMessagesToLoad =
		MIN(_totalMailCount, nMessages);
        if (numberOfMessagesToLoad == 0)
		{
			return;
		}
        
        if (_reloading) {
            _unreadCount = 0;
            [self.resultMailList removeAllObjects];
            [self doneLoadingTableViewData];
        }
        
        MCORange fetchRange;
        if (!totalNumberOfMessagesDidChange && self.resultMailList.count)
		{
			numberOfMessagesToLoad -= self.resultMailList.count;
			
			fetchRange =
			MCORangeMake(_totalMailCount -
						 self.resultMailList.count -
						 (numberOfMessagesToLoad - 1),
						 (numberOfMessagesToLoad - 1));
            
            NSLog(@"%d %d",_totalMailCount - self.resultMailList.count - numberOfMessagesToLoad + 1,numberOfMessagesToLoad - 1);
		}
		
		// Else just fetch the last N messages
		else
		{
			fetchRange =
			MCORangeMake(_totalMailCount -
						 (numberOfMessagesToLoad - 1),
						 (numberOfMessagesToLoad - 1));
            
            NSLog(@"%d %d",_totalMailCount - numberOfMessagesToLoad + 1,numberOfMessagesToLoad - 1);
		}

        
        MCOIMAPFetchMessagesOperation *fetchOperation = [[[AppDelegate getDelegate] imapSession] fetchMessagesByNumberOperationWithFolder:folder requestKind:requestKind numbers:[MCOIndexSet indexSetWithRange:fetchRange]];
        ;
        
        [fetchOperation start:^(NSError * error, NSArray * fetchedMessages, MCOIndexSet * vanishedMessages) {
            
            [self hiddenHud];
            if(error) {
               
                NSLog(@"error = %@",error);
                [Util showTipsLabels:self.view setMsg:@"邮件获取失败" setOffset:0];
                _isLoading = NO;
            }
            //排序
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"header.date" ascending:NO];
            NSMutableArray *combinedMessage = [NSMutableArray arrayWithArray:fetchedMessages];
            
            [self.resultMailList addObjectsFromArray:[combinedMessage sortedArrayUsingDescriptors:@[sort]]];
            
            //显示未读
            for (int i = 0; i< self.resultMailList.count; i++) {
                MCOIMAPMessage *message = self.resultMailList[i];
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                BOOL flag = message.flags;
                if (!flag){
                    [_readFlagDict setObject:@"0" forKey:uidKey];
                    _unreadCount++;
                }else{
                    [_readFlagDict setObject:@"1" forKey:uidKey];
                }
            }
            [self updateHadReadCount];
    
            [_mainTable reloadData];
        }];
    }];
}

- (void)updateHadReadCount
{
    [_titleLable setText:[NSString stringWithFormat:@"共 %d 封,其中未读邮件 %d 封",self.resultMailList.count,_unreadCount]];
}


#pragma mark ----------------- POP3 解析开始
/**
 *  获取pop3 邮件
 */
- (void)loadPop3DetailMsg
{
    [self showLoadingWithTips:@"获取邮件中..."];

    reqeustCount = 0;
    [self setTotalMailCount:-1];
    _unreadCount = 0;
    
    //1.先获取总的消息条数
    __block ReceiveViewController *weakSelf = self;
    
    MCOPOPSession *popsession = [[[MCOPOPSession alloc] init] autorelease];
    [popsession setCheckCertificateEnabled:NO];
    [popsession setConnectionType:MCOConnectionTypeClear];
    [popsession setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
    [popsession setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
    [popsession setUsername:[Util getObjFromUserDefualt:SENDER]];
    [popsession setPassword:[Util getObjFromUserDefualt:SENDER_PWD]];
    
//    MCOPOPFetchMessagesOperation *allMsgOP = [[[AppDelegate getDelegate] popSession] fetchMessagesOperation];
     MCOPOPFetchMessagesOperation *allMsgOP = [popsession fetchMessagesOperation];
    
    [allMsgOP start:^(NSError *error, NSArray *messages) {
        ReceiveViewController *strongSelf = weakSelf;
        if (!error) {
            
            //获取本地已读标识
            [self getPopReadFlag:messages];
           
            ReceiveBiz *biz = [[[ReceiveBiz alloc] init] autorelease];
            
            //保存邮件头，做本地缓存处理。
            [biz savePop3ReceiveMail:messages];
            
            if (_totalMailCount == -1)
            {
                [strongSelf setTotalMailCount:messages.count];
            }
            
            if (_totalMailCount <= SIZEOFPAGE) {
                _curListCount = _totalMailCount;
            }
            
            [strongSelf fetchMailList:messages];
        }else{
            NSLog(@"______ error %@",[error userInfo]);
            [Util showTipsLabels:self.view setMsg:@"获取邮件失败" setOffset:0.0f];
            [self hiddenHud];
            
        }
    }];
}

/**
 *  获取是否已读
 *
 *  @param datas MCOPOPMessageInfo objs
 */
- (void)getPopReadFlag:(NSArray *)datas
{
    ReceiveBiz *biz = [[[ReceiveBiz alloc] init] autorelease];
    NSArray *mailArray = [biz getPop3Mail];
    if (mailArray.count == 0) {
        for (MCOPOPMessageInfo *inof in datas) {
            [_readFlagDict setObject:@"0" forKey:inof.uid];
        }
        _unreadCount = datas.count;
    }else{
        for (MCOPOPMessageInfo *inof in datas) {
            NSString *uid = inof.uid;
            BOOL readFlag = NO;
            for (PopMail *mail in mailArray) {
                if ([mail.pop_uid isEqualToString:uid] && [mail.pop_readFlag isEqualToString:@"1"]) {
                    readFlag = YES;
                    [_readFlagDict setObject:@"1" forKey:uid];
                    break;
                }
            }
            
            if (!readFlag) {
                [_readFlagDict setObject:@"0" forKey:uid];
                _unreadCount++;
            }
        }
    }
}

- (void)fetchMailList:(NSArray *)messageInfoArray
{
    if (_reloading) {
        [self.containerMailList removeAllObjects];
    }
    
    for (int i = 1; i < messageInfoArray.count+1; i++) {
        //2.获取消息的头部，用于显示列表信息
        
        MCOPOPSession *popsession = [[[MCOPOPSession alloc] init] autorelease];
        [popsession setCheckCertificateEnabled:NO];
        [popsession setConnectionType:MCOConnectionTypeClear];
        [popsession setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
        [popsession setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
        [popsession setUsername:[Util getObjFromUserDefualt:SENDER]];
        [popsession setPassword:[Util getObjFromUserDefualt:SENDER_PWD]];
        MCOPOPFetchHeaderOperation *headerOP = [popsession fetchHeaderOperationWithIndex:i];
        
//        MCOPOPFetchHeaderOperation *headerOP = [[[AppDelegate getDelegate] popSession] fetchHeaderOperationWithIndex:i];
        __block ReceiveViewController *weakSelf = self;
        [headerOP start:^(NSError *error, MCOMessageHeader *header) {
            if (!error) {
                MCOPOPMessageInfo *info = [messageInfoArray objectAtIndex:i - 1];
                NSLog(@"*******)000-=---- date : %@",header.date);
                NSDictionary *dict = @{UIDKEY : [info uid],POPHEADERKEY : header,POPINDEX : [NSNumber numberWithUnsignedInt:info.index]};
//                [self.resultMailList addObject:dict];
                [self.containerMailList addObject:dict];
            }
            
            ReceiveViewController *strongSelf = weakSelf;
            [strongSelf caculteReslutCount];
            
        }];
        
    }
}

- (void)caculteReslutCount
{
    reqeustCount++;
    GWLog(@"%d",reqeustCount);
    
    if (reqeustCount == _totalMailCount) {
        [self hiddenHud];
        //排序
        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"popIndex" ascending:NO];
        
        self.resultMailList = [NSMutableArray arrayWithArray:[[NSMutableArray arrayWithArray:self.containerMailList] sortedArrayUsingDescriptors:@[sort]]];
        
        [self updateHadReadCount];
        
        if (_reloading) {
            [self doneLoadingTableViewData];
        }
        [_mainTable reloadData];
        
        
    }
}

/**
 *  设置总消息条数，用于加载更多
 *
 *  @param count 总的消息条数，当下拉刷新的时候，需要设置成 -1
 */
- (void)setTotalMailCount:(NSInteger)count
{
    _totalMailCount = count;
}

#pragma mark ----------------- POP3 结束

#pragma mark tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.resultMailList.count) {
        return 44;
    }
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
		
	if (self.resultMailList) {
        return self.resultMailList.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.resultMailList.count) {
        static NSString *loadMore = @"loadMore";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:loadMore];
        if (!cell) {
            
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:loadMore] autorelease];
            
            cell.textLabel.font = [UIFont boldSystemFontOfSize:14];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.detailTextLabel.textAlignment = NSTextAlignmentCenter;
            
        }
        
        if (self.resultMailList.count < _totalMailCount) {
            cell.textLabel.text = @"加载更多";
        }else{
            cell.textLabel.text = @"没有更多邮件了";
        }
        
        return cell;
    }else {
        static NSString *identify = @"inbox";
        InBoxCell *cell = (InBoxCell *)[tableView dequeueReusableCellWithIdentifier:identify];
        if (!cell) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"InBoxCell" owner:nil options:nil]lastObject];
        }
        if (self.resultMailList.count > 0) {
            
            if (self.requestSessionType == TYPEIMAP) {
                MCOIMAPMessage *message = self.resultMailList[indexPath.row];
                NSString *uidKey = [NSString stringWithFormat:@"%d", message.uid];
                
                NSString *flag = [_readFlagDict objectForKey:uidKey];
                if (![flag isEqualToString:@"0"]) {//未读
                    
                    [cell.readFlagImage setImage:[UIImage imageNamed:@"email_readed"]];
                }else
                {
                    [cell.readFlagImage setImage:[UIImage imageNamed:@"email_not_readed"]];
                }
                
                NSString *displayName = message.header.sender.displayName;
                [cell.dateLabel setText:[Util stringFromDate:message.header.date]];
                NSString *sender = nil;
                if (displayName) {
                    sender = [NSString stringWithFormat:@"%@%@",message.header.sender.displayName,message.header.sender.mailbox];
                }else{
                    sender = [NSString stringWithFormat:@"%@",message.header.sender.mailbox];
                }
                [cell.senderLabel setText:sender];
                [cell.mailTitleLabel setText:message.header.subject];

            }else{
                //* -------- pop3 -------------*//
                MCOMessageHeader *message = [self.resultMailList[indexPath.row] objectForKey:POPHEADERKEY];
                NSString *uid = [self.resultMailList[indexPath.row] objectForKey:UIDKEY];
                
                NSString *flag = [_readFlagDict objectForKey:uid];
                if (![flag isEqualToString:@"0"]) {//未读
                    
                    [cell.readFlagImage setImage:[UIImage imageNamed:@"email_readed"]];
                }else
                {
                    [cell.readFlagImage setImage:[UIImage imageNamed:@"email_not_readed"]];
                }

                
                [cell.dateLabel setText:[Util stringFromDate:message.date]];
                MCOAddress *address = message.from;
                NSString *mailBox = address.mailbox;
                NSString *sender = nil;
                sender = [NSString stringWithFormat:@"%@",mailBox];
                [cell.senderLabel setText:sender];
                NSLog(@"message.subject  = %@",[message.subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
                [cell.mailTitleLabel setText:[message.subject stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.requestSessionType == TYPEIMAP) {
        if (indexPath.row == self.resultMailList.count) {
            
            if (self.resultMailList.count < _totalMailCount) {
                _unreadCount = 0;
                [self loadReceiveMail:self.resultMailList.count + SIZEOFPAGE ];
            }
        }else{
            MCOIMAPMessage *msg = self.resultMailList[indexPath.row];
            ReceiveDetailViewController *vc = [[ReceiveDetailViewController alloc] init];
            vc.folder = @"INBOX";
            vc.message = msg;
            vc.session = [[AppDelegate getDelegate] imapSession];
            [self.navigationController pushViewController:vc animated:YES];
            [vc release];
            
            NSString *uidKey = [NSString stringWithFormat:@"%d", msg.uid];
            _unreadCount--;
            [_readFlagDict setObject:@"1" forKey:uidKey];
            InBoxCell *cell = (InBoxCell *)[tableView cellForRowAtIndexPath:indexPath];
            [cell.readFlagImage setImage:[UIImage imageNamed:@"email_readed"]];
            [self updateHadReadCount];
        }

    }else{
        
        if (indexPath.row == self.resultMailList.count) return;
        
        NSString *uid = [self.resultMailList[indexPath.row] objectForKey:UIDKEY];
        [_readFlagDict setObject:@"1" forKey:uid];
        
        if (_unreadCount > 0) {
            _unreadCount--;
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ReceiveBiz *biz = [[ReceiveBiz alloc] init];
                [biz updateMailData:uid
                           readFlag:@"1"];
                [biz release];
            });
        }
        
        [self updateHadReadCount];
        
        InBoxCell *cell = (InBoxCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell.readFlagImage setImage:[UIImage imageNamed:@"email_readed"]];
        
        ReceiveDetailViewController *vc = [[ReceiveDetailViewController alloc] init];
        vc.folder = @"INBOX";
        [vc setRequestSessionType:TYPEPOP];
        vc.popIndex = [[self.resultMailList[indexPath.row] objectForKey:POPINDEX] unsignedIntValue];
        vc.popSession = [[AppDelegate getDelegate] popSession];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];


    }
}

#pragma mark ego delegate methods
//根据方向，访问上拉或者下拉的访问请求。
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{

    [self reloadTableViewDataSource];

}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
    return [NSDate date];
}


- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
    return _reloading;
}


#pragma mark Data Source Loading / Reloading Methods
- (void)reloadTableViewDataSource{
	_reloading = YES;
    
    if (self.requestSessionType == TYPEIMAP) {
        [self loadReceiveMail:SIZEOFPAGE];
    }else{
        [self loadPop3DetailMsg];
    }
    
}



- (void)doneLoadingTableViewData{
	_reloading = NO;
	[_refreshTableView egoRefreshScrollViewDataSourceDidFinishedLoading:_mainTable];
    
}

#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    [_refreshTableView egoRefreshScrollViewDidScroll:scrollView];

}



- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    

    [_refreshTableView egoRefreshScrollViewDidEndDragging:scrollView];

    
}


@end
