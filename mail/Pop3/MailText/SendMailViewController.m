//
//  SendMailViewController.m
//  MailText
//
//  Created by gwj on 13-8-21.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "SendMailViewController.h"
#import "SetMailViewController.h"
#import "NSData+Base64Additions.h"
#import "Util.h"

#import "ReceiveCell.h"
#import "SubjectCell.h"
#import "CCCell.h"
#import "ContenViewCell.h"
#import "FjCell.h"

#import "AppDelegate.h"
#import "Mail.h"
#import "SendBiz.h"

@interface SendMailViewController ()
{
    UITableView *_mainTable;
    NSInteger _rowCount;
    BOOL _ccFlag;
    BOOL _fjFlag;
//    SKPSMTPMessage *_sender;
    
    MailSaveType _showType;
    
    UIWebView *web;
}

@property (nonatomic,retain) NSMutableArray *sendPartArray;
@property (nonatomic,retain) NSMutableArray *imgArray;
@end

@implementation SendMailViewController

- (void)dealloc
{
//    [_sender release];
    [_imgArray release];
    [_mainTable release];
    [_sendPartArray release];
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
    
    _rowCount = 3;
    
    self.title = @"邮件编辑";
    
    _mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 44) style:UITableViewStylePlain];
    [_mainTable setDelegate:self];
    [_mainTable setDataSource:self];
    _mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_mainTable];
    
    
    self.sendPartArray = [[[NSMutableArray alloc] init] autorelease];
    self.imgArray = [[[NSMutableArray alloc] init] autorelease];
    
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(print)];
    self.navigationItem.rightBarButtonItem = item;
    web = [[UIWebView alloc] initWithFrame:self.view.bounds];
//    [web loadHTMLString:self.innerText baseURL:nil];
//    [self.view addSubview:web];
}

- (void)print
{
    NSLog(@"web %@",[web stringByEvaluatingJavaScriptFromString:@"document.body.innerText"]);
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//添加附件
- (void)addFujian:(UIButton *)sender
{
    
    if (sender.tag == 887) {//删除
        
        _fjFlag = NO;
        
        [self.imgArray removeAllObjects];
        
        [self clearParts];
        
        [_mainTable reloadData];
        
    }else{
        
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"附件"
                                                           delegate:self
                                                  cancelButtonTitle:@"取消"
                                             destructiveButtonTitle:@"图片"
                                                  otherButtonTitles:nil,
                                nil];
        [sheet showInView:self.view];
        [sheet release];

    }

}

- (void)addChaoSong:(id)sender
{
    _ccFlag = !_ccFlag;
    [_mainTable reloadData];
}

#pragma mark -- send mail by MCO
- (IBAction)sendMailByMco
{
    NSInteger row = 1;
    if (_ccFlag) {
        row = 2;
    }
    
    ReceiveCell *cell = (ReceiveCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *receive = cell.receiveTextField.text;
    if (receive.length == 0) {
        [Util showTipsLabels:self.view setMsg:@"收件人不能为空" setOffset:45];
        return;
    }
    
    SubjectCell *subCell = (SubjectCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    NSString *sub = subCell.subjectTextField.text;
    if (sub.length == 0) {
        [Util showTipsLabels:self.view setMsg:@"主题不能为空" setOffset:45];
        return;
    }
    
    [self showLoadingWithTips:@"正在发送"];
    
    NSInteger contRow = 2;
    if ((_ccFlag && !_fjFlag) || (!_ccFlag && _fjFlag)) {
        contRow = 3;
    }
    if (_ccFlag && _fjFlag) {
        contRow = 4;
    }
    
    
    //正文内容
    ContenViewCell *contentCell = (ContenViewCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contRow inSection:0]];
    NSString *content = [contentCell.webContentView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];;
    if (content.length == 0) {
        content = @"";
    }
    
    MCOMessageBuilder * builder = [[MCOMessageBuilder alloc] init];
    [[builder header] setFrom:[MCOAddress addressWithDisplayName:nil mailbox:[Util getObjFromUserDefualt:SENDER]]];
    NSMutableArray *to = [[NSMutableArray alloc] init];
    
    for(NSString *toAddress in [receive componentsSeparatedByString:@";"]) {
        NSLog(@"to addresss -- %@", toAddress);
        MCOAddress *newAddress = [MCOAddress addressWithMailbox:toAddress];
        [to addObject:newAddress];
    }
    [[builder header] setTo:to];
   
    if (_ccFlag) {
        CCCell *cc = (CCCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        NSString *ccStr = cc.inputTextField.text;
        NSArray *ccArray = [ccStr componentsSeparatedByString:@";"];
        NSLog(@"cc Array = %@",ccArray);
        NSMutableArray *cCAddressArray = [[NSMutableArray alloc] init];
        for(NSString *ccAddress in ccArray) {
                MCOAddress *newAddress = [MCOAddress addressWithMailbox:ccAddress];
                [cCAddressArray addObject:newAddress];
        }
        
        [[builder header] setCc:cCAddressArray];
    }
    
    [[builder header] setSubject:sub];
    [builder setTextBody:content];
  
    NSData * rfc822Data = [builder data];
    
    SendBiz *sn = [[SendBiz alloc] init];
    [sn sendMail:rfc822Data
         success:^{
             [self messageSent:nil];
        }
            fail:^{
                [self messageFailed:nil error:NULL];
    }];
}

#pragma mark send mail
- (IBAction)sendMail:(id)sender {

    NSInteger row = 1;
    if (_ccFlag) {
        row = 2;
    }
  
    ReceiveCell *cell = (ReceiveCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *receive = cell.receiveTextField.text;
    if (receive.length == 0) {
        [Util showTipsLabels:self.view setMsg:@"收件人不能为空" setOffset:45];
        return;
    }
    
    SubjectCell *subCell = (SubjectCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    NSString *sub = subCell.subjectTextField.text;
    if (sub.length == 0) {
        [Util showTipsLabels:self.view setMsg:@"主题不能为空" setOffset:45];
        return;
    }
    
    [self showLoadingWithTips:@"正在发送"];
    
    
    SKPSMTPMessage *_sender = [[SKPSMTPMessage alloc] init];
    
    _sender.toEmail = receive;
    _sender.fromEmail =[Util getObjFromUserDefualt:SENDER];
    _sender.relayHost = [Util getObjFromUserDefualt:RECEIVE_SERVER];
   
    _sender.login = [Util getObjFromUserDefualt:SENDER];//
	_sender.pass = [Util getObjFromUserDefualt:SENDER_PWD];//
    _sender.requiresAuth = YES;
    _sender.wantsSecure = YES;
    _sender.subject = sub;
    
    NSInteger contRow = 2;
    if ((_ccFlag && !_fjFlag) || (!_ccFlag && _fjFlag)) {
        contRow = 3;
    }
    if (_ccFlag && _fjFlag) {
        contRow = 4;
    }
    
    ContenViewCell *contentCell = (ContenViewCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contRow inSection:0]];
//    NSString *content = contentCell.contentVIew.text;
    NSString *content = [contentCell.webContentView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];;
    if (content.length == 0) {
        content = @"";
    }
    NSDictionary *plainPart = [NSDictionary
                               dictionaryWithObjectsAndKeys:@"text/plain",
                               kSKPSMTPPartContentTypeKey,
                               content,
                               kSKPSMTPPartMessageKey,
                               @"8bit",
                               kSKPSMTPPartContentTransferEncodingKey,
                               nil];
    
    if (_ccFlag) {
        CCCell *cc = (CCCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        NSString *ccStr = cc.inputTextField.text;
        if (ccStr.length > 0) {
            [_sender setCcEmail:ccStr];
        }
    }
    
    
    [_sendPartArray addObject:plainPart];
    _sender.parts = _sendPartArray;
    _sender.delegate = self;
    [_sender send];
    
    [_sender release];
    
    
}

- (void)clearParts
{
    [_sendPartArray removeAllObjects];
}



- (IBAction)clearText:(id)sender
{
  
    NSInteger contRow = 2;
    if ((_ccFlag && !_fjFlag) || (!_ccFlag && _fjFlag)) {
        contRow = 3;
    }
    if (_ccFlag && _fjFlag) {
        contRow = 4;
    }
    
    ContenViewCell *contentCell = (ContenViewCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contRow inSection:0]];
    [contentCell.contentVIew setText:@""];

}

#pragma mark 保存
- (IBAction)saveToTemp:(id)sender
{
    if (sender) {
        _showType = TEMPMAIL;
    }else
        _showType = SENDBOXMAIL;
    
    
    NSInteger row = 1;
    if (_ccFlag) {
        row = 2;
    }
    
    ReceiveCell *cell = (ReceiveCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    NSString *receive = cell.receiveTextField.text;
    
    SubjectCell *subCell = (SubjectCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
    NSString *sub = subCell.subjectTextField.text;
    
    NSString *ccStr = nil;
    if (_ccFlag) {
        CCCell *cc = (CCCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        ccStr = cc.inputTextField.text;
    }
    
    NSInteger contRow = 2;
    if ((_ccFlag && !_fjFlag) || (!_ccFlag && _fjFlag)) {
        contRow = 3;
    }
    if (_ccFlag && _fjFlag) {
        contRow = 4;
    }
    ContenViewCell *contentCell = (ContenViewCell *)[_mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:contRow inSection:0]];
    NSString *content = contentCell.contentVIew.text;
 
    AppDelegate *delegate = [AppDelegate getDelegate];
    NSManagedObjectContext *context = [delegate objContext];
    Mail *mail = [NSEntityDescription insertNewObjectForEntityForName:@"Mail" inManagedObjectContext:context];
    [mail setMail_title:sub];
    [mail setMail_to:receive];
    if (_ccFlag) {
        [mail setMail_cc:ccStr];
    }
    [mail setMail_content:content];
    [mail setMail_from:[Util getObjFromUserDefualt:SENDER]];
    [mail setMail_type:[NSNumber numberWithInteger:_showType]];
    [mail setMail_date:[Util stringFromDate:[NSDate date]]];
    
    if ( self.imgArray.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (int i = 0; i < self.imgArray.count ; i++) {
                NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
                UIImage *image = [self.imgArray objectAtIndex:i];
                NSData *data = UIImageJPEGRepresentation(image, 1.0);//UIImagePNGRepresentation(image);
                NSString *path = [Util getFileAtDocumentPath:[NSString stringWithFormat:@"pic_%d.jpg",i]];
                [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:NULL];
                [pool release];
            }
        });
        
        NSString *paths = @"";
        for (int i = 0; i< self.imgArray.count; i++) {
            NSString *path = [NSString stringWithFormat:@"pic_%d/",i];
            paths = [NSString stringWithFormat:@"%@%@",paths,path];
        }
        
        [mail setMail_attach:paths];
    }
    
   
    [context save:NULL];
    
    if (sender) {
        [Util showTipsLabels:self.view setMsg:@"保存成功" setOffset:0];
    }
    
    
}

#pragma mark skps delegate
- (void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    
    [self hiddenHud];
    
    [self clearParts];
    
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
    
    [self clearParts];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"邮件发送成功"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    [alert show];
	[alert release];
    
    [self reBuildSender];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        [self saveToTemp:nil];
    });
}

- (void)reBuildSender
{
//    if (!_sender) {
////        [_sender setDelegate:nil];
////        [_sender release];
////        _sender = nil;
//        
//        _sender = [[SKPSMTPMessage alloc] init];
//        
//    }else{
//        if (_sender) {
//            [_sender setDelegate:nil];
//            [_sender release];
//            _sender = nil;
//
//        }
//        
//        _sender = [[SKPSMTPMessage alloc] init];
//
//    }
    
    
   
    
   
}

#pragma mark touch

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
 
}

#pragma mark text view delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self changeTextViewFrame:-150];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self changeTextViewFrame:150];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)changeTextViewFrame:(CGFloat)offset
{
    [UIView animateWithDuration:0.3
                     animations:^{
                         CGRect frame = self.view.frame;
                         frame.origin.y = self.view.frame.origin.y + offset;
                         self.view.frame = frame;
                     }];
}

#pragma mark action sheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (buttonIndex == 0) {
        [self openLoaclPic];
    }
}

//获取图片
#pragma mark open img picker
-(void)openLoaclPic
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
    
        UIImagePickerController *pickers = [[UIImagePickerController alloc] init];
        pickers.delegate = self;
        pickers.allowsEditing = YES;
        pickers.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:pickers animated:YES];
        [pickers release];
    }else {
        [Util showTipsLabels:self.view setMsg:@"打开图库失败" setOffset:45];
    }
}

#pragma imagepicker delegate method

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *t=[info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSURL *ext=[info objectForKey:@"UIImagePickerControllerReferenceURL"];
    NSRange range=NSMakeRange(ext.absoluteString.length-3, 3);
    NSString *fiex=[ext.absoluteString substringWithRange:range];
    
    NSData *data = nil;
    NSString *picName = nil;
    if ([fiex isEqualToString:@"PNG"]){
        data = UIImagePNGRepresentation(t);
        picName = [NSString stringWithFormat:@"pic_%d.png",self.sendPartArray.count];
    }else{
        data = UIImageJPEGRepresentation(t, 0.1);
        picName = [NSString stringWithFormat:@"pic_%d.jpg",self.sendPartArray.count];
    }
    
    NSLog(@"info = %@ ext = %@ \n name = %@",info,ext,picName);
    
    NSDictionary *vcfPart = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSString stringWithFormat:@"text/directory;\r\n\tx-unix-mode=0644;\r\n\tname=\"%@\"",picName],
                             kSKPSMTPPartContentTypeKey,
                             [NSString stringWithFormat:@"attachment;\r\n\tfilename=\"%@\"",picName],
                             kSKPSMTPPartContentDispositionKey,
                             [data encodeBase64ForData],
                             kSKPSMTPPartMessageKey,
                             @"base64",
                             kSKPSMTPPartContentTransferEncodingKey,
                             nil];
    
    [_sendPartArray addObject:vcfPart];
    
    [self.imgArray addObject:t];
    _fjFlag = YES;
    [_mainTable reloadData];
    
    
    
    
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissModalViewControllerAnimated:YES];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
}


#pragma mark tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!_ccFlag && !_fjFlag) {
        
        if (indexPath.row == 0) {
            return 87;
        }else if(indexPath.row == 1){
            return 63;
        }else{
            return 191;
        }
        
    }else if ((_ccFlag && !_fjFlag)) {
        if (indexPath.row == 0) {
            return 87;
        }else if(indexPath.row == 1){
            return 45;
        }
        else if(indexPath.row == 2){
            return 63;
        }else{
            return 191;
        }
    }else if ((!_ccFlag && _fjFlag)) {
        if (indexPath.row == 0) {
            return 87;
        }else if(indexPath.row == 1){
            return 63;
        }else if(indexPath.row == 2){
            return 45;
        }else{
            return 191;
        }
    }else{
        if (indexPath.row == 0) {
            return 87;
        }else if(indexPath.row == 1){
            return 45;
        }
        else if(indexPath.row == 2){
            return 63;
        }else if(indexPath.row == 3){
            return 45;
        }else{
            return 191;
        }
 
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!_ccFlag && !_fjFlag) {
        return _rowCount;
    }else if ((_ccFlag && !_fjFlag) || (!_ccFlag && _fjFlag)) {
        return _rowCount + 1;
    }else{
        return _rowCount + 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{        
    static NSString *indetify = @"receive";
    ReceiveCell *cell = (ReceiveCell *)[tableView dequeueReusableCellWithIdentifier:indetify];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"ReceiveCell" owner:nil options:nil] lastObject];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell.addCCBtn addTarget:self action:@selector(addChaoSong:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.receiveTextField setDelegate:self];
        [cell.receiveTextField setReturnKeyType:UIReturnKeyDone];
    }

    static NSString *subjcet = @"subjcet";
    SubjectCell *subCell = (SubjectCell *)[tableView dequeueReusableCellWithIdentifier:subjcet];
    if (!subCell) {
        subCell = [[[NSBundle mainBundle] loadNibNamed:@"SubjectCell" owner:nil options:nil] lastObject];
        [subCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [subCell.firstAddBtn addTarget:self action:@selector(addFujian:) forControlEvents:UIControlEventTouchUpInside];
        [subCell.secondAddBtn addTarget:self action:@selector(addFujian:) forControlEvents:UIControlEventTouchUpInside];
        
        if (_fjFlag) {
            [subCell.secondAddBtn setTag:887];
            [subCell.secondAddBtn setTitle:@"删除附件" forState:UIControlStateNormal];
        }else{
            [subCell.secondAddBtn setTitle:@"添加附件" forState:UIControlStateNormal];
            [subCell.secondAddBtn setTag:888];
        }
        
        [subCell.subjectTextField setDelegate:self];
        [subCell.subjectTextField setReturnKeyType:UIReturnKeyDone];
    
    }
  
    static NSString *content = @"content";
    ContenViewCell *contentCell = (ContenViewCell *)[tableView dequeueReusableCellWithIdentifier:content];
    if (!contentCell) {
        contentCell = [[[NSBundle mainBundle] loadNibNamed:@"ContenViewCell" owner:nil options:nil] lastObject];
        [contentCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [contentCell.contentVIew setDelegate:self];
        [contentCell.contentVIew setReturnKeyType:UIReturnKeyDone];
        NSString *divs = @"<div contenteditable=true></div>";
        [contentCell.webContentView loadHTMLString:divs baseURL:nil];
        
    }

    
    CCCell *ccCells = nil;
    if (_ccFlag) {
        static NSString *ccCell = @"cc";
        ccCells = (CCCell *)[tableView dequeueReusableCellWithIdentifier:ccCell];
        if (!ccCells) {
            ccCells = [[[NSBundle mainBundle] loadNibNamed:@"CCCell" owner:nil options:nil] lastObject];
            [ccCells setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            [ccCells.inputTextField setDelegate:self];
            [ccCells.inputTextField setReturnKeyType:UIReturnKeyDone];
          
        }
    }
    
    FjCell *fjCells = nil;
    if (_fjFlag) {
        static NSString *fjCell = @"fj";
        fjCells = (FjCell *)[tableView dequeueReusableCellWithIdentifier:fjCell];
        if (!fjCells) {
            fjCells = [[[NSBundle mainBundle] loadNibNamed:@"FjCell" owner:nil options:nil] lastObject];
            [fjCells setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
//        [fjCells addImg:self.imgArray];
        [fjCells.fujImageView setImage:[self.imgArray objectAtIndex:0]];

    }

    if (!_ccFlag && !_fjFlag) {
        
        if (indexPath.row == 0) {
            return cell;
        }else if(indexPath.row == 1){
            return subCell;
        }else{
            return contentCell;
        }
        
    }else if ((_ccFlag && !_fjFlag)) {
        if (indexPath.row == 0) {
            return cell;
        }else if(indexPath.row == 1){
            return ccCells;
        }
        else if(indexPath.row == 2){
            return subCell;
        }else{
            return contentCell;
        }
    }else if ((!_ccFlag && _fjFlag)) {
        if (indexPath.row == 0) {
            return cell;
        }else if(indexPath.row == 1){
            return subCell;
        }else if(indexPath.row == 2){
            return fjCells;
        }else{
            return contentCell;
        }
    }else{
        if (indexPath.row == 0) {
             return cell;
        }else if(indexPath.row == 1){
            return ccCells;
        }
        else if(indexPath.row == 2){
            return subCell;
        }else if(indexPath.row == 3){
            return fjCells;
        }else{
            return contentCell;
        }
    }
}

@end
