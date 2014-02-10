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

@property (nonatomic, retain) NSMutableArray *senderArray;//发件人数组

@property (nonatomic, assign) RelayType replayType;

@property (nonatomic, copy) NSString *innerText;

@end
