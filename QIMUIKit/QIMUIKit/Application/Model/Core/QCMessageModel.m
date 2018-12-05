//
//  QCMessageModel.m
//  qunarChatIphone
//
//  Created by c on 15/5/12.
//  Copyright (c) 2015年 c. All rights reserved.
//

#import "QCMessageModel.h"

@implementation QCMessageModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageId      = nil;
        self.messageContent = nil;
        self.messageType    = QCMessageTypeNone;
        self.from           = nil;
        self.to             = nil;
    }
    return self;
}

@end
