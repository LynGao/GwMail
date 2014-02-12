//
//  SendMailViewController.h
//  MailText
//
//  Created by gwj on 13-8-21.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKPSMTPMessage.h"
#import "BaseViewController.h"
@interface SendMailViewController : BaseViewController <UITextFieldDelegate,SKPSMTPMessageDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, assign) RelayType replayType;

@property (nonatomic, copy) NSString *innerText;

@property (nonatomic, copy) NSString *receiversString;//收件人数组

@property (nonatomic, copy) NSString *subjectString;

@end
