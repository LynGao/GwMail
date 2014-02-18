//
//  ContenViewCell.h
//  MailText
//
//  Created by gao on 13-9-10.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContenViewCell : UITableViewCell <UIWebViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *contentVIew;
@property (retain, nonatomic) IBOutlet UIWebView *webContentView;

@end
