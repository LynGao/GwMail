//
//  SendBiz.m
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "SendBiz.h"
#import "Util.h"

@implementation SendBiz


- (void)sendMail:(NSData *)mailData
         success:(sendSuccessBlock)success
            fail:(sendFailBlock)fail
{
    MCOSMTPSession *smtpSession = [[[MCOSMTPSession alloc] init] autorelease];
    smtpSession.hostname = [Util getObjFromUserDefualt:RECEIVE_SERVER];
    smtpSession.port = 465;
    smtpSession.username = [Util getObjFromUserDefualt:SENDER];
    smtpSession.password = [Util getObjFromUserDefualt:SENDER_PWD];
    
    NSLog(@"--- %@ %@ %@ ",[Util getObjFromUserDefualt:RECEIVE_SERVER],[Util getObjFromUserDefualt:SENDER],[Util getObjFromUserDefualt:SENDER_PWD]);
    smtpSession.connectionType = MCOConnectionTypeTLS;
    MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:mailData];
        [sendOperation start:^(NSError *error) {
            if(error) {
              
                NSLog(@"error %@",error);
                fail();
                
            } else {
                
                NSLog(@"%@ Successfully sent email!", @"jsdkjaskljdk");
                success();
            }
    }];

}

@end
