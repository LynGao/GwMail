//
//  BaseViewController.m
//  MailText
//
//  Created by gao on 13-9-3.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()
{
    MBProgressHUD *_HUD;
}
@end

@implementation BaseViewController



-(void)dealloc
{
    if (_HUD) {
        [_HUD release];
        _HUD = nil;
    }
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if ( IOS7_OR_LATER )
    {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.navigationController.navigationBar.translucent = NO;
    }
#endif  // #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showLoadingWithTips:(NSString *)tips
{
    NSString *tip = @"正在加载...";
    if (tips) {
        tip = tips;
    }
    
    if (!_HUD) {
        _HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [_HUD setDelegate:self];
        [_HUD setLabelFont:[UIFont systemFontOfSize:12.0f]];
        [_HUD setDimBackground:YES];
        [self.view addSubview:_HUD];
    }
    
    [_HUD setLabelText:tip];
    [_HUD show:YES];
}

- (void)hiddenHud
{
    if (_HUD) {
        [_HUD hide:YES];
    }
    
}

#pragma mark Hud Delegate
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    GWLog(@"Hud deleHidden");
    [_HUD removeFromSuperview];
    [_HUD release];
    _HUD = nil;
}

@end
