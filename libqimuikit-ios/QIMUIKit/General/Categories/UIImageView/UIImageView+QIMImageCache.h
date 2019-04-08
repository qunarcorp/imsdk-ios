//
//  UIImageView+QIMImageCache.h
//  QIMUIKit
//
//  Created by 李露 on 2018/8/27.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface UIImageView (QIMImageCache)

- (void)qim_setImageWithJid:(NSString *)jid;

- (void)qim_setImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (void)qim_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType;

- (void)qim_setImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType placeholderImage:(UIImage *)placeholder;

- (void)qim_setImageWithJid:(NSString *)jid WithRealJid:(NSString *)realJid WithChatType:(NSInteger)chatType placeholderImage:(UIImage *)placeholder;

- (void)qim_setCollectionImageWithJid:(NSString *)jid WithChatType:(NSInteger)chatType;

- (void)qim_setImageWithURL:(NSURL *)url;

- (void)qim_setImageWithURL:(NSURL *)url WithChatType:(ChatType)chatType;

- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;

- (void)qim_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDExternalCompletionBlock)completedBlock;

@end
