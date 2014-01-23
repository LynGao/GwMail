//
//  ReadViewController.h
//  MailText
//
//  Created by gao on 13-10-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "BaseViewController.h"
#import "Mail.h"


@interface ReadViewController : BaseViewController<UIDocumentInteractionControllerDelegate,UIWebViewDelegate>

@property (nonatomic,retain) Mail *mail;
@property (nonatomic, assign) MailSaveType showType;

@property (retain, nonatomic) IBOutlet UIButton *firstBtn;
@property (retain, nonatomic) IBOutlet UIButton *secBtn;
@property (retain, nonatomic) IBOutlet UIButton *thirdBtn;


//
@property (retain, nonatomic) IBOutlet UITextField *targetText;
@property (retain, nonatomic) IBOutlet UIView *ccView;
@property (retain, nonatomic) IBOutlet UIImageView *ccbg;
@property (retain, nonatomic) IBOutlet UILabel *ccLabel;
@property (retain, nonatomic) IBOutlet UITextField *ccText;
@property (retain, nonatomic) IBOutlet UIButton *addBtn;
@property (retain, nonatomic) IBOutlet UIButton *ccsendBtn;

@end
