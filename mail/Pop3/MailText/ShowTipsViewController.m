//
//  ShowTipsViewController.m
//  MailText
//
//  Created by gao wenjian on 14-1-20.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import "ShowTipsViewController.h"

@interface ShowTipsViewController ()

@end

@implementation ShowTipsViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    UIAlertView *aler = [[UIAlertView alloc] initWithTitle:@"注意" message:@"由于用户已使用该软件超过35次。所以暂停使用，若有不便请联系开发者，谢谢！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [aler show];
    [aler release];
}

@end
