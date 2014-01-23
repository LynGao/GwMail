//
//  LeftCell.m
//  MailText
//
//  Created by gao on 13-9-25.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "LeftCell.h"

@implementation LeftCell

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
    [_headerImage release];
    [_titleLabel release];
    [super dealloc];
}
@end
