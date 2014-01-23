//
//  ReceiveBiz.m
//  MailText
//
//  Created by gao wenjian on 14-1-16.
//  Copyright (c) 2014年 gwj. All rights reserved.
//

#import "ReceiveBiz.h"
#import "AppDelegate.h"
#import "PopMail.h"

@implementation ReceiveBiz

static NSInteger size = 10;

- (NSManagedObjectContext *)getContext
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    return [delegate objContext];
}

/**
 *  从数据库获取邮件头
 *
 *  @return 右箭头数组
 */
- (NSArray *)getPop3Mail
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"PopMail" inManagedObjectContext:[self getContext]];
    [request setEntity:entityDesc];
    NSArray *array = [[self getContext] executeFetchRequest:request error:NULL];
    return array;
}

/**
 *  保存邮件头，设置是否已读标识
 *
 *  @param datas MCOPOPMessageInfo array
 */
- (void)savePop3ReceiveMail:(NSArray *)datas
{
    NSArray *array = [self getPop3Mail];
    if (array.count == 0) {
        //直接插入
        NSInteger i = 0;
        for (MCOPOPMessageInfo *info in datas) {
            PopMail *pop = [NSEntityDescription insertNewObjectForEntityForName:@"PopMail" inManagedObjectContext:[self getContext]];
            [pop setPop_index:[NSNumber numberWithUnsignedInt:info.index]];
            [pop setPop_size:[NSNumber numberWithUnsignedInt:info.size]];
            [pop setPop_uid:[NSString stringWithFormat:@"%@",info.uid]];
            [pop setPop_readFlag:@"0"];
            i++;
            if (datas.count < size) {
                if (i == datas.count) {
                    [self save];
                }
            }else{
                if (i % size == 0) {
                    [self save];
                }else{
                    if (i == array.count) {
                        [self save];
                    }
                }
            }
        }
    }else
    {
        BOOL needInsertFlag = NO;
        for (MCOPOPMessageInfo *info in datas) {
            NSString *uid = info.uid;
            BOOL cachFlag = NO;
            for (PopMail *model in array) {
                if ([model.pop_uid isEqualToString:uid]) {
                    cachFlag = YES;
                    break;
                }
            }
            
            if (!cachFlag) {
                needInsertFlag = YES;
                PopMail *pop = [NSEntityDescription insertNewObjectForEntityForName:@"PopMail" inManagedObjectContext:[self getContext]];
                [pop setPop_index:[NSNumber numberWithUnsignedInt:info.index]];
                [pop setPop_size:[NSNumber numberWithUnsignedInt:info.size]];
                [pop setPop_uid:[NSString stringWithFormat:@"%@",info.uid]];
                [pop setPop_readFlag:@"0"];
            }
        }
        
        if (needInsertFlag) {
            [self save];
        }
    }
}

- (void)save
{
    [[self getContext] save:NULL];
}

/**
 *  更新邮件头
 *
 *  @param uid 邮件编号
 *  @param flag 是否已读标识
 */
- (void)updateMailData:(NSString *)uid readFlag:(NSString *)flag
{
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"PopMail" inManagedObjectContext:[self getContext]];
    NSPredicate *predict = [NSPredicate predicateWithFormat:@"pop_uid = %@",uid];
    [request setEntity:entityDesc];
    [request setPredicate:predict];
    
    NSArray *array = [[self getContext] executeFetchRequest:request error:NULL];
    if (array > 0) {
        PopMail *mail = [array objectAtIndex:0];
        [mail setPop_readFlag:flag];
        [self save];
    }
}

@end
