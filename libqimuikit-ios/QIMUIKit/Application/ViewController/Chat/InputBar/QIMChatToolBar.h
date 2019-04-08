
#import "QIMCommonUIFramework.h"
#import "QTalkTextView.h"
#import "QIMRecordButton.h"

typedef NS_ENUM(NSInteger, ButKind)
{
    kButKindVoice,
    kButKindFace,
    kButKindMore,
    kButKindSwitchBar
};

@class QIMChatToolBar;
@class QIMChatToolBarItem;

@protocol QIMChatToolBarDelegate <NSObject>

@optional
- (void)chatToolBar:(QIMChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(QIMChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBar:(QIMChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change;
- (void)chatToolBarSwitchToolBarBtnPressed:(QIMChatToolBar *)toolBar keyBoardState:(BOOL)change;

- (void)chatToolBarDidStartRecording:(QIMChatToolBar *)toolBar;
- (void)chatToolBarDidCancelRecording:(QIMChatToolBar *)toolBar;
- (void)chatToolBarDidFinishRecoding:(QIMChatToolBar *)toolBar;
- (void)chatToolBarWillCancelRecoding:(QIMChatToolBar *)toolBar;
- (void)chatToolBarContineRecording:(QIMChatToolBar *)toolBar;

- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView;
- (void)chatToolBarSendText:(NSString *)text;
- (void)chatToolBarTextViewDidChange:(UITextView *)textView;
- (void)chatToolBarTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)chatToolBarTextViewDeleteBackward:(QTalkTextView *)textView;
@end


@interface QIMChatToolBar : UIImageView

@property (nonatomic, weak) id<QIMChatToolBarDelegate> delegate;

/** 切换barView按钮 */
@property (nonatomic, readonly, strong) UIButton *switchBarBtn;
/** 语音按钮 */
@property (nonatomic, readonly, strong) UIButton *voiceBtn;
/** 表情按钮 */
@property (nonatomic, readonly, strong) UIButton *faceBtn;
/** more按钮 */
@property (nonatomic, readonly, strong) UIButton *moreBtn;
/** 输入文本框 */
@property (nonatomic, readonly, strong) QTalkTextView *textView;

//@property (nonatomic, assign) BOOL chatToolTextViewShow;
/** 按住录制语音按钮 */
//@property (nonatomic, readonly, strong) QIMRecordButton *recordBtn;

/** 默认为no */
@property (nonatomic, assign) BOOL allowSwitchBar;
/** 以下默认为yes*/
@property (nonatomic, assign) BOOL allowVoice;
@property (nonatomic, assign) BOOL allowFace;
@property (nonatomic, assign) BOOL allowMoreFunc;

@property (readonly) BOOL voiceSelected;
@property (readonly) BOOL faceSelected;
@property (readonly) BOOL moreFuncSelected;
@property (readonly) BOOL switchBarSelected;


/**
 *  配置textView内容
 */
- (void)setTextViewContent:(NSString *)text;
- (void)clearTextViewContent;

/**
 *  配置placeHolder
 */
- (void)setTextViewPlaceHolder:(NSString *)placeholder;
- (void)setTextViewPlaceHolderColor:(UIColor *)placeHolderColor;

/**
 *  为开始评论和结束评论做准备
 */
- (void)prepareForBeginComment;
- (void)prepareForEndComment;


/**
 *  加载数据
 */
- (void)loadBarItems:(NSArray<QIMChatToolBarItem *> *)barItems;

@end
