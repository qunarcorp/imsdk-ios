//
//  QIMSingleChatImageTools.m
//  DangDiRen
//
//  Created by 平 薛 on 14-4-23.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMSingleChatImageTools.h"
static QIMSingleChatImageTools *__global_chat_image_tools = nil;
@implementation QIMSingleChatImageTools{
    UIImage *_sentImageBg;
    UIImage *_receivedImageBg;
    UIImage *_downFaildImage_Receive;
    UIImage *_downFaildImage_Sent;
    UIImage *_downingImage;
}

+ (QIMSingleChatImageTools *)sharedInstance{
    if (__global_chat_image_tools == nil) {
        __global_chat_image_tools = [[QIMSingleChatImageTools alloc] init];
    }
    return __global_chat_image_tools;
}

- (id)init{
    self = [super init];
    if (self) {
        _sentImageBg = [[UIImage imageNamed:@"im_sent_msg_bg"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
        _receivedImageBg = [[UIImage imageNamed:@"im_receive_msg_bg"] stretchableImageWithLeftCapWidth:20 topCapHeight:15];
    }
    return self;
}

- (UIImage *)getSentBg{
    return _sentImageBg;
}
- (UIImage *)getReceivedBg{
    return _receivedImageBg;
}

- (UIImage *)getImageDownloadFaildWithDirect:(int)direct{
    if (direct == 0) {
        if (_downFaildImage_Sent == nil) {
            _downFaildImage_Sent = [UIImage imageNamed:kImageDownloadFailImageFileName];
        }
        return _downFaildImage_Sent;
    } else {
        if (_downFaildImage_Receive == nil) {
            _downFaildImage_Receive = [UIImage imageNamed:kImageDownloadFailImageFileName];
        }
        return _downFaildImage_Receive;
    }
}

- (UIImage *)getImageDownloading{
    if (_downingImage == nil) {
        _downingImage = [UIImage imageNamed:kImageDownloadFailImageFileName];
    }
    return _downingImage;
}

@end
