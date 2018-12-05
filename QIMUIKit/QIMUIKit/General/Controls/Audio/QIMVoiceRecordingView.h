//
//  QIMVoiceRecordingView.h
//  AudioTempForQT
//
//  Created by danzheng on 15/4/21.
//  Copyright (c) 2015年 fresh. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMVoiceRecordingView : UIView

- (void)beginDoRecord;
- (void)doImageUpdateWithVoicePower:(float)voicePower;
//change 15/5/4 去掉时间限制功能，删除剩余时间的提醒
//- (void)doRemindUserWithRemainTime:(float)remainTime;

//add 15/5/13  用于手指上滑可以取消发送的提醒 以及 状态返回
- (void)voiceMaybeCancelWithState:(BOOL)ifMaybeCancel;

@end
