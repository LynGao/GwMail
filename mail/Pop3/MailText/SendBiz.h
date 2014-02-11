//
//  SendBiz.h
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <MailCore/MailCore.h>

typedef void(^sendSuccessBlock)();

typedef void(^sendFailBlock)();

@interface SendBiz : NSObject

- (void)sendMail:(NSData *)mailData
         success:(sendSuccessBlock)success
            fail:(sendFailBlock)fail;

@end
