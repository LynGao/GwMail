//
//  Mail.h
//  MailText
//
//  Created by gao wenjian on 14-2-14.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Mail : NSManagedObject

@property (nonatomic, retain) NSString * mail_attach;
@property (nonatomic, retain) NSString * mail_cc;
@property (nonatomic, retain) NSString * mail_content;
@property (nonatomic, retain) NSString * mail_date;
@property (nonatomic, retain) NSString * mail_from;
@property (nonatomic, retain) NSNumber * mail_removeFlag;
@property (nonatomic, retain) NSString * mail_title;
@property (nonatomic, retain) NSString * mail_to;
@property (nonatomic, retain) NSNumber * mail_type;
@property (nonatomic, retain) NSString * mail_ower;

@end
