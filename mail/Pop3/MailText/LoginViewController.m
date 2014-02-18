//
//  LoginViewController.m
//  MailText
//
//  Created by gao wenjian on 13-9-5.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "LoginViewController.h"
#import "Util.h"

#import "ReceiveViewController.h"

#import "AppDelegate.h"

#import "MCOMessageView.h"



@interface LoginViewController ()
{
    UIView *_serverView;
}
@end

@implementation LoginViewController



- (void)dealloc {
    
    [_serverView release];
    [_userName release];
    [_pwd release];
    [_remeberPwdBtn release];
    [_autoBtn release];
    [_serverTypeBtn release];
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
   
    if ([[Util getObjFromUserDefualt:IS_REMBER_PWD] isEqualToString:@"1"]){
            self.remeberPwdBtn.selected = YES;
        [self.userName setText:[Util getObjFromUserDefualt:SENDER]];
        [self.pwd setText:[Util getObjFromUserDefualt:SENDER_PWD]];
    }
    
    
    if (![Util getObjFromUserDefualt:SENDER_SERVER]) {
        [Util updateUserDefualt:ZH_POP3_RECEIVER key:RECEIVE_SERVER];
        [Util updateUserDefualt:ZH_POP3_SERVER key:SENDER_SERVER];
        [Util updateUserDefualt:[NSNumber numberWithInteger:ZH_POP3_SERVER_PORT] key:SENDER_PORT];
    }
    
      NSString *senders = [Util getObjFromUserDefualt:SENDER_SERVER];
    if ([[Util getObjFromUserDefualt:IS_AUTO_LOGIN] isEqualToString:@"1"]) {
        self.autoBtn.selected = YES;
        if ([senders isEqualToString:ZH_POP3_SERVER]) {
            
            MCOPOPSession *popSession = [[AppDelegate getDelegate] popSession];
            [popSession setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
            [popSession setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
            [popSession setUsername:[Util getObjFromUserDefualt:SENDER]];
            [popSession setPassword:[Util getObjFromUserDefualt:SENDER_PWD]];
            [self jumpMainWithType:TYPEPOP];
        }else
        {
            MCOIMAPSession *imapSession = [[AppDelegate getDelegate] imapSession];
            [imapSession setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
            [imapSession setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
            [imapSession setUsername:[Util getObjFromUserDefualt:SENDER]];
            [imapSession setPassword:[Util getObjFromUserDefualt:SENDER_PWD]];
            [self jumpMainWithType:TYPEIMAP];
            
        }
        
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *senders = [Util getObjFromUserDefualt:SENDER_SERVER];
    if ([senders isEqualToString:ZH_POP3_SERVER]) {
        [self.serverTypeBtn setTitle:@"纵横随心邮" forState:UIControlStateNormal];
    }else if([senders isEqualToString:QQ_IMAP_SERVER])
    {
        [self.serverTypeBtn setTitle:@"QQ邮箱" forState:UIControlStateNormal];
    }else
    {
        [self.serverTypeBtn setTitle:@"163网易免费邮" forState:UIControlStateNormal];
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}


- (void)viewDidUnload {
    [self setUserName:nil];
    [self setPwd:nil];
    [self setRemeberPwdBtn:nil];
    [self setAutoBtn:nil];
    [self setServerTypeBtn:nil];
    [super viewDidUnload];
}

- (IBAction)login:(id)sender
{
    
    [self.userName resignFirstResponder];
    [self.pwd resignFirstResponder];
    
    NSLog(@"ser %@ %@" ,[Util getObjFromUserDefualt:SENDER_SERVER],[Util getObjFromUserDefualt:SENDER_PORT]);
    
    if (self.userName.text.length == 0) {
        
        [Util showTipsLabels:self.view setMsg:@"用户名不能为空" setOffset:0];
        return;
    }
    
    if (self.pwd.text.length == 0) {
        
        [Util showTipsLabels:self.view setMsg:@"密码不能为空" setOffset:0];
        return;
    }
    
    if ([[Util getObjFromUserDefualt:SENDER_SERVER] isEqualToString:ZH_POP3_SERVER]) {
        [[[AppDelegate getDelegate] popSession] setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
        [[[AppDelegate getDelegate] popSession] setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
        [[[AppDelegate getDelegate] popSession] setUsername:self.userName.text];
        [[[AppDelegate getDelegate] popSession] setPassword:self.pwd.text];
        
        MCOPOPOperation *op = [[[AppDelegate getDelegate] popSession] checkAccountOperation];
        [self showLoadingWithTips:@"正在登陆"];
        [op start:^(NSError *error) {
            NSLog(@"%@",[error userInfo]);
            [self hiddenHud];
            if (!error) {
                
                [Util updateUserDefualt:self.userName.text key:SENDER];
                [Util updateUserDefualt:self.pwd.text key:SENDER_PWD];
                [Util updateUserDefualt:@"1" key:LOGIN_STATU];
                [self jumpMainWithType:TYPEPOP];

            }else{
                [Util showTipsLabels:self.view setMsg:@"登陆失败" setOffset:0];
            }
        }];
    }else{
        [[[AppDelegate getDelegate] imapSession] setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
        [[[AppDelegate getDelegate] imapSession] setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
        [[[AppDelegate getDelegate] imapSession] setUsername:self.userName.text];
        [[[AppDelegate getDelegate] imapSession] setPassword:self.pwd.text];
        
        MCOIMAPOperation *op = [[[AppDelegate getDelegate] imapSession] checkAccountOperation];
        [self showLoadingWithTips:@"正在登陆"];
        [op start:^(NSError *error) {
            NSLog(@"%@",[error userInfo]);
            [self hiddenHud];
            if (!error) {
                
                [Util updateUserDefualt:self.userName.text key:SENDER];
                [Util updateUserDefualt:self.pwd.text key:SENDER_PWD];
                [Util updateUserDefualt:@"1" key:LOGIN_STATU];
                [self jumpMainWithType:TYPEIMAP];
                
            }else{
                [Util showTipsLabels:self.view setMsg:@"登陆失败" setOffset:0];
            }
        }];
    }
}

- (void)jumpMainWithType:(SessionType)type{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"loginsuccess" object:nil];
    
    if (self.isPresent) {
        [self dismissViewControllerAnimated:YES
                                 completion:^{
            
        }];
    }else{
        ReceiveViewController *viewController = nil;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            NSString *nibName = @"ViewController_iPhone";
            if (iPhone5) {
                nibName = @"ViewController_iPhone_5";
            }
            viewController = [[ReceiveViewController alloc] initWithNibName:nibName bundle:nil] ;
        } else {
            viewController = [[ReceiveViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
        }
        
        [viewController setRequestSessionType:type];
        
        UINavigationController *mainNav = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
        [viewController release];
        PPRevealSideViewController *revealController = [[[PPRevealSideViewController alloc] initWithRootViewController:mainNav] autorelease];
        [revealController setPanInteractionsWhenOpened:PPRevealSideInteractionContentView];
        [revealController setPanInteractionsWhenClosed:PPRevealSideInteractionContentView];
        [AppDelegate getDelegate].window.rootViewController = revealController;
        [[AppDelegate getDelegate].window  makeKeyAndVisible];

    }
}

- (IBAction)remberPwd:(UIButton *)sender
{
    self.remeberPwdBtn.selected = !self.remeberPwdBtn.selected;
    
    
    NSString *type = nil;
    if (self.remeberPwdBtn.selected) {
        type = @"1";
        [self saveAutoConfig:1];
    }else{
        type = @"0";
        [self saveAutoConfig:0];
    }
    
    [Util updateUserDefualt:type key:IS_REMBER_PWD];
}

- (IBAction)autoLogin:(id)sender
{
   
    self.autoBtn.selected = !self.autoBtn.selected;
    
    NSString *type = nil;
    if (self.autoBtn.selected) {
        self.remeberPwdBtn.selected = YES;
        type = @"1";
        [self saveAutoConfig:1];
        [Util updateUserDefualt:type key:IS_REMBER_PWD];
    }else{
        [self saveAutoConfig:0];
        self.remeberPwdBtn.selected = NO;
        type = @"0";
    }
    
    [Util updateUserDefualt:type key:IS_AUTO_LOGIN];
}

- (void)saveAutoConfig:(NSInteger)type
{
    if (self.userName.text.length == 0 || self.pwd.text.length == 0) {
        return;
    }
    
    if (type == 1) {
        [Util updateUserDefualt:self.userName.text key:SENDER];
        [Util updateUserDefualt:self.pwd.text key:SENDER_PWD];
    }else{
        [Util updateUserDefualt:@"" key:SENDER];
        [Util updateUserDefualt:@"" key:SENDER_PWD];
    }
   

}

- (IBAction)selectServer:(id)sender
{
    if (_serverView == nil) {
        _serverView = [[UIView alloc] initWithFrame:CGRectMake(self.serverTypeBtn.frame.origin.x, self.serverTypeBtn.frame.origin.y + self.serverTypeBtn.frame.size.height + 1, self.serverTypeBtn.frame.size.width, 44 * 3)];
        
        [_serverView setBackgroundColor:[UIColor lightGrayColor]];
        
        for (int i = 0; i<3; i++) {
            NSString *title = nil;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(3, 44 * i, self.serverTypeBtn.frame.size.width, 44)];
            [label setBackgroundColor:[UIColor clearColor]];
            if (i == 0) {
                title = @"纵横随心邮";
                
                UILabel *liner = [[UILabel alloc] initWithFrame:CGRectMake(0, label.frame.size.height, label.frame.size.width, 1)];
                [_serverView addSubview:liner];
                [liner release];
                
            }else if(i == 1){
                title = @"163网易免费邮";
                UILabel *liner = [[UILabel alloc] initWithFrame:CGRectMake(0, label.frame.size.height * 2, label.frame.size.width, 1)];
                [_serverView addSubview:liner];
                [liner release];

            }else{
                title = @"QQ邮箱";
            }
            [label setText:title];
            [label setFont:[UIFont systemFontOfSize:14]];
            [_serverView addSubview:label];
            [label release];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setFrame:label.frame];
            [btn addTarget:self action:@selector(changeServerTitle:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:i + 9000];
            [_serverView addSubview:btn];
            
        }
        
        [self.view addSubview:_serverView];
        [_serverView setHidden:YES];
    }
    
    [_serverView setHidden:!_serverView.hidden];
}

- (void)changeServerTitle:(UIButton *)btn
{
    switch (btn.tag) {
        case 9000:{
            [self.serverTypeBtn setTitle:@"纵横随心邮" forState:UIControlStateNormal];
            [Util updateUserDefualt:ZH_POP3_SERVER key:SENDER_SERVER];
            [Util updateUserDefualt:[NSNumber numberWithInteger:ZH_POP3_SERVER_PORT] key:SENDER_PORT];
            [[[AppDelegate getDelegate] popSession] setCheckCertificateEnabled:NO];
            [[[AppDelegate getDelegate] popSession] setConnectionType:MCOConnectionTypeClear];
            
            [Util updateUserDefualt:ZH_IMAP_RECEIVER key:RECEIVE_SERVER];
        }
            break;
        case 9001:{
            [self.serverTypeBtn setTitle:@"163网易免费邮" forState:UIControlStateNormal];
            [Util updateUserDefualt:WY_IMAP_SERVER key:SENDER_SERVER];
            [Util updateUserDefualt:[NSNumber numberWithInteger:WY_IMAP_SERVER_PORT] key:SENDER_PORT];
            [[[AppDelegate getDelegate] imapSession] setCheckCertificateEnabled:YES];
            [[[AppDelegate getDelegate] imapSession] setConnectionType:MCOConnectionTypeTLS];
            
            [Util updateUserDefualt:WY_IMAP_RECEIVER key:RECEIVE_SERVER];

        }
            break;
        case 9002:{
            [self.serverTypeBtn setTitle:@"QQ邮箱" forState:UIControlStateNormal];
            [Util updateUserDefualt:QQ_IMAP_SERVER key:SENDER_SERVER];
            [Util updateUserDefualt:[NSNumber numberWithInteger:QQ_IMAP_SERVER_PORT] key:SENDER_PORT];
            [[[AppDelegate getDelegate] imapSession] setCheckCertificateEnabled:YES];
            [[[AppDelegate getDelegate] imapSession] setConnectionType:MCOConnectionTypeTLS];
            
            [Util updateUserDefualt:QQ_IMAP_RECEIVER key:RECEIVE_SERVER];

        }
            break;
            
        default:
            break;
    }
    [_serverView setHidden:YES];
}

#pragma mark textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         CGRect frame = self.view.frame;
                         frame.origin.y = -100;
                         [self.view setFrame:frame];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:.3
                     animations:^{
                         
                         CGRect frame = self.view.frame;
                         frame.origin.y = 0;
                         [self.view setFrame:frame];
                     }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

#pragma mark touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userName resignFirstResponder];
    [self.pwd resignFirstResponder];
}

#pragma mark 处理旋屏
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    NSLog(@"[[UIDevice currentDevice] model] = %@",[[UIDevice currentDevice] model]);
    
    if ([[[UIDevice currentDevice] model] isEqualToString:@"iPhone"]) {
        if (toInterfaceOrientation == UIInterfaceOrientationMaskPortrait) {
            return YES;
        }else
            return NO;
    }else{
        return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    }
}

#else

- (NSUInteger)supportedInterfaceOrientations
{
    NSLog(@"[[UIDevice currentDevice] model] = %@",[[UIDevice currentDevice] model]);
    
    return UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

- (BOOL)shouldAutorotate
{
    return YES;
}


#endif
@end
