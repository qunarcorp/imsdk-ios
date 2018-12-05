//
//  QIMSingleChatImageTools.h
//  DangDiRen
//
//  Created by 平 薛 on 14-4-23.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMSingleChatImageTools : NSObject

+ (QIMSingleChatImageTools *)sharedInstance;

- (UIImage *)getSentBg;
- (UIImage *)getReceivedBg;
- (UIImage *)getImageDownloadFaildWithDirect:(int)direct;
- (UIImage *)getImageDownloading;

@end
