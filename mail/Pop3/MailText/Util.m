//
//  Util.m
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "Util.h"

@implementation Util

+(void)showTipsLabels:(UIView *)views setMsg:(NSString *)msg setOffset:(float)offset{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:views animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = msg;
	hud.margin = 10.0f;
	hud.yOffset = offset;
    hud.labelFont=[UIFont systemFontOfSize:13.0f];
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:1.5];
}

+ (void)updateUserDefualt:(id)obj key:(NSString *)key
{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    [defualt setObject:obj forKey:key];
    [defualt synchronize];
    
}

+ (id)getObjFromUserDefualt:(NSString *)key
{
    NSUserDefaults *defualt = [NSUserDefaults standardUserDefaults];
    return [defualt objectForKey:key];
}


+ (NSString *)getFileAtDocumentPath:(NSString *)name
{
    NSString *logFilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",name];
    return logFilePath;
}

+ (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formater = [[[NSDateFormatter alloc] init] autorelease];
    [formater setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    [formater setTimeZone:[NSTimeZone timeZoneWithName:@"shanghai"]];
    return  [formater stringFromDate:date];
}

+(CGFloat)caculateTextLength:(NSString *)text FontSize:(float)fontSize ConstrainedWidth:(float)width{
    
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 21.0f) lineBreakMode:UILineBreakModeWordWrap];
    return size.width;
}
@end
