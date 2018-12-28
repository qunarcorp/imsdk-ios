//
//  QIMSearchRemindView.h
//  QIMUIKit
//
//  Created by lilu on 2018/12/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QIMSearchRemindView : UIView

- (instancetype)initWithChatId:(NSString *)chatId withRealJid:(NSString *)realjid withChatType:(NSInteger)chatType;

@end

NS_ASSUME_NONNULL_END
