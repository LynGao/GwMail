//
//  MCOAbstractMessage.m
//  mailcore2
//
//  Created by DINH Viêt Hoà on 3/10/13.
//  Copyright (c) 2013 MailCore. All rights reserved.
//

#import "MCOAbstractMessage.h"

#include "MCAbstractMessage.h"
#include "MCMessageHeader.h"
#include "MCAbstractPart.h"

#import "MCOMessageHeader.h"
#import "MCOAbstractPart.h"
#import "NSObject+MCO.h"
#import "NSString+MCO.h"

@implementation MCOAbstractMessage {
    mailcore::AbstractMessage * _message;
}

#define nativeType mailcore::AbstractMessage

- (mailcore::Object *) mco_mcObject
{
    return _message;
}

- (id) init
{
    MCAssert(0);
    return nil;
}

- (id) initWithMCMessage:(mailcore::AbstractMessage *)message
{
    self = [super init];
    
    message->retain();
    _message = message;
    
    return self;
}

- (id) copyWithZone:(NSZone *)zone
{
    nativeType * nativeObject = (nativeType *) [self mco_mcObject]->copy();
    id result = [[self class] mco_objectWithMCObject:nativeObject];
    MC_SAFE_RELEASE(nativeObject);
    return [result retain];
}

- (void) dealloc
{
    MC_SAFE_RELEASE(_message);
    [super dealloc];
}

- (NSString *) description
{
    return MCO_OBJC_BRIDGE_GET(description);
}

MCO_OBJC_SYNTHESIZE(MessageHeader, setHeader, header)

- (MCOAbstractPart *) partForContentID:(NSString *)contentID
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->partForContentID([contentID mco_mcString]));
}

- (MCOAbstractPart *) partForUniqueID:(NSString *)uniqueID
{
    return MCO_TO_OBJC(MCO_NATIVE_INSTANCE->partForUniqueID([uniqueID mco_mcString]));
}

- (NSArray *) attachments
{
    NSLog(@"MCO_OBJC_BRIDGE_GET(attachments) %@",MCO_OBJC_BRIDGE_GET(attachments));
    return MCO_OBJC_BRIDGE_GET(attachments);
}

- (NSArray *) htmlInlineAttachments
{
        NSLog(@"MCO_OBJC_BRIDGE_GET(htmlInlineAttachments) %@",MCO_OBJC_BRIDGE_GET(htmlInlineAttachments));
    
    return MCO_OBJC_BRIDGE_GET(htmlInlineAttachments);
}

@end