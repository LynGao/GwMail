//
//  NSString+EncodingUTF8Additions.h
//  MailText
//
//  Created by gao wenjian on 14-1-23.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EncodingUTF8Additions)

-(NSString *) URLEncodingUTF8String;//编码
-(NSString *) URLDecodingUTF8String;//解码

@end
