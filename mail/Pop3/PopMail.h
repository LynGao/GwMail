//
//  PopMail.h
//  MailText
//
//  Created by gao wenjian on 14-1-17.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PopMail : NSManagedObject

@property (nonatomic, retain) NSNumber * pop_index;
@property (nonatomic, retain) NSNumber * pop_size;
@property (nonatomic, retain) NSString * pop_uid;
@property (nonatomic, retain) NSString * pop_readFlag;

@end
