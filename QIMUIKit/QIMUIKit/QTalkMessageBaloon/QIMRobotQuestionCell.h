//
//  QCIMConsultCell.h
//  IMSDK
//
//  Created by chenjie on 2017/08/08.
//  Copyright © 2017年 qunar. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"

@protocol QIMRobotQuestionCellDelegate <NSObject>

/* 发送文本消息 */
- (void) sendTextMessageForText:(NSString *)messageContent isSendToServer:(BOOL)isSendToServer userType:(NSString *)userType;

/* 刷新该语音消息cell */
- (void) refreshRobotQuestionMessageCell:(QIMMsgBaloonBaseCell *)cell;

@end

@interface QIMRobotQuestionCell : QIMMsgBaloonBaseCell

@property (nonatomic, weak) id<QIMRobotQuestionCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

+ (float)cellHeightForMessage:(Message *)msg chatType:(ChatType)chatType;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier WithChatType:(ChatType)chatType;

@end
