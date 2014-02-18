//
//  BaseViewController.h
//  MailText
//
//  Created by gao on 13-9-3.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "AppDelegate.h"

#import "ReceiveViewController.h"

#import "LoginViewController.h"

#import "Util.h"

#import "ShowTipsViewController.h"


@interface AppDelegate()
{}

@end

@implementation AppDelegate

@synthesize mainNav;

@synthesize revealController = _revealController;
@synthesize popSession = _popSession;
@synthesize imapSession = _imapSession;


- (void)dealloc
{
    [_imapSession release];
    [_popSession release];
    [_revealController release];
    [mainNav release];
    [_window release];
    [_viewController release];
    [super dealloc];
}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    
    return UIInterfaceOrientationMaskAll;
    
}

+ (AppDelegate *)getDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}


- (void)rebuilSessions
{
    self.popSession = nil;
    self.imapSession = nil;
    
    MCOPOPSession *popsession = [[MCOPOPSession alloc] init];
    self.popSession = popsession;
    [popsession release];
    [_popSession setCheckCertificateEnabled:NO];
    [_popSession setConnectionType:MCOConnectionTypeClear];
    
    self.imapSession = [[[MCOIMAPSession alloc] init] autorelease];
    [self.imapSession setCheckCertificateEnabled:YES];
    [self.imapSession setConnectionType:MCOConnectionTypeTLS];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    BOOL isBiger = NO;
    NSUserDefaults *opencounting = [NSUserDefaults standardUserDefaults];
    if ([opencounting objectForKey:@"counting"] != nil) {
        NSInteger countinga = [[opencounting objectForKey:@"counting"] integerValue];
        if (countinga > 30) {
            isBiger = YES;
            NSString *nibName = @"ShowTipsViewController";
            if (IS_IPAD) {
                nibName = @"ShowTipsViewController_ipad";
            }
            ShowTipsViewController *tips = [[ShowTipsViewController alloc] initWithNibName:nibName bundle:nil];
            self.window.rootViewController = tips;
            [tips release];
        
        }else {
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",++countinga] forKey:@"counting"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }else {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"counting"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    
    if (!isBiger) {
        //配置全局的seesion
        MCOPOPSession *popsession = [[MCOPOPSession alloc] init];
        self.popSession = popsession;
        [popsession release];
        [_popSession setCheckCertificateEnabled:NO];
        [_popSession setConnectionType:MCOConnectionTypeClear];
        
        self.imapSession = [[[MCOIMAPSession alloc] init] autorelease];
        [self.imapSession setCheckCertificateEnabled:YES];
        [self.imapSession setConnectionType:MCOConnectionTypeTLS];
        
        NSString *nibName = @"LoginViewController";
        if (IS_IPAD) {
            nibName = @"LoginViewController_ipad";
        }
        LoginViewController *login = [[LoginViewController alloc] initWithNibName:nibName bundle:nil];
        self.mainNav = [[[UINavigationController alloc]initWithRootViewController:login] autorelease];
        [login release];
        self.mainNav.navigationBar.hidden =YES;
        self.window.rootViewController = self.mainNav;
    }
    


    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

#pragma mark -- configure core data obj
- (NSManagedObjectContext *) objContext
{
    if (_objContext) {
        return _objContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStore];
    if (coordinator != nil) {
        _objContext = [[NSManagedObjectContext alloc] init];
        [_objContext setPersistentStoreCoordinator:coordinator];
    }
    
    return _objContext;
}

- (NSManagedObjectModel *) objModel
{
    if (_objModel) {
        return _objModel;
    }
    
    NSURL *modleUrl = [[NSBundle mainBundle] URLForResource:@"MailModel" withExtension:@"momd"];
    _objModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modleUrl];
    return _objModel;
}

//绑定存储方式，一般是sqlite
- (NSPersistentStoreCoordinator *) persistentStore
{
    if (_persistentStore) {
        return _persistentStore;
    }
    
    _persistentStore = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self objModel]];
    
    NSError *error = nil;
    NSURL *storeUrl = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"MailModel.sqlite3"];
    
    if (![_persistentStore addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return _persistentStore ;
    
}


- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (NSURL *)applicationCachesDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}


/**
 coredata对象，定义在appdelegate。
 目的可以是在系统退到后台，可以执行save方法。保存数据，
 且，达到一个对象共享。
 */
- (void)saveContext
{
    NSError *error;
    if (_objContext != nil) {
        if ([_objContext hasChanges] && ![_objContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.

             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


@end
