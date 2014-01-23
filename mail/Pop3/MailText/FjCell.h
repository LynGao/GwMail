//
//  FjCell.h
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FjCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIScrollView *fjListScroll;
@property (retain, nonatomic) IBOutlet UIImageView *fujImageView;

- (void)addImg:(NSMutableArray *)array;
@end
