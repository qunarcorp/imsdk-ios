//
//  QIMSingleChatVoiceCell.h
//  DangDiRen
//
//  Created by ping.xue on 14-3-27.
//  Copyright (c) 2014年 Qunar.com. All rights reserved.
//
//  为了完成groupChat中识别音频发起人，将voiceCell的refreshUI分为doChatVCRefresh和doGroupChatVCRefresh两部分。在ChatVC中直接使用doChatVCRefresh，在groupChatVC中使用doGroupChatVCRefresh。

#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"

@class Message;

@protocol QIMSingleChatVoiceCellDelegate;

#define kNotifyPlayVoiceTime                @"kNotifyPlayProcess"
#define kNotifyPlayVoiceTimeMsgId           @"kNotifyPlayVoiceTimeMsgId"
#define kNotifyPlayVoiceTimeTime            @"kNotifyPlayVoiceTimeTime"

#define kNotifyDownloadProgress             @"kNotifyDownloadProgress"
#define kNotifyDownloadProgressMsgId        @"kNotifyDownloadProgressMsgId"
#define kNotifyDownloadProgressProgress     @"kNotifyDownloadProgressProgress"


@interface QIMSingleChatVoiceCell : QIMMsgBaloonBaseCell<QIMMenuImageViewDelegate>

@property (nonatomic, weak) id<QIMSingleChatVoiceCellDelegate,QIMMsgBaloonBaseCellDelegate> delegate;
@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, copy) NSString *messageDate;
@property (nonatomic, assign) BOOL isGroupVoice;

- (void)refreshUI;
- (void)onClick ;
@end

@protocol QIMSingleChatVoiceCellDelegate <NSObject>
@required

- (BOOL)playingVoiceWithMsgId:(NSString *)msgId;
- (int)playCurrentTime;
- (double)getCurrentDownloadProgress;

@end
