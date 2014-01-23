//
//  BaseViewController.h
//  MailText
//
//  Created by gao on 13-9-3.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface BaseViewController : UIViewController<MBProgressHUDDelegate>

//显示loading
- (void)showLoadingWithTips:(NSString *)tips;

//隐藏loading
- (void)hiddenHud;

@end
