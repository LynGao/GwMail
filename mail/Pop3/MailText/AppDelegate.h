//
//  BaseViewController.h
//  MailText
//
//  Created by gao on 13-9-3.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPRevealSideViewController.h"
#import <CoreData/CoreData.h>
#include <MailCore/MailCore.h>

@class ReceiveViewController;



@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    
}

@property (strong, nonatomic) UIWindow *window;

@property (retain, nonatomic) ReceiveViewController *viewController;

@property (nonatomic, retain) UINavigationController *mainNav;

@property (nonatomic, retain) PPRevealSideViewController *revealController;

@property (nonatomic, retain) NSManagedObjectModel *objModel;
@property (nonatomic, retain) NSManagedObjectContext *objContext;
@property (nonatomic, retain) NSPersistentStoreCoordinator *persistentStore;

@property (nonatomic, retain) MCOPOPSession *popSession;
@property (nonatomic, retain) MCOIMAPSession *imapSession;

+ (AppDelegate *)getDelegate;

- (void)rebuilSessions;

@end
