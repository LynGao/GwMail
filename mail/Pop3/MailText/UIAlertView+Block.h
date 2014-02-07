//
//  UIAlertView+Block.h
//  MailText
//
//  Created by gao wenjian on 14-2-7.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>

//
typedef void(^ClickConfirmBlock)(NSInteger buttonIndex);

@interface UIAlertView (Block)

- (void)showAlertViewWithBlock:(ClickConfirmBlock) alertBlock;
@end
