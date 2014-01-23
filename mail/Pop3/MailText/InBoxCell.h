//
//  InBoxCell.h
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <MailCore/MailCore.h>

@interface InBoxCell : UITableViewCell

@property (nonatomic, strong) MCOIMAPMessageRenderingOperation * messageRenderingOperation;

@property (retain, nonatomic) IBOutlet UIImageView *readFlagImage;
@property (retain, nonatomic) IBOutlet UILabel *senderLabel;
@property (retain, nonatomic) IBOutlet UILabel *dateLabel;
@property (retain, nonatomic) IBOutlet UILabel *mailTitleLabel;

@end
