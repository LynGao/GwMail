//
//  ReadViewController.m
//  MailText
//
//  Created by gao on 13-10-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "ReadViewController.h"
#import "AppDelegate.h"
#import "Util.h"
#import "SKPSMTPMessage.h"
#import "SendMailViewController.h"

@interface ReadViewController ()<SKPSMTPMessageDelegate>
{
    UIWebView *_webView;
    UIDocumentInteractionController *_docInteractionController;
}
@end

@implementation ReadViewController

- (void)dealloc
{
    [_mail release];
    [_firstBtn release];
    [_secBtn release];
    [_thirdBtn release];
    [_ccView release];
    [_ccbg release];
    [_ccLabel release];
    [_ccText release];
    [_addBtn release];
    [_ccsendBtn release];
    [_targetText release];
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
	// Do any additional setup after loading the view.
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadData
{
    CGFloat delta = 0;
    if (IOS7_OR_LATER) {
        delta = 20;
    }
    _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height - 44 - delta)];
    [_webView setDelegate:self];
    [self.view addSubview:_webView];
    
    NSString *base = @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\"><div style=\"background-color:#eee\">";
    //to
    base = [NSString stringWithFormat:@"%@<div>%@</div>",base,_mail.mail_title];
    
    //
    base = [NSString stringWithFormat:@"%@<div><b>发件人:</b>%@</div>                                  <div><b>时间:</b>%@</div><div><b>收件人:</b>%@</div>",base,_mail.mail_from,_mail.mail_date,_mail.mail_to];
    
    //fujian
    NSLog(@"fujian ----- %@",_mail.mail_attach);
    NSString *attench = nil;
    NSArray *arry = [_mail.mail_attach componentsSeparatedByString:@"/"];
    NSLog(@"arry ----- %@",arry);
    for (int i = 0; i< arry.count; i++) {
        
        if (![[arry objectAtIndex:i] isEqualToString:@""]) {
             NSString *name = [NSString stringWithFormat:@"%@.jpg",[arry objectAtIndex:i]];
            if (i == 0) {
                attench = [NSString stringWithFormat:@"<div><b>附件:<b/><b>%@</b>&nbsp<a id = \"FJID%i\" href=\"http://OpenFile/%@\">打开</a></div>",name,i,name];
            }else
                attench = [NSString stringWithFormat:@"<div>&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<b>%@</b>&nbsp<a id = \"FJID%i\" href=\"http://OpenFile/%@\">打开</a></div>",name,i,name];
        }
    }
    
    if (attench) {
        base = [NSString stringWithFormat:@"%@%@</div></div>",base,attench];
    }else
        base = [NSString stringWithFormat:@"%@</div></div>",base];
    
    //content
    NSString *mainContent = @"<div><!DOCTYPE html><html xmlns=\"http://www.w3.org/1999/xhtml\"><head><meta name=\"generator\" content=\"HTML Tidy for HTML5 (experimental) for Mac OS X https://github.com/w3c/tidy-html5/tree/c63cc39\"/><title></title></head><body style=\"padding:12px 8px; font-size:12px;\" marginwidth=\"0\"marginheight=\"0\">";
    mainContent = [NSString stringWithFormat:@"%@%@%@",mainContent,_mail.mail_content,@"</html>"];
    
    NSString *final = [NSString stringWithFormat:@"%@%@",base,mainContent];
    
    NSLog(@"%@",final);
    [_webView loadHTMLString:final baseURL:nil];
    
    if (_showType == SENDBOXMAIL || _showType == TEMPMAIL) {
        [_firstBtn addTarget:self action:@selector(moveToRubbish) forControlEvents:UIControlEventTouchUpInside];
        [_secBtn addTarget:self action:@selector(removeRubbish) forControlEvents:UIControlEventTouchUpInside];
            [_secBtn setTitle:@"彻底删除" forState:UIControlStateNormal];
        [_thirdBtn addTarget:self action:@selector(goToEidtMail) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [_firstBtn addTarget:self action:@selector(removeRubbish) forControlEvents:UIControlEventTouchUpInside];
        [_secBtn setTitle:@"恢复" forState:UIControlStateNormal];
        [_secBtn addTarget:self action:@selector(recovermail) forControlEvents:UIControlEventTouchUpInside];
        [_thirdBtn addTarget:self action:@selector(goToEidtMail) forControlEvents:UIControlEventTouchUpInside];

    }
}




- (void)viewDidUnload {
    [self setFirstBtn:nil];
    [self setSecBtn:nil];
    [self setThirdBtn:nil];
    [self setCcView:nil];
    [self setCcbg:nil];
    [self setCcLabel:nil];
    [self setCcText:nil];
    [self setAddBtn:nil];
    [self setCcsendBtn:nil];
    [self setTargetText:nil];
    [super viewDidUnload];
}

- (void)recovermail
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
    _mail.mail_type = [NSNumber numberWithInt:TEMPMAIL];

    NSError *error = nil;
    [context save:&error];
    if (!error) {
        [Util showTipsLabels:self.view setMsg:@"恢复成功" setOffset:0];
    }else
        NSLog(@"save -- fial %@",error);
}

- (void)moveToRubbish
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
//    Mail *mails = [NSEntityDescription insertNewObjectForEntityForName:@"Mail" inManagedObjectContext:context];
//    [mails setMail_title:_mail.mail_title];
//    [mails setMail_to:_mail.mail_to];
// 
//    [mails setMail_cc:_mail.mail_cc];
//
//    [mails setMail_content:_mail.mail_content];
//    [mails setMail_from:[Util getObjFromUserDefualt:SENDER]];
//    [mails setMail_type:[NSNumber numberWithInteger:RUBBISHMAIL]];
//    [mails setMail_date:[Util stringFromDate:[NSDate date]]];
    [_mail setMail_type:[NSNumber numberWithInteger:RUBBISHMAIL]];
    
    NSError *error = nil;
    [context save:&error];
    if (!error) {
        [Util showTipsLabels:self.view setMsg:@"删除成功" setOffset:0];
    }else
        NSLog(@"save -- fial %@",error);

}

- (void)removeRubbish
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
    [context deleteObject:_mail];
    NSError *error = nil;
    [context save:&error];
    if (!error) {
        [Util showTipsLabels:self.view setMsg:@"彻底删除成功" setOffset:0];
    }else
        NSLog(@"save -- fial %@",error);
}

- (void)goToEidtMail
{
  
        
    NSString *nibName = @"SendMailViewController";
    if (iPhone5) {
        nibName = @"SendMailViewController_5";
    }
    SendMailViewController *sendController = [[SendMailViewController alloc] initWithNibName:nibName bundle:nil];
    //正文
    NSString *str = [NSString stringWithFormat:@"<div contenteditable=true id = \"beignDiv\"><br/><br/>%@</div>",_mail.mail_content];
    [sendController setInnerText:str];
    
    //回复
    NSString *sender = nil;
    NSString *subject = nil;
 
    sender = _mail.mail_to;
    subject = _mail.mail_title;
    NSString *ccTo = _mail.mail_cc;
 
    [sendController setSubjectString:subject];
    [sendController setReceiversString:sender];
    [sendController setReplayType:SINGLEREPLAY];
    
    [self.navigationController pushViewController:sendController animated:YES];
    [sendController release];
}

- (void)ccToOther
{
    
//    LoadViewFromXib *loader = [[LoadViewFromXib alloc] initWithNib:@"CcView"];
//    UIView *sub = [loader loadView];
//    [self.view addSubview:sub];
    
    [self showLoadingWithTips:@"正在发送"];
    
    SKPSMTPMessage *_sender = [[SKPSMTPMessage alloc] init];
    
    _sender.toEmail = _mail.mail_to;
    _sender.fromEmail =[Util getObjFromUserDefualt:SENDER];
    _sender.relayHost = [Util getObjFromUserDefualt:SENDER_SERVER];//
    _sender.login = [Util getObjFromUserDefualt:SENDER];//
	_sender.pass = [Util getObjFromUserDefualt:SENDER_PWD];//
    _sender.requiresAuth = YES;
    _sender.wantsSecure = YES;
    _sender.subject = _mail.mail_title;
    
    NSDictionary *plainPart = [NSDictionary
                               dictionaryWithObjectsAndKeys:@"text/plain",
                               kSKPSMTPPartContentTypeKey,
                               _mail.mail_content,
                               kSKPSMTPPartMessageKey,
                               @"8bit",
                               kSKPSMTPPartContentTransferEncodingKey,
                               nil];
    
    _sender.ccEmail = _mail.mail_cc;
    _sender.parts = [NSArray arrayWithObjects:plainPart, nil];
    _sender.delegate = self;
    [_sender send];
    
    [_sender release];

}

#pragma mark skps delegate
- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    
    [self hiddenHud];
    
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"发送失败"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
	[alert show];
	[alert release];
    
    //    [self reBuildSender];
    
	NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
}

- (void)messageSent:(SKPSMTPMessage *)message{
    
    [self hiddenHud];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self saveToSendBox:nil];
    });
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"邮件发送成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
	[alert release];
    
}

#pragma mark 保存
- (IBAction)saveToSendBox:(id)sender
{
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
    [_mail setMail_date:[Util stringFromDate:[NSDate date]]];
    [context save:NULL];
    
    if (sender) {
         [Util showTipsLabels:self.view setMsg:@"保存成功" setOffset:0];
    }
   
    
}

#pragma mark webview delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSArray *array = [request.URL.absoluteString componentsSeparatedByString:@"/"];
    NSLog(@"arrya = %@",array);
    if (array.count == 4) {
         if ([[[array objectAtIndex:2] lowercaseString] isEqualToString:@"openfile"])//打开预览
        {
            NSURL *pathUrl = [NSURL fileURLWithPath:[Util getFileAtDocumentPath:[array objectAtIndex:3]]];
            
            NSLog(@"%@",[Util getFileAtDocumentPath:[array objectAtIndex:3]]);
            
            if (_docInteractionController == nil) {
                _docInteractionController = [[UIDocumentInteractionController interactionControllerWithURL:pathUrl] retain];
                _docInteractionController.delegate = self;
            }else {
                _docInteractionController.URL = pathUrl;
            }
            [_docInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];

            return NO;
        }
    }
    
    return YES;
}

- (void)createCCView
{
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(10, (self.view.frame.size.height - 100) / 2, 300, 100)];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 44)];
    [title setFont:[UIFont systemFontOfSize:15.0]];
    [title setText:@"转发"];
    [title setBackgroundColor:[UIColor blueColor]];
    [v addSubview:title];
    [title release];
    
    UILabel *liner = [[UILabel alloc] initWithFrame:CGRectMake(0, 45, 300, 1)];
    [liner setBackgroundColor:[UIColor blueColor]];
    [v addSubview:liner];
    [v release];
    [liner release];
   
}
@end
