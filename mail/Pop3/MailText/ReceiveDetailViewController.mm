//
//  ReceiveDetailViewController.m
//  MailText
//
//  Created by gao on 13-9-15.
//  Copyright (c) 2013年 gwj. All rights reserved.
//

#import "ReceiveDetailViewController.h"

#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>
#import "MCOMessageView.h"
#import "Util.h"

#import "UIAlertView+Block.h"

#import "SendMailViewController.h"


@interface ReceiveDetailViewController () <MCOMessageViewDelegate,UIDocumentInteractionControllerDelegate,UIActionSheetDelegate>
{
    UIDocumentInteractionController *_docInteractionController;
}
@property (nonatomic, retain) MCOAbstractMessage *popMessage;
@end

@implementation ReceiveDetailViewController

@synthesize folder = _folder;
@synthesize session = _session;

-(void)dealloc
{
    [_messageView setDelegate:nil];
    self.popMessage = nil;
    [_session release];
    [_folder release];
    [_storage release];
    [_ops release];
    [_pending release];
    [_callbacks release];
    [super dealloc];
}

- (void) awakeFromNib
{
    _storage = [[NSMutableDictionary alloc] init];
    _ops = [[NSMutableArray alloc] init];
    _pending = [[NSMutableSet alloc] init];
    _callbacks = [[NSMutableDictionary alloc] init];
}

- (id)init {
    self = [super init];
    
    if(self) {
        [self awakeFromNib];
    }
    
    return self;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"index -- %d",buttonIndex);
    NSInteger type = 0;
    if (buttonIndex == 0) {
        type = 10001;
    }else if(buttonIndex == 1){
        type = 10002;
    }else if(buttonIndex == 2)
        type = 10003;
    if (type != 0) {
        [self replayMail:type];
    }
}

- (void)showReplayType
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"回复类型"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"回复",@"回复全部",@"转发",nil];
    [sheet showInView:self.view];
    [sheet release];
    
//    UIView *bgView = [[UIView alloc] initWithFrame:self.view.bounds];
//    [bgView setTag:20001];
//    [bgView setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.7]];
//    [bgView.layer setCornerRadius:1];
//    for (int i = 0; i < 3; i++) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(self.view.frame.size.width / 2 - 100 / 2, 150 + 40 *i, 100, 40)];
//        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
//    
//        switch (i) {
//            case 0:
//            {
//                //回复
//                [btn setTitle:@"回复" forState:UIControlStateNormal];
//                [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//                [btn addTarget:self action:@selector(replayMail:) forControlEvents:UIControlEventTouchUpInside];
//                [btn setTag:10001];
//                [bgView addSubview:btn];
//            }
//                break;
//            case 1:
//            {
//                //回复全部
//                [btn setTitle:@"回复全部" forState:UIControlStateNormal];
//                [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//                [btn addTarget:self action:@selector(replayMail:) forControlEvents:UIControlEventTouchUpInside];
//                [btn setTag:10002];
//                [bgView addSubview:btn];
//            }
//                break;
//            case 2:
//            {
//                //转发
//                [btn setTitle:@"转发" forState:UIControlStateNormal];
//                [btn.titleLabel setFont:[UIFont systemFontOfSize:18.0]];
//                [btn addTarget:self action:@selector(replayMail:) forControlEvents:UIControlEventTouchUpInside];
//                [btn setTag:10003];
//                [bgView addSubview:btn];
//            }
//                break;
//            default:
//                break;
//        }
//    }
//    
//    [self.view addSubview:bgView];
//    [bgView release];
}

#pragma mark -- 回复邮件
- (void)replayMail:(NSInteger)type
{
//    NSString *innerMailText = [_messageView.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerText"];

    NSString *nibName = @"SendMailViewController";
    if (iPhone5) {
        nibName = @"SendMailViewController_5";
    }
    SendMailViewController *sendController = [[SendMailViewController alloc] initWithNibName:nibName bundle:nil];
    //正文
    NSString *str = [NSString stringWithFormat:@"<div contenteditable=true id = \"beignDiv\"><br/><div>---来自随心邮苹果客户端</div><br/>%@</div>",_messageView.htmlStrings];
    [sendController setInnerText:str];
    
    switch (type) {
        case 10001:
        {
            //回复
            NSString *sender = nil;
            NSString *subject = nil;
            if (self.requestSessionType == TYPEIMAP) {
                sender = _message.header.from.mailbox;
                subject = _message.header.subject;
            }else{
                sender = self.popMailHeader.from.mailbox;
                subject = self.popMessage.header.subject;
            }
            [sendController setSubjectString:subject];
            [sendController setReceiversString:sender];
            [sendController setReplayType:SINGLEREPLAY];
        }
            break;
        case 10002:
        {
            //回复全部
            NSString *sender = nil;
            NSString *receiver = nil;
            NSString *subject = nil;
            if (self.requestSessionType == TYPEIMAP) {
                subject = _message.header.subject;
                sender = _message.header.from.mailbox;
                receiver = sender;
                NSArray *array = _message.header.to;
                for (MCOAddress *receiverAddress in array)
                {
                   receiver = [receiver stringByAppendingString:[NSString stringWithFormat:@";%@",receiverAddress.mailbox]];
                }
            }else{
                sender = self.popMailHeader.from.mailbox;
                subject = self.popMessage.header.subject;
                receiver = sender;
                NSArray *array = self.popMessage.header.to;
                for (MCOAddress *receiverAddress in array)
                {
                    receiver = [receiver stringByAppendingString:[NSString stringWithFormat:@";%@",receiverAddress.mailbox]];
                }
            }
            [sendController setSubjectString:subject];
            [sendController setReceiversString:receiver];
            [sendController setReplayType:ALLREPLAY];
        }
            break;
        case 10003:
        {
            //转发
            [sendController setReplayType:TRANSMIT];
            
        }
            break;
            
        default:
            break;
    }

    [self.navigationController pushViewController:sendController animated:YES];
    [sendController release];



}

#pragma mark -- 删除邮件
- (void)deleteMail
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"是否删除邮件"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确定", nil];
    [alert showAlertViewWithBlock:^(NSInteger buttonIndex) {
       
        if (buttonIndex == 1) {
            if (self.requestSessionType == TYPEPOP) {
                MCOPOPSession *popsession = [[[MCOPOPSession alloc] init] autorelease];
                MCOIndexSet *set = [MCOIndexSet indexSetWithIndex:self.popIndex];
                MCOPOPOperation *op = [popsession deleteMessagesOperationWithIndexes:set];
                [op start:^(NSError *error) {
                    if (error) {
                        
                        NSLog(@"删除成功!");
                        
                        [Util showTipsLabels:self.view setMsg:@"删除失败" setOffset:0.0];
                    }else
                        [self deleteSuccess];
                }];
            }else{
                
                MCOIMAPOperation * op = [_session storeFlagsOperationWithFolder:@"INBOX"
                                                                          uids:[MCOIndexSet indexSetWithIndex:[_message uid]]
                                                                          kind:MCOIMAPStoreFlagsRequestKindSet
                                                                         flags:MCOMessageFlagDeleted];
               
                [op start:^(NSError * error) {
                    if(!error) {
                        NSLog(@"删除成功!");
                        
                        [self deleteSuccess];
                        
                    } else {
                       [Util showTipsLabels:self.view setMsg:@"删除失败" setOffset:0.0];
                    }
                }];
            }
        }
    }];
}

//删除成功
-(void) deleteSuccess
{
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(refreshMail)]) {
        [_delegate refreshMail];
    }
}


- (void)viewDidLoad {
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    _messageView = [[MCOMessageView alloc] initWithFrame:frame];
    _messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_messageView];
    
    CGFloat deta = 0;
    if (IOS7_OR_LATER) {
        deta = 20;
    }
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _messageView.frame.size.height + _messageView.frame.origin.y - 44 - deta, _messageView.frame.size.width, 44)];
    [self.view addSubview:bottomView];
    [bottomView setBackgroundColor:[UIColor colorWithRed:180.0/255.0 green:208.0/255.0 blue:240.0/255.0 alpha:1]];
    
    UIButton *replayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [replayBtn setFrame:CGRectMake(10, 10, 60, 30)];
    [replayBtn setTitle:@"回复" forState:UIControlStateNormal];
    [replayBtn setTitle:@"回复" forState:UIControlStateHighlighted];
    [replayBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [replayBtn setTitleColor:[UIColor colorWithRed:38.0/255.0 green:143.0/255.0 blue:241.0/255.0 alpha:1] forState:UIControlStateNormal];
    [bottomView addSubview:replayBtn];
    [replayBtn addTarget:self action:@selector(showReplayType) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [delBtn setFrame:CGRectMake(10 + 60 + 10, 10, 60, 30)];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setTitle:@"删除" forState:UIControlStateHighlighted];
    [delBtn setTitleColor:[UIColor colorWithRed:38.0/255.0 green:143.0/255.0 blue:241.0/255.0 alpha:1] forState:UIControlStateNormal];
    [bottomView addSubview:delBtn];
    [delBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(deleteMail) forControlEvents:UIControlEventTouchUpInside];

    [bottomView release];
    
    if (self.requestSessionType == TYPEPOP) {
        
        NSLog(@"self.pop ---- %d",self.popIndex);
        
        [self showLoadingWithTips:@"正在加载中..."];
        
        MCOPOPSession *popsession = [[[MCOPOPSession alloc] init] autorelease];
        [popsession setCheckCertificateEnabled:NO];
        [popsession setConnectionType:MCOConnectionTypeClear];
        [popsession setHostname:[Util getObjFromUserDefualt:SENDER_SERVER]];
        [popsession setPort:[[Util getObjFromUserDefualt:SENDER_PORT] integerValue]];
        [popsession setUsername:[Util getObjFromUserDefualt:SENDER]];
        [popsession setPassword:[Util getObjFromUserDefualt:SENDER_PWD]];
        
//        MCOPOPFetchMessageOperation *op = [self.popSession fetchMessageOperationWithIndex:self.popIndex];
        MCOPOPFetchMessageOperation *op = [popsession fetchMessageOperationWithIndex:self.popIndex];
        [op start:^(NSError *error, NSData *messageData) {
            if (error) {
                return ;
            }else{
                MCOMessageParser * msg = [MCOMessageParser messageParserWithData:messageData];
                [_messageView setDelegate:self];
                [_messageView setFolder:_folder];
                [_messageView setMessage:msg];
                self.popMessage = msg;

            }
        }];
        
    }else{
        
        [self showLoadingWithTips:@"正在加载中..."];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
            [_messageView setDelegate:self];
            [_messageView setFolder:_folder];
            [_messageView setMessage:_message];
        }
        else {
            [_messageView setMessage:NULL];
            MCOIMAPFetchContentOperation * op = [_session fetchMessageByUIDOperationWithFolder:_folder uid:[_message uid]];
            [_ops addObject:op];
            [op start:^(NSError * error, NSData * data) {
                if ([error code] != MCOErrorNone) {
                    return;
                }
                
                NSAssert(data != nil, @"data != nil");
                
                MCOMessageParser * msg = [MCOMessageParser messageParserWithData:data];
                
                [_messageView setDelegate:self];
                [_messageView setFolder:_folder];
                [_messageView setMessage:msg];
            }];
        }
    }
}

- (void) setMessage:(MCOIMAPMessage *)message
{
//    NSArray *array = [_message attachments];
	MCLog("set message : %s", message.description.UTF8String);
    for(MCOOperation * op in _ops) {
        [op cancel];
    }
    [_ops removeAllObjects];
    
    [_callbacks removeAllObjects];
    [_pending removeAllObjects];
    [_storage removeAllObjects];
    _message = message;
}

- (MCOIMAPMessage *) message
{
    return _message;
}

- (MCOIMAPFetchContentOperation *) _fetchIMAPPartWithUniqueID:(NSString *)partUniqueID folder:(NSString *)folder
{
    if ([_pending containsObject:partUniqueID]) {
        return nil;
    }
    
    MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:partUniqueID];
    NSAssert(part != nil, @"part != nil");
    
    [_pending addObject:partUniqueID];
    
    MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:folder uid:[_message uid] partID:[part partID] encoding:[part encoding]];
    [_ops addObject:op];
    [op start:^(NSError * error, NSData * data) {
        if ([error code] != MCOErrorNone) {
            [self _callbackForPartUniqueID:partUniqueID error:error];
            return;
        }
        
        NSAssert(data != NULL, @"data != nil");
        [_ops removeObject:op];
        [_storage setObject:data forKey:partUniqueID];
        [_pending removeObject:partUniqueID];
        [self _callbackForPartUniqueID:partUniqueID error:nil];
    }];
    
    return op;
}

typedef void (^DownloadCallback)(NSError * error);

- (void) _callbackForPartUniqueID:(NSString *)partUniqueID error:(NSError *)error
{
    NSArray * blocks;
    blocks = [_callbacks objectForKey:partUniqueID];
    for(DownloadCallback block in blocks) {
        block(error);
    }
}

- (NSString *) MCOMessageView_templateForAttachment:(MCOMessageView *)view
{
    //add by gwj
//    return @"<div><img src=\"http://www.iconshock.com/img_jpg/OFFICE/general/jpg/128/attachment_icon.jpg\"/></div>\
//    {{#HASSIZE}}\
//    <div>- {{FILENAME}}, {{SIZE}}</div>\
//    {{/HASSIZE}}\
//    {{#NOSIZE}}\
//    <div>- {{FILENAME}}</div>\
//    {{/NOSIZE}}";
    
    //end
    
    return @"<div></div>";
    
}

- (NSString *) MCOMessageView_templateForMessage:(MCOMessageView *)view
{
    return @"<div style=\"padding-bottom: 20px; font-family: Helvetica; font-size: 13px;\">{{HEADER}}</div><div>{{BODY}}</div>";
}

- (BOOL) MCOMessageView:(MCOMessageView *)view canPreviewPart:(MCOAbstractPart *)part
{
     return NO;
    
    //add by gwj
 
//    // tiff, tif, pdf
//    NSString * mimeType = [[part mimeType] lowercaseString];
//    if ([mimeType isEqualToString:@"image/tiff"]) {
//        return YES;
//    }
//    else if ([mimeType isEqualToString:@"image/tif"]) {
//        return YES;
//    }
//    else if ([mimeType isEqualToString:@"application/pdf"]) {
//        return YES;
//    }
//    
//    NSString * ext = nil;
//    if ([part filename] != nil) {
//        if ([[part filename] pathExtension] != nil) {
//            ext = [[[part filename] pathExtension] lowercaseString];
//        }
//    }
//    if (ext != nil) {
//        if ([ext isEqualToString:@"tiff"]) {
//            return YES;
//        }
//        else if ([ext isEqualToString:@"tif"]) {
//            return YES;
//        }
//        else if ([ext isEqualToString:@"pdf"]) {
//            return YES;
//        }
//    }
//    return NO;
    
    
   
}

- (NSString *) MCOMessageView:(MCOMessageView *)view filteredHTML:(NSString *)html
{
    return html;
}

- (NSData *) MCOMessageView:(MCOMessageView *)view dataForPartWithUniqueID:(NSString *)partUniqueID
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"FetchFullMessageEnabled"]) {
		MCOAttachment * attachment = (MCOAttachment *) [[_messageView message] partForUniqueID:partUniqueID];
		return [attachment data];
	}
	else {
		NSData * data = [_storage objectForKey:partUniqueID];
		return data;
	}
}

- (void) MCOMessageView:(MCOMessageView *)view fetchDataForPartWithUniqueID:(NSString *)partUniqueID
     downloadedFinished:(void (^)(NSError * error))downloadFinished
{
    MCOIMAPFetchContentOperation * op = [self _fetchIMAPPartWithUniqueID:partUniqueID folder:_folder];
    [op setProgress:^(unsigned int current, unsigned int maximum) {
        
        NSLog(@"progress content: %u/%u", current, maximum);
        if (current == maximum) {
            [self hiddenHud];
        }
        
    }];
    if (op != nil) {
        [_ops addObject:op];
    }
    if (downloadFinished != NULL) {
        NSMutableArray * blocks;
        blocks = [_callbacks objectForKey:partUniqueID];
        if (blocks == nil) {
            blocks = [NSMutableArray array];
            [_callbacks setObject:blocks forKey:partUniqueID];
        }
        [blocks addObject:[downloadFinished copy]];
    }else{
          [self hiddenHud];
    }
}

- (NSData *) MCOMessageView:(MCOMessageView *)view previewForData:(NSData *)data isHTMLInlineImage:(BOOL)isHTMLInlineImage
{
    if (isHTMLInlineImage) {
        return data;
    }
    else {
        return [self _convertToJPEGData:data];
    }
}

#define IMAGE_PREVIEW_HEIGHT 300
#define IMAGE_PREVIEW_WIDTH 500

- (NSData *) _convertToJPEGData:(NSData *)data {
    CGImageSourceRef imageSource;
    CGImageRef thumbnail;
    NSMutableDictionary * info;
    imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    if (imageSource == NULL)
        return nil;
    
    info = [[NSMutableDictionary alloc] init];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailWithTransform];
    [info setObject:(id) kCFBooleanTrue forKey:(id) kCGImageSourceCreateThumbnailFromImageAlways];
    [info setObject:(id) [NSNumber numberWithFloat:(float) IMAGE_PREVIEW_WIDTH] forKey:(id) kCGImageSourceThumbnailMaxPixelSize];
    thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (CFDictionaryRef) info);
    
    CGImageDestinationRef destination;
    NSMutableData * destData = [NSMutableData data];
    
    destination = CGImageDestinationCreateWithData((CFMutableDataRef) destData,
                                                   (CFStringRef) @"public.jpeg",
                                                   1, NULL);
    
    CGImageDestinationAddImage(destination, thumbnail, NULL);
    CGImageDestinationFinalize(destination);
    
    CFRelease(destination);
    
    CFRelease(thumbnail);
    CFRelease(imageSource);
    
    [info release];
    
    return destData;
}


#pragma mark gwj

#pragma mark preview fj
- (void)MessageView:(MCOMessageView *)view preViewFj:(NSString *)_id
{
    NSArray *array = nil;
    if (self.requestSessionType == TYPEIMAP) {
        array = [_message attachments];
    }else
        array = [self.popMessage attachments];
    
    if (array.count == 0) {
        return;
    }
    
    MCOAbstractPart *attach = [array objectAtIndex:[_id integerValue]];
    NSLog(@"name - %@",attach.filename);
    NSURL *pathUrl = [NSURL fileURLWithPath:[Util getFileAtDocumentPath:attach.filename]];
    
    
    if (_docInteractionController == nil) {
        _docInteractionController = [[UIDocumentInteractionController interactionControllerWithURL:pathUrl] retain];
        _docInteractionController.delegate = self;
    }else {
        _docInteractionController.URL = pathUrl;
    }
    BOOL flag = [_docInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    if (!flag) {
        [Util showTipsLabels:self.view setMsg:@"暂不能预览" setOffset:0];
    }
}

#pragma mark download delegate
- (void)MessageView:(MCOMessageView *)view downLoadFj:(NSString *)_id
{
    [self downLoadFjById:_id];
}

- (void)downLoadFjById:(NSString *)_id
{

    
    if (self.requestSessionType == TYPEPOP) {
        
        NSArray *array = [self.popMessage attachments];
        MCOAttachment *attach = [array objectAtIndex:_id.integerValue];
        NSString *logFilePath = [Util getFileAtDocumentPath:attach.filename];
        [[NSFileManager defaultManager] createFileAtPath:logFilePath
                                                contents:attach.data
                                              attributes:NULL];
        [_messageView changeTitleById:_id];
        
    }else{
        NSArray *array = [_message attachments];
        if (array.count == 0) {
            return;
        }
        
        MCOAbstractPart *attach = [array objectAtIndex:[_id integerValue]];
        MCOIMAPPart * part = (MCOIMAPPart *) [_message partForUniqueID:attach.uniqueID];
        
        MCOIMAPFetchContentOperation * op = [_session fetchMessageAttachmentByUIDOperationWithFolder:self.folder uid:[_message uid] partID:[part partID] encoding:[part encoding]];
        
        
        
        [op start:^(NSError *error, NSData *data) {
            
            NSString *logFilePath = [Util getFileAtDocumentPath:attach.filename];//[NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@",attach.filename];
            [[NSFileManager defaultManager] createFileAtPath:logFilePath contents:data attributes:NULL];
        }];
        
        [self showLoadingWithTips:@"下载附件中"];
        [op setProgress:^(unsigned int current, unsigned int maximum) {
    
            if (maximum == current && maximum > 0) {
                
                [self hiddenHud];
                [_messageView changeTitleById:_id];
            }
        }];
    }
}

- (void)MessageViewStopLoading
{
    [self hiddenHud];
}


@end

