//
//  SendByMcoViewController.m
//  MailText
//
//  Created by gao wenjian on 14-2-10.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import "SendByMcoViewController.h"

@interface SendByMcoViewController ()

@end

@implementation SendByMcoViewController

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

    //    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    //    smtpSession.hostname = @"smtp.qq.com";
    //    smtpSession.port = 465;
    //    smtpSession.username = [Util getObjFromUserDefualt:SENDER];
    //    smtpSession.password = [Util getObjFromUserDefualt:SENDER_PWD];
    //    smtpSession.connectionType = MCOConnectionTypeTLS;
    //
    //    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    //    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:[Util getObjFromUserDefualt:SENDER]]];
    //    NSMutableArray *to = [[NSMutableArray alloc] init];
    //    //    for(NSString *toAddress in RECIPIENTS) {
    //            MCOAddress *newAddress = [MCOAddress addressWithMailbox:@"915288796@qq.com"];
    //            [to addObject:newAddress];
    //    //    }
    //    [[builder header] setTo:to];
    //    NSMutableArray *cc = [[NSMutableArray alloc] init];
    //    //    for(NSString *ccAddress in CC) {
    //    //        MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
    //    //        [cc addObject:newAddress];
    //    //    }
    ////    [[builder header] setCc:cc];
    //    NSMutableArray *bcc = [[NSMutableArray alloc] init];
    //    //    for(NSString *bccAddress in BCC) {
    //    //        MCOAddress *newAddress = [MCOAddress addressWithMailbox:bccAddress];
    //    //        [bcc addObject:newAddress];
    //    //    }
    ////    [[builder header] setBcc:bcc];
    //    [[builder header] setSubject:@"测试回复"];
    ////    [builder setHTMLBody:_messageView.htmlStrings];
    //    [builder setTextBody:@"哈哈哈 尼玛"];
    //    NSData * rfc822Data = [builder data];
    
    //    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
    //    [sendOperation start:^(NSError *error) {
    //        if(error) {
    //            //            NSLog(@"%@ Error sending email:%@", USERNAME, error);
    //            NSLog(@"error %@",error);
    //        } else {
    //                       NSLog(@"%@ Successfully sent email!", @"jsdkjaskljdk");
    //        }
    //    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
