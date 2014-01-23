//
//  ReceiveBiz.h
//  MailText
//
//  Created by gao wenjian on 14-1-16.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceiveBiz : NSObject

- (NSArray *)getPop3Mail;

- (void)savePop3ReceiveMail:(NSArray *)datas;

- (void)updateMailData:(NSString *)uid readFlag:(NSString *)flag;
@end
