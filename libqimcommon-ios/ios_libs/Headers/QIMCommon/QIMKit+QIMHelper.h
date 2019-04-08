//
//  QIMKit+QIMHelper.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/4/3.
//

#import "QIMKit.h"

@interface QIMKit (QIMHelper)

/**
 红包提示音
 */
- (void)playHongBaoSound;

/**
 新消息提示音
 */
- (void)playSound;

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;

/**
 窗口抖动
 */
- (void)shockWindow;

@end
