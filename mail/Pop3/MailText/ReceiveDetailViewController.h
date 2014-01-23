//
//  ReceiveDetailViewController.h
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "BaseViewController.h"

#include <MailCore/MailCore.h>
@class MCOMessageView;
@class MCOIMAPAsyncSession;
@class MCOMAPMessage;

@interface ReceiveDetailViewController : BaseViewController
{
    IBOutlet MCOMessageView * _messageView;
    NSMutableDictionary * _storage;
    NSMutableSet * _pending;
    NSMutableArray * _ops;
    MCOIMAPSession * _session;
    MCOIMAPMessage * _message;
    NSMutableDictionary * _callbacks;
    NSString * _folder;
}

@property (nonatomic, copy) NSString * folder;
@property (nonatomic, strong) MCOIMAPSession * session;
@property (nonatomic, strong) MCOIMAPMessage * message;

@property (nonatomic, assign) SessionType requestSessionType;
@property (nonatomic, retain) MCOPOPSession *popSession;
@property (nonatomic, assign) unsigned int popIndex;
@end
