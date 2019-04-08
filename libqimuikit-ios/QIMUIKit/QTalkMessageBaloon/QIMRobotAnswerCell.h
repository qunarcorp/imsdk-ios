//
//  QIMRobotAnswerCell.h
//  QIMUIKit
//
//  Created by 李露 on 11/9/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"

@protocol QIMRobotAnswerCellLoadDelegate <NSObject>

- (void)refreshRobotAnswerMessageCell:(QIMMsgBaloonBaseCell *)cell;

- (void)reTeachRobot;

@end

@interface QIMRobotAnswerCell : QIMMsgBaloonBaseCell

@property (nonatomic, weak) id<QIMRobotAnswerCellLoadDelegate,QIMMsgBaloonBaseCellDelegate> delegate;

@end
