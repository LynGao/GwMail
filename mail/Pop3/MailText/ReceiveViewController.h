//
//  ReceiveViewController.h
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "BaseViewController.h"
#include <MailCore/MailCore.h>
#import "EGORefreshTableHeaderView.h"

@interface ReceiveViewController : BaseViewController<MCOHTMLRendererIMAPDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UIScrollViewDelegate>{
    
    EGORefreshTableHeaderView *_refreshTableView;
    BOOL _reloading;
}

@property (nonatomic,assign) SessionType requestSessionType;
@end
