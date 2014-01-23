//
//  Util.h
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface Util : NSObject

+(void)showTipsLabels:(UIView *)views setMsg:(NSString *)msg setOffset:(float)offset;


+ (void)updateUserDefualt:(id)obj key:(NSString *)key;

+ (id)getObjFromUserDefualt:(NSString *)key;

+ (NSString *)getFileAtDocumentPath:(NSString *)name;

+ (NSString *)stringFromDate:(NSDate *)date;

+(CGFloat)caculateTextLength:(NSString *)text FontSize:(float)fontSize ConstrainedWidth:(float)width;
@end
