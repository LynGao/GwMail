//
//  TempSendBoxViewController.m
//  MailText
//
//  Created by gao on 13-10-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "TempSendBoxViewController.h"
#import "InBoxCell.h"
#import "AppDelegate.h"
#import "Mail.h"
#import "ReadViewController.h"

@interface TempSendBoxViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_mainTable;
}
@property (nonatomic,retain) NSMutableArray *resultMailList;
@end

@implementation TempSendBoxViewController

-(void)dealloc
{
    self.resultMailList = nil;
    [_mainTable release];
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
	// Do any additional setup after loading the view.
    switch (self.showType) {
        case TEMPMAIL:
            self.title = @"草稿箱";
            break;
        case RUBBISHMAIL:
            self.title = @"垃圾箱";
            break;
        case SENDBOXMAIL:
            self.title = @"发件箱";
            break;
        default:
            break;
    }
    
    
    
    _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_mainTable setDelegate:self];
    [_mainTable setDataSource:self];
    [self.view addSubview:_mainTable];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDes = [NSEntityDescription entityForName:@"Mail" inManagedObjectContext:context];
    [request setEntity:entityDes];
    
    NSLog(@"self.show type = %d",self.showType);
    NSPredicate *condition = [NSPredicate predicateWithFormat:@"mail_type = %@",[NSNumber numberWithInteger:self.showType]];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"mail_date" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [sort release];
    
    [request setPredicate:condition];
    NSArray *array = [context executeFetchRequest:request error:NULL];
    [request release];
    [self.resultMailList removeAllObjects];
    self.resultMailList = [NSMutableArray arrayWithArray:array];
    [_mainTable reloadData];
    
    
}

#pragma mark tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
	if (self.resultMailList) {
        return self.resultMailList.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"inbox";
    InBoxCell *cell = (InBoxCell *)[tableView dequeueReusableCellWithIdentifier:identify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"InBoxCell" owner:nil options:nil]lastObject];
    }
    
    if (self.resultMailList.count > 0) {
        
        Mail *mail = [self.resultMailList objectAtIndex:indexPath.row];
        [cell.dateLabel setText:mail.mail_date];
        [cell.senderLabel setText:mail.mail_from];
        [cell.mailTitleLabel setText:mail.mail_title];
    }
    
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.resultMailList.count > 0) {
        
        Mail *mail = [self.resultMailList objectAtIndex:indexPath.row];
       
        NSString *nibName = @"ReadViewController";
        if (iPhone5) {
            nibName = @"ReadViewController_5";
        }
        ReadViewController *read = [[ReadViewController alloc] initWithNibName:nibName bundle:nil];
        [read setMail:mail];
        [read setShowType:self.showType];
        [self.navigationController pushViewController:read animated:YES];
        [read release];
    }
}
@end
