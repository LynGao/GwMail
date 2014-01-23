//
//  AppConstant.h
//  GCZaker
//
//  Created by gao on 13-8-23.
//  Copyright (c) 2013年 gao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppConstant : NSObject

//定义url
#define URL_ROOT @"http://yxdntcgcom.s121.000pc.net/"

//设置0则屏蔽所有log输出
#if 1
#define GWLog(s,...)NSLog(@"<%p %@:(%d)> %@",self,[[NSString stringWithUTF8String:__FILE__]lastPathComponent],__LINE__,[NSString stringWithFormat:(s),##__VA_ARGS__])
#else
#define GWLog(s,...)
#endif

//iphone5判断
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//ios 7
#define IOS7_OR_LATER   ( [[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending )
#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define ORGINECOLOR_R 230.0
#define ORGINECOLOR_G 86.0
#define ORGINECOLOR_B 7.0

#define LIGHT_BLUE_R 180.0
#define LIGHT_BLUE_G 208.0
#define LIGHT_BLUE_B 240.0

#define LIGHT_GREEN_R 104.0
#define LIGHT_GREEN_G 162.0
#define LIGHT_GREEN_B 16.0




//通知名称

//定义请求超时
#define kRequsetTimeOutSeconds 30.0f

//
#define WEB_IMG_BASE_TAG 10000



#define IS_AUTO_LOGIN @"IS_AUTO_LOGIN"
#define IS_REMBER_PWD @"reberPwd"
#define LOGIN_STATU @"loginStatu"

#define RECEIVE_SERVER @"recieiver"
#define SENDER_SERVER @"senderServer"
#define SENDER @"sender"
#define SENDER_PWD @"senderPWd"
#define SENDER_PORT @"port"

#define ZH_IMAP_SERVER @"mail.zhnet.net"
#define ZH_IMAP_SERVER_PORT 143
#define ZH_IMAP_RECEIVER @"mail.zhnet.net"

#define QQ_IMAP_SERVER @"imap.qq.com"
#define QQ_IMAP_SERVER_PORT 993
#define QQ_IMAP_RECEIVER @"smtp.qq.com"

#define WY_IMAP_SERVER @"imap.163.com"
#define WY_IMAP_SERVER_PORT 993
#define WY_IMAP_RECEIVER @"smtp.163.com"

#define ZH_POP3_SERVER @"mail.zhnet.net"
#define ZH_POP3_SERVER_PORT 110
#define ZH_POP3_RECEIVER @"mail.zhnet.net"


/*************************** 定义枚举 ***********************/
typedef enum {
    TYPEIMAP = 0,
    TYPEPOP = 1
}SessionType;

typedef enum
{
    TEMPMAIL = 0,
    RUBBISHMAIL = 1,
    SENDBOXMAIL = 2
}MailSaveType;

@end
