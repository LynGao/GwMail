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


@interface ReceiveDetailViewController () <MCOMessageViewDelegate,UIDocumentInteractionControllerDelegate>
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

#pragma mark -- 回复邮件
- (void)replayMail
{
    SendMailViewController *send = [[SendMailViewController alloc] init];
    [self presentViewController:send
                       animated:YES
                     completion:NULL];
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
                        [Util showTipsLabels:self.view setMsg:@"删除失败" setOffset:0.0];
                    }
                }];
            }else{
                MCOIMAPSession *session = [[[MCOIMAPSession alloc] init] autorelease];
                
                MCOIMAPOperation *op = [session storeFlagsOperationWithFolder:@"INBOX"
                                                                         uids:[MCOIndexSet indexSetWithIndex:[_message uid]]
                                                                         kind:MCOIMAPStoreFlagsRequestKindSet
                                                                        flags:MCOMessageFlagDeleted];
                [op start:^(NSError * error) {
                    if(!error) {
                        NSLog(@"Updated flags!");
                    } else {
                       [Util showTipsLabels:self.view setMsg:@"删除失败" setOffset:0.0];
                    }
                
                    MCOIMAPOperation *deleteOp = [session expungeOperation:@"INBOX"];
                    [deleteOp start:^(NSError *error) {
                        if(error) {
                            NSLog(@"Error expunging folder:%@", error);
                        } else {
                            NSLog(@"Successfully expunged folder");
                        }
                    }];
                }];
            }
        }
    }];
}

- (void)viewDidLoad {
    
    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 44);
    _messageView = [[MCOMessageView alloc] initWithFrame:frame];
    _messageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_messageView];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, _messageView.frame.size.height + _messageView.frame.origin.y - 44, _messageView.frame.size.width, 44)];
    [self.view addSubview:bottomView];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *replayBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [replayBtn setFrame:CGRectMake(10, 10, 44, 35)];
    [replayBtn setTitle:@"回复" forState:UIControlStateNormal];
    [replayBtn setTitle:@"回复" forState:UIControlStateHighlighted];
    [bottomView addSubview:replayBtn];
    [replayBtn addTarget:self action:@selector(replayMail) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *delBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [delBtn setFrame:CGRectMake(10 + 44 + 10, 10, 44, 40)];
    [delBtn setTitle:@"删除" forState:UIControlStateNormal];
    [delBtn setTitle:@"删除" forState:UIControlStateHighlighted];
    [bottomView addSubview:delBtn];
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
                
                NSString *str = [[[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding] autorelease];

                MCOMessageParser * msg = [MCOMessageParser messageParserWithData:messageData];
                [_messageView setDelegate:self];
                [_messageView setFolder:_folder];
                [_messageView setMessage:msg];
                self.popMessage = msg;

            }
        }];
        
    }else{
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
    
    NSArray *array = [_message attachments];
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
        MCLog("progress content: %u/%u", current, maximum);
        
        NSLog(@"progress content: %u/%u", current, maximum);
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

