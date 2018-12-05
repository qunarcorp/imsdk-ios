//
//  QIMVoiceChatView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/13.
//
//

typedef enum {
    VoiceChatRecordingStatusStart,
    VoiceChatRecordingStatusRecording,
    VoiceChatRecordingStatusEnd,
    VoiceChatRecordingStatusCancel,
    VoiceChatRecordingStatusAudition,
    VoiceChatRecordingStatusSend,
} VoiceChatRecordingStatus;

typedef enum {
    VoiceBtnStatusNomal,
    VoiceBtnStatusRecording,
    VoiceBtnStatusAuditionStart,
    VoiceBtnStatusAuditionStop,
} VoiceBtnStatus;

#import "QIMCommonUIFramework.h"

@class QIMVoiceChatView;

@protocol QIMVoiceChatViewDelegate <NSObject>

- (void)voiceChatView:(QIMVoiceChatView *)voiceChatView RecordingAtStatus:(VoiceChatRecordingStatus)status;

@end

@interface QIMVoiceChatView : UIView
@property (nonatomic,assign)id<QIMVoiceChatViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame;

- (void)stopPlayVoice;

@end
