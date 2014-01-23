//
//  SetMailViewController.m
//  MailText
//
//  Created by gwj on 13-8-21.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "SetMailViewController.h"
#import "Util.h"

@interface SetMailViewController ()
{
    UIScrollView *_scrollView;
    
    NSInteger _curTag1;
    NSInteger _curTag2;
    
    BOOL _isAutoLogin;
    BOOL _isRemeber;
}

@end

@implementation SetMailViewController

- (void) dealloc {

    [_scrollView release];
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
    
    self.title = @"设置";
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44 - 44)];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setShowsVerticalScrollIndicator:NO];
    [_scrollView setBackgroundColor:[UIColor clearColor]];
    
    [self.view addSubview:_scrollView];
    
    UILabel *titleLabel = [self createLabel:10 hight:21 font:16];
    [_scrollView addSubview:titleLabel];
    [titleLabel setText:@"常规"];

   
    //first
    UILabel *liner = [self createLabel:titleLabel.frame.size.height + titleLabel.frame.origin.y + 5 hight:1.0 font:14];
    [_scrollView addSubview:liner];
    [liner setBackgroundColor:[UIColor darkGrayColor]];
    UILabel *fistLabel = [self createLabel:liner.frame.size.height + liner.frame.origin.y + 10 hight:21 font:14];
    [fistLabel setText:@"是否记住密码，登陆时无需再输入"];
    [_scrollView addSubview:fistLabel];
    
    UIView *v1 = [self createChangeView:@selector(remberPwd:) orginY:fistLabel.frame.size.height + fistLabel.frame.origin.y + 3 tag:1000 title:@"是"];
    UIView *v2 = [self createChangeView:@selector(remberPwd:) orginY:v1.frame.size.height + v1.frame.origin.y + 3 tag:1001 title:@"否"];
    
    [_scrollView addSubview:v1];
    [_scrollView addSubview:v2];
    
    
    //secod
    UILabel *liner1 = [self createLabel:v2.frame.size.height + v2.frame.origin.y + 10 hight:1.0 font:14];
    [_scrollView addSubview:liner1];
    [liner1 setBackgroundColor:[UIColor darkGrayColor]];
    
    UILabel *fistLabel1 = [self createLabel:liner1.frame.size.height + liner1.frame.origin.y + 10 hight:21 font:14];
    [fistLabel1 setText:@"是否设置邮箱自动登陆"];
    [_scrollView addSubview:fistLabel1];
    
    UIView *v3 = [self createChangeView:@selector(remberAutoLogin:) orginY:fistLabel1.frame.size.height + fistLabel1.frame.origin.y + 3 tag:2000 title:@"是"];
    UIView *v4 = [self createChangeView:@selector(remberAutoLogin:) orginY:v3.frame.size.height + v3.frame.origin.y + 3 tag:2001 title:@"否"];
    
    [_scrollView addSubview:v3];
    [_scrollView addSubview:v4];
    
    //3
    UILabel *liner2 = [self createLabel:v4.frame.size.height + v4.frame.origin.y + 10 hight:1.0 font:14];
    [_scrollView addSubview:liner2];
    [liner2 setBackgroundColor:[UIColor darkGrayColor]];
    
    UILabel *fistLabel2 = [self createLabel:liner2.frame.size.height + liner2.frame.origin.y + 10 hight:21 font:14];
    [fistLabel2 setText:@"为了您的账号安全，请定期修改密码"];
    [_scrollView addSubview:fistLabel2];
    
    UIView *ip1 = [self createInput:@"账号" textFieldTag:3000 orginY:fistLabel2.frame.size.height + fistLabel2.frame.origin.y + 10 isPwd:NO];
    
    UIView *ip2 = [self createInput:@"密码" textFieldTag:3001 orginY:ip1.frame.size.height + ip1.frame.origin.y + 10 isPwd:YES];
    
    UIView *ip3 = [self createInput:@"确认密码" textFieldTag:3002 orginY:ip2.frame.size.height + ip2.frame.origin.y + 10 isPwd:YES];
    
    [_scrollView addSubview:ip1];
    [_scrollView addSubview:ip2];
    [_scrollView addSubview:ip3];
    
    //3
    UILabel *liner3 = [self createLabel:ip3.frame.size.height + ip3.frame.origin.y + 10 hight:1.0 font:14];
    [_scrollView addSubview:liner3];
    [liner3 setBackgroundColor:[UIColor darkGrayColor]];
    
    UILabel *fistLabel3 = [self createLabel:liner3.frame.size.height + liner3.frame.origin.y + 10 hight:21 font:14];
    [fistLabel3 setText:@"服务器设置"];
    [_scrollView addSubview:fistLabel3];
    
    UIView *ip4 = [self createInput:@"发送服务器"
                       textFieldTag:4000
                             orginY:fistLabel3.frame.size.height + fistLabel3.frame.origin.y + 10
                              isPwd:NO];
    
    UIView *ip5 = [self createInput:@"接收服务器" textFieldTag:4001 orginY:ip4.frame.size.height + ip4.frame.origin.y + 10 isPwd:NO];
    
    [_scrollView addSubview:ip4];
    [_scrollView addSubview:ip5];
    
    [_scrollView setContentSize:CGSizeMake(320, ip5.frame.size.height + ip5.frame.origin.y + 10)];
    
    //蓝色头部
    CGFloat orginY = IS_IPAD ? self.view.frame.size.width : self.view.frame.size.height;
    UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, orginY - 44 - 44 - 20, 320, 44)] autorelease];
    [headerView setBackgroundColor:[UIColor colorWithRed:LIGHT_BLUE_R / 255.0 green:LIGHT_BLUE_G / 255.0 blue:LIGHT_BLUE_B / 255.0 alpha:1.0]];

    UIButton *btnu = [[UIButton alloc] initWithFrame:CGRectMake(10, 11, 80, 25)];
    [btnu setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [btnu setTitle:@"保存修改" forState:UIControlStateNormal];
    [btnu.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btnu setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnu addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btnu];
    
    UIButton *btnu1 = [[UIButton alloc] initWithFrame:CGRectMake(95, 11, 50, 25)];
    [btnu1 setBackgroundImage:[UIImage imageNamed:@"button"] forState:UIControlStateNormal];
    [btnu1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnu1 setTitle:@"取消" forState:UIControlStateNormal];
    [btnu1.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [btnu1 addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:btnu1];
    
    [self.view addSubview:headerView];
    
    [self initalSeletStatu];
    
    UITextField *senderSer = (UITextField *)[_scrollView viewWithTag:4000];

    [senderSer setText:[Util getObjFromUserDefualt:SENDER_SERVER]];
    
    UITextField *receiver = (UITextField *)[_scrollView viewWithTag:4001];
    
    [receiver setText:[Util getObjFromUserDefualt:SENDER_SERVER]];
    

}

- (void)save
{
   
    
    _isRemeber ? [Util updateUserDefualt:@"1" key:IS_REMBER_PWD] : [Util updateUserDefualt:@"0" key:IS_REMBER_PWD];
    
     _isAutoLogin ? [Util updateUserDefualt:@"1" key:IS_AUTO_LOGIN] : [Util updateUserDefualt:@"0" key:IS_AUTO_LOGIN];
    
    
    UITextField *senderSer = (UITextField *)[_scrollView viewWithTag:4000];
    if (senderSer.text.length > 0) {
         [Util updateUserDefualt:senderSer.text key:SENDER_SERVER];
    }
    UITextField *receiver = (UITextField *)[_scrollView viewWithTag:4001];
    if (receiver.text.length > 0) {
        [Util updateUserDefualt:receiver.text key:RECEIVE_SERVER];
    }
   
    UITextField *name = (UITextField *)[_scrollView viewWithTag:3000];
    UITextField *pwd = (UITextField *)[_scrollView viewWithTag:3001];
    UITextField *confirmPwd = (UITextField *)[_scrollView viewWithTag:3002];
    if (pwd.text.length > 0 && confirmPwd.text.length > 0) {
        
        if (name.text.length == 0) {
             [Util showTipsLabels:self.view setMsg:@"用户名不能为空" setOffset:0];
                    return;
        }
        
        if (pwd.text == 0 ) {
             [Util showTipsLabels:self.view setMsg:@"密码不能为空" setOffset:0];
                    return;
        }
        
        if (confirmPwd.text == 0 ) {
            [Util showTipsLabels:self.view setMsg:@"确认密码不能为空" setOffset:0];
                    return;
        }
        
        if (![pwd.text isEqualToString:confirmPwd.text]) {
            [Util showTipsLabels:self.view setMsg:@"确认密码与密码不相同" setOffset:0];
                    return;
        }
        
        if (name.text.length > 0 && [pwd.text isEqualToString:confirmPwd.text]) {
            [Util updateUserDefualt:name.text key:SENDER];
            [Util updateUserDefualt:pwd.text key:SENDER_PWD];
        }
    }else{
         [Util showTipsLabels:self.view setMsg:@"保存失败，请检查用户名和密码是否未空" setOffset:0];
        return;
    }
    

    [Util showTipsLabels:self.view setMsg:@"保存成功" setOffset:0];
    
}

- (void)cancle
{
    
}

- (void)initalSeletStatu
{
    if ([[Util getObjFromUserDefualt:IS_AUTO_LOGIN] isEqualToString:@"1"]) {
        UIButton *btns = (UIButton *)[_scrollView viewWithTag:2000];
        [btns setSelected:YES];
    }else{
        UIButton *btns = (UIButton *)[_scrollView viewWithTag:2001];
        [btns setSelected:YES];
    }
    
    if ([[Util getObjFromUserDefualt:IS_REMBER_PWD] isEqualToString:@"1"]) {
        UIButton *btns = (UIButton *)[_scrollView viewWithTag:1000];
        [btns setSelected:YES];
    }else{
        UIButton *btns = (UIButton *)[_scrollView viewWithTag:1001];
        [btns setSelected:YES];
    }
}

- (void)remberPwd:(UIButton *)btn
{
    
    if (btn.tag == 1000 || btn.tag == 1001) {
        
        if (_curTag1 == btn.tag) {
            _curTag1 = btn.tag;
            return;
        }
        
        _curTag1 = btn.tag;
        btn.selected = !btn.selected;
        
//        btn.selected ? [Util updateUserDefualt:@"1" key:IS_REMBER_PWD] : [Util updateUserDefualt:@"0" key:IS_REMBER_PWD];
        
        if(btn.selected)
            _isRemeber = YES;
        else
            _isRemeber = NO;
        
        if (btn.tag == 1000) {
            UIButton *btns = (UIButton *)[_scrollView viewWithTag:1001];
            [btns setSelected:!btn.selected];
            
        }else{
            UIButton *btns = (UIButton *)[_scrollView viewWithTag:1000];
            [btns setSelected:!btn.selected];
        }

    }
    
}

- (void)remberAutoLogin:(UIButton *)btn
{
     if (btn.tag == 2000 || btn.tag == 2001) {
         
         if (_curTag2 == btn.tag) {
             _curTag2 = btn.tag;
             return;
         }
         
         _curTag2 = btn.tag;
         btn.selected = !btn.selected;
        
//         btn.selected ? [Util updateUserDefualt:@"1" key:IS_AUTO_LOGIN] : [Util updateUserDefualt:@"0" key:IS_AUTO_LOGIN];
         
         if(btn.selected)
             _isAutoLogin = YES;
         else
             _isAutoLogin = NO;
         
        
        if (btn.tag == 2000) {
            UIButton *btns = (UIButton *)[_scrollView viewWithTag:2001];
            [btns setSelected:!btn.selected];
            
        }else{
            UIButton *btns = (UIButton *)[_scrollView viewWithTag:2000];
            [btns setSelected:!btn.selected];
        }
     }
}

- (UIView *)createInput:(NSString *)title textFieldTag:(NSInteger)tag orginY:(CGFloat)y isPwd:(BOOL)isPwd;
{

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 21)];
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [Util caculateTextLength:title FontSize:14 ConstrainedWidth:1000], 21)];
    [l setFont:[UIFont systemFontOfSize:14]];
    [l setText:title];
    [l setBackgroundColor:[UIColor clearColor]];
    [v addSubview:l];
    [l release];
    
    UITextField *inputs = [[UITextField alloc] initWithFrame:CGRectMake(l.frame.origin.x + l.frame.size.width + 2, 0, 200, 21)];
    [inputs setTag:tag];
    [inputs setDelegate:self];
    [inputs setFont:[UIFont systemFontOfSize:14]];
    if (isPwd) {
        [inputs setSecureTextEntry:YES];
    }
//    [inputs setBorderStyle:UITextBorderStyleLine];
    [inputs setBackground:[UIImage imageNamed:@"login_input"]];
    [inputs setDelegate:self];
    [inputs setReturnKeyType:UIReturnKeyDone];
    [v addSubview:inputs];
    [inputs release];
    
    if (tag == 3000) {
        [inputs setText:[Util getObjFromUserDefualt:SENDER]];
        
    }
    
    if (tag == 3001) {
        [inputs setText:[Util getObjFromUserDefualt:SENDER_PWD]];
        
    }

    if (tag == 3002) {
        [inputs setText:[Util getObjFromUserDefualt:SENDER_PWD]];
        
    }

    
    
    return [v autorelease];
}

- (UILabel *)createLabel:(CGFloat)orginY hight:(CGFloat)hight font:(CGFloat)fontsize
{
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, orginY, 300, hight)];
    [titleLabel setFont:[UIFont systemFontOfSize:fontsize]];
    return [titleLabel autorelease];
}

- (UIView *)createChangeView:(SEL)seltor orginY:(CGFloat)y tag:(NSInteger)tag title:(NSString *)title
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, y, 300, 22)];
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setFrame:CGRectMake(0, 0, 22, 22)];
    [btn1 setImage:[UIImage imageNamed:@"unSelected"] forState:UIControlStateNormal];
    [btn1 setImage:[UIImage imageNamed:@"select"] forState:UIControlStateSelected];
    [btn1 setTag:tag];
    [v addSubview:btn1];
    [btn1 addTarget:self action:seltor forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setFrame:CGRectMake(24, 0, 22, 22)];
    [btn2 setTitle:title forState:UIControlStateNormal];
    [btn2.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [btn2 addTarget:self action:seltor forControlEvents:UIControlEventTouchUpInside];
    [btn2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [btn2 setTag:tag + 1];
    [v addSubview:btn2];
    
   
    return [v autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0 - 210;
        [self.view setFrame:frame];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self.view setFrame:frame];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.3 animations:^{
        CGRect frame = self.view.frame;
        frame.origin.y = 0;
        [self.view setFrame:frame];
    }];

    return YES;
}
@end
