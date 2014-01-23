//
//  LoginViewController.h
//  MailText
//
//  Created by gao wenjian on 13-9-5.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "BaseViewController.h"
#include <MailCore/MailCore.h>

@interface LoginViewController : BaseViewController<UITextFieldDelegate>
@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *pwd;
@property (retain, nonatomic) IBOutlet UIButton *remeberPwdBtn;
@property (retain, nonatomic) IBOutlet UIButton *autoBtn;
@property (retain, nonatomic) IBOutlet UIButton *serverTypeBtn;

@property (assign, nonatomic) BOOL isPresent;


@end
