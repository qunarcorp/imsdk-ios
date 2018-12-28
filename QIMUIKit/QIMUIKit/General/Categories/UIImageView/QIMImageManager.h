//
//  QIMImageManager.h
//  QIMUIKit
//
//  Created by 李露 on 2018/8/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface QIMImageManager : NSObject

+ (instancetype)sharedInstance;

- (void)initWithQIMImageCacheNamespace:(NSString *)ns;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (NSString *)qim_getHeaderCachePathWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType;

- (NSString *)qim_getHeaderCachePathWithHeaderUrl:(NSString *)headerUrl;

- (UIImage *)getUserHeaderImageByUserId:(NSString *)jid;

@end
