//
//  InBoxCell.m
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "InBoxCell.h"

@implementation InBoxCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [self.messageRenderingOperation cancel];
    [_readFlagImage release];
    [_senderLabel release];
    [_dateLabel release];
    [_mailTitleLabel release];
    [super dealloc];
}
@end
