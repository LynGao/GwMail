//
//  FjCell.m
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "FjCell.h"

@implementation FjCell

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
    [_fjListScroll release];
    [_fujImageView release];
    [super dealloc];
}

- (void)addImg:(NSMutableArray *)array
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    for (UIImageView *img in self.subviews) {
        [img removeFromSuperview];
    }
    if (array.count == 0) {
        return;
    }
    for (int i = 0; i < array.count; i ++) {
        UIImageView *v = [[UIImageView alloc] initWithImage:[array objectAtIndex:i]];
        [v setFrame:CGRectMake(15 + 40 * i + 10 * i, 0, 40, 40)];
        [self addSubview:v];
        [v release];
    }
    [pool release];
}
@end
