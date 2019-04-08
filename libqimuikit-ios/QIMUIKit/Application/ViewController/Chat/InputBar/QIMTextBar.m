//
//  QIMTextBar.m
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/24.
//
//

#define kEmotionBtnFrom 10000
#define kTextFont [UIFont systemFontOfSize:17]
#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

#define normalImage [UIImage qim_imageFromColor:[UIColor whiteColor]]

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define kTextViewFirstLineHeadIndent    30.0f
#define kReferAlertViewTag      1000
#define kReferAlertViewNotDisplay      @"kReferAlertViewNotDisplay"

//键盘上面的工具条
#define kQIMChatToolBarHeight              49

//表情模块高度
#define kFacePanelHeight                220
#define kFacePanelBottomToolBarHeight   40
#define kUIPageControllerHeight         25

//拍照、发视频等更多功能模块的面板的高度
#define kMorePanelHeight                220
#define kChatKeyBoardHeight     kQIMChatToolBarHeight + kFacePanelHeight

#import <MobileCoreServices/MobileCoreServices.h>

#import "QIMTextBar.h"
#import "UIApplication+QIMApplication.h"
#import "QIMUUIDTools.h"
#import "NSBundle+QIMLibrary.h"
#import "QIMChatToolBarItem.h"
#import "QIMPathManage.h"
#import "QIMVoiceOperator.h"
#import "IMAmrFileCodec.h"
#import "QIMATGroupMemberTextAttachment.h"
#import "QIMMessageManagerFaceView.h"
#import "QIMGroupATNotifyVC.h"
#import "QIMViewHelper.h"
#import "QIMRemoteAudioPlayer.h"
#import "QIMStringTransformTools.h"
#import "QIMImageUtil.h"
#import "CameraViewController.h"
#import "QIMCollectionFaceManager.h"
#import "QTImagePickerController.h"
#import "MBProgressHUD.h"
#import "QIMHistoryMsgManager.h"

#import "QIMHistoryMsgListViewController.h"

#import "QIMEmojiTextAttachment.h"

#import "QIMTextView.h"
#import "QIMUIImagePickerBrowserVC.h"
#import "QIMEmotionsDownloadViewController.h"
#import "QIMOfficialAccountToolbar.h"
#import "QIMEmotionManager.h"
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_0
#import "QTPHImagePickerController.h"
#import "QIMEmotionManagerView.h"
#endif

#import "QIMAuthorizationManager.h"

@interface NSAttributedString (EmojiExtension)
- (NSString *)getPlainString;
@end

@implementation NSAttributedString (EmojiExtension)

- (NSString *)getPlainString {
    //最终纯文本
    NSMutableString *plainString = [NSMutableString stringWithString:self.string];
    
    //替换下标的偏移量
    __block NSUInteger base = 0;
    
    //遍历
    [self enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.length)
                     options:0
                  usingBlock:^(id value, NSRange range, BOOL *stop) {
                      
                      //检查类型是否是自定义NSTextAttachment类
                      if (value && [value isKindOfClass:[QIMEmojiTextAttachment class]]) {
                          //替换
                          [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                     withString:[((QIMEmojiTextAttachment *) value) getSendText]];
                          
                          //增加偏移量
                          base += [((QIMEmojiTextAttachment *) value) getSendText].length - 1;
                      } else if (value && [value isKindOfClass:[QIMATGroupMemberTextAttachment class]]) {
                          QIMVerboseLog(@"value : %@", value);
                      }
                  }];
    
    return plainString;
}

@end

@interface IMAlertView : UIAlertView
@property (nonatomic, weak) CameraViewController *picker;
@property (nonatomic, copy) NSString *videoOutPath;
@property (nonatomic, copy) NSString *fileSizeStr;
@property (nonatomic, assign) float  videoDuration;
@property (nonatomic, strong) UIImage *thumbImage;
@end

@implementation IMAlertView

- (void)dealloc{
    [self setVideoOutPath:nil];
    [self setFileSizeStr:nil];
    [self setThumbImage:nil];
}

@end

@interface QIMTextBar(ChatVoice)<QIMVoiceOperatorDelegate,QIMTextViewDelegate,QIMTextBarExpandViewDelegate,QIMRemoteAudioPlayerDelegate,UIAlertViewDelegate,CameraViewControllerDelegate,QTImagePickerControllerDelegate,QTPHImagePickerControllerDelegate>
@end

@interface VoiceRecorderButton : UIButton

@end

@implementation VoiceRecorderButton

@end

@implementation IMTextBarInputItem
{
    
}

@end

typedef void(^SelectedEmotion)(NSString *);


#pragma mark - QIMTextBar
@interface QIMTextBar () <UITextViewDelegate,UIScrollViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate,QIMUIImagePickerBrowserVCDelegate, QIMMessageManagerFaceViewDelegate,QIMVoiceChatViewDelegate,QIMHistoryMsgListViewControllerDelegate, QIMChatToolBarDelegate, QTalkQIMEmotionManagerDelegate> {
    __weak UITableView *_associateTableView;
}

@property (nonatomic, strong) UIImageView *bgImageView;

/**
 *  聊天键盘 上一次的 y 坐标
 */
@property (nonatomic, assign) CGFloat lastChatKeyboardY;

@property (nonatomic, strong) QIMTextView *myTextView;

@property (nonatomic, strong) UIImageView *myTextViewBgImageView;

//表情发送
@property (nonatomic, strong) UIButton *sendButton;

@property (nonatomic, strong) UIButton *emotionButton;

@property (nonatomic, strong) QIMVoiceChatView *voiceView;

@property (nonatomic, strong) UIButton *voiceButton;

@property (nonatomic, strong) UIButton *expandButton;

@property (nonatomic, strong) UIButton *referButton;

@property (nonatomic, strong) UIButton *fireButton;

@property (nonatomic, assign) NSUInteger maxLine;

@property (nonatomic, assign) CGFloat maxHeight;

@property (nonatomic, assign) CGFloat minHeight;

@property (nonatomic, assign) BOOL isMaxLineState;

@property (nonatomic, assign) BOOL isFirst;

@property (nonatomic, assign) double keyboardDuration;

@property (nonatomic, assign) CGRect keyboardRect;

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, assign) BOOL isScrollToBottom;

@property (nonatomic, assign) QIMEmotionManagerView *faceView;

@property (nonatomic, strong) UIScrollView *emotionSegScrollView;

@property (nonatomic, strong) NSMutableDictionary *faceViewsDic;

@property (nonatomic, copy) SelectedEmotion onEmotionSelected;

@property (nonatomic, assign) BOOL voiceMaybeCancel; //上滑出_recordButton的区域时设置为1，此时松手则取消发送

@property (nonatomic, assign) VoiceChatRecordingStatus recordingStatus;

@property (nonatomic, strong) NSMutableDictionary *voiceInfoDic;

@property (nonatomic, strong) QIMRemoteAudioPlayer *remoteAudioPlayer;

@property (nonatomic, copy) NSString *videoPath;

@property (nonatomic, strong) CameraViewController *picker;

@property (nonatomic, strong) MBProgressHUD *tipHUD;

@property (nonatomic, copy) NSString *fileName;

@property (nonatomic, retain) QIMVoiceOperator *voiceOperator;

@property (nonatomic, strong) UIButton *showActionBtn;

@property (nonatomic, strong) UIView *boderView;


@property (nonatomic, strong) UIButton *addEmotionsBtn;

@property (nonatomic, strong) UIButton *collectEmotionBtn;

//上方发送按钮
@property (nonatomic, strong) UIButton *sendBtn;

@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) UILabel *loadingLabel;

@property (nonatomic, strong) UIView *loadView;

@property (nonatomic, strong) UIPageControl *expandPageControl;

@end

static QIMTextBar *__textBar = nil;

@implementation QIMTextBar {
    
    CGRect _rootFrame;
    UIImage *_image;
    CGFloat _left;
    CGFloat _right;
    NSUInteger  _referDelCount;
}

@synthesize replyName;
@synthesize rootFrame = _rootFrame;

static QIMTextBar *__norMalTextBar = nil;
static QIMTextBar *__singleTextBar = nil;
static QIMTextBar *__groupTextBar = nil;
static QIMTextBar *__robotTextBar = nil;
static QIMTextBar *__consultTextBar = nil;
static QIMTextBar *__consultServerTextBar = nil;
static QIMTextBar *__publicNumberTextBar = nil;

+ (instancetype)sharedIMTextBarWithBounds:(CGRect)bounds WithExpandViewType:(QIMTextBarExpandViewType)expandType {
    switch (expandType) {
        case QIMTextBarExpandViewTypeRobot: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __robotTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__robotTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __robotTextBar.frame = frame;
            }
            __robotTextBar.expandViewType = expandType;
            [__robotTextBar.expandPanel addItems];
            return __robotTextBar;
        }
            break;
        case QIMTextBarExpandViewTypePublicNumber: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __publicNumberTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__publicNumberTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __publicNumberTextBar.frame = frame;
            }
            __publicNumberTextBar.expandViewType = expandType;
            [__publicNumberTextBar.expandPanel addItems];
            return __publicNumberTextBar;
        }
            break;
        case QIMTextBarExpandViewTypeGroup: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __groupTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__groupTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __groupTextBar.frame = frame;
            }
            __groupTextBar.expandViewType = expandType;
            [__groupTextBar.expandPanel addItems];
            return __groupTextBar;
        }
            break;
        case QIMTextBarExpandViewTypeConsult: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __consultTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__consultTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __consultTextBar.frame = frame;
            }
            __consultTextBar.expandViewType = expandType;
            [__consultTextBar.expandPanel addItems];
            return __consultTextBar;
        }
            break;
        case QIMTextBarExpandViewTypeConsultServer: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __consultServerTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__consultServerTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __consultServerTextBar.frame = frame;
            }
            __consultServerTextBar.expandViewType = expandType;
            [__consultServerTextBar.expandPanel addItems];
            return __consultServerTextBar;
        }
            break;
        case QIMTextBarExpandViewTypeSingle: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __singleTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__singleTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __singleTextBar.frame = frame;
            }
            __singleTextBar.expandViewType = expandType;
            [__singleTextBar.expandPanel addItems];
            return __singleTextBar;
        }
            break;
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __norMalTextBar = [[QIMTextBar alloc] initWithFrame:frame WithExpandViewType:expandType];
            });
            if (__norMalTextBar.origin.y > CGRectGetHeight(bounds) - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) {
                CGRect frame = CGRectMake(0, bounds.size.height - kQIMChatToolBarHeight - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(bounds), kChatKeyBoardHeight);
                __norMalTextBar.frame = frame;
            }
            __norMalTextBar.expandViewType = expandType;
            return __norMalTextBar;
        }
            break;
    }
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame WithExpandViewType:(QIMTextBarExpandViewType)expandType{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor qtalkChatBgColor];
        [self resgisterNSNotifications];
        
        self.hasAtFun = FALSE;
        self.hasEmotion = YES;
        self.hasExpandKeyboard = YES;
        self.hasVoice = YES;
        self.expandViewType = expandType;
        _currentRange = NSMakeRange(0, 0);
        _image = [UIImage qim_imageFromColor:[UIColor qim_colorWithHex:0xebecef alpha:1]];
        
        self.lastChatKeyboardY = frame.origin.y;
        
        [self addSubview:self.chatToolBar];
        _isScrollToBottom = YES;
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:5];
        QIMChatToolBarItem *item1 = [QIMChatToolBarItem barItemWithKind:kBarItemFace normal:@"face" high:@"face_HL" select:@"keyboard"];
        [items addObject:item1];
        QIMChatToolBarItem *item2 = [QIMChatToolBarItem barItemWithKind:kBarItemVoice normal:@"voice" high:@"voice_HL" select:@"keyboard"];
        [items addObject:item2];
        QIMChatToolBarItem *item3 = [QIMChatToolBarItem barItemWithKind:kBarItemMore normal:@"more_ios" high:@"more_ios_HL" select:nil];
        [items addObject:item3];
        
        QIMChatToolBarItem *item4 = [QIMChatToolBarItem barItemWithKind:kBarItemSwitchBar normal:@"Mode_texttolist" high:@"Mode_texttolistHL" select:nil];
        [items addObject:item4];
        [self.chatToolBar loadBarItems:items];
        
        __weak __typeof(self) weakself = self;
        self.robotActionToolBar.switchAction = ^(){
            
            [UIView animateWithDuration:0.25 animations:^{
                weakself.robotActionToolBar.frame = CGRectMake(0, CGRectGetMaxY(weakself.frame), CGRectGetWidth(weakself.frame), kQIMChatToolBarHeight);
                CGFloat y = weakself.frame.origin.y;
                y = [weakself getSuperViewH] - weakself.chatToolBar.frame.size.height;
                weakself.frame = CGRectMake(0, y, weakself.frame.size.width, weakself.frame.size.height);
            }];
        };
        
        self.lastChatKeyboardY = frame.origin.y;
    }
    return self;
}

- (void)resgisterNSNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [self addObserver:self forKeyPath:@"self.chatToolBar.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    [self addObserver:self forKeyPath:@"self.maskView.frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(atSomeOneNotifacationHandle:) name:@"ATSomeOneNotifacation" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emotionListUpdate:) name:kEmotionListUpdateNotification object:nil];
}

- (void)updateEmotionPackageIdList:(NSNotification *)notify {
    
    [self initEmotionViews];
}

- (void)showAction{
    if ([self.delegate respondsToSelector:@selector(showActionBottomView)]) {
        [self.delegate showActionBottomView];
    }
}

- (void)onShowActionBarClick:(UIButton *)sender{
    if (_isFirst) {
        [self needFirstResponder:NO];
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(showAction)
                                                   object:nil];
        [self performSelector:@selector(showAction) withObject:nil afterDelay:0.3];
    } else {
        [self showAction];
    }
}

- (void)emotionListUpdate:(NSNotification *)notify {
    self.faceViewsDic = nil;
    [_emotionSegScrollView removeFromSuperview];
    _emotionSegScrollView = nil;
    _faceView = nil;
    [self initEmotionViews];
    [self emoticonsHandle:[_emotionSegScrollView viewWithTag:kEmotionBtnFrom + 1]];
}

#pragma mark -- kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if (object == self && [keyPath isEqualToString:@"self.chatToolBar.frame"]) {
        
        CGRect newRect = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
        CGRect oldRect = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
        CGFloat changeHeight = newRect.size.height - oldRect.size.height;
        
        self.lastChatKeyboardY = self.frame.origin.y;
        self.frame = CGRectMake(0, self.frame.origin.y - changeHeight, self.frame.size.width, self.frame.size.height + changeHeight);
        self.maskView.frame = CGRectMake(0, self.chatToolBar.bottom, CGRectGetWidth(self.frame), kFacePanelHeight);
        self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
        self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kMorePanelHeight, CGRectGetWidth(self.frame), kMorePanelHeight);
        self.robotActionToolBar.frame = CGRectMake(0, CGRectGetMaxY(self.frame), CGRectGetWidth(self.frame), kQIMChatToolBarHeight);
        
        [self updateAssociateTableViewFrame];
    } else if ([keyPath isEqualToString:@"frame"]) {
        NSLog(@"change : %@", change);
    } else if ([keyPath isEqualToString:@"self.maskView.frame"]) {
        NSLog(@"self.maskView.frame Change : %@", change);
    }
}

#pragma mark -- 跟随键盘的坐标变化
- (void)keyBoardWillChangeFrame:(NSNotification *)notification
{
    // 键盘已经弹起时，表情按钮被选择
    if (![self.chatToolBar.textView isFirstResponder]) {
        return;
    }
    if (self.chatToolBar.faceSelected)
    {
        if (self.faceView == nil) {
            [self initEmotionViews];
        }
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.expandPanel.hidden = YES;
            _quickReplyExpandView.hidden = YES;
            [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
            self.emotionPanel.hidden = NO;
            self.voiceView.hidden = YES;
            self.maskView.hidden = YES;
            self.robotActionToolBar.hidden = YES;
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.maskView.frame = CGRectMake(0, self.chatToolBar.bottom, CGRectGetWidth(self.frame), kFacePanelHeight);
            [self updateAssociateTableViewFrame];
            
        } completion:^(BOOL finished) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
        }];
    }
    // 键盘已经弹起时，more按钮被选择
    else if (self.chatToolBar.moreFuncSelected)
    {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.expandPanel.hidden = NO;
            self.emotionPanel.hidden = YES;
            self.maskView.hidden = YES;
            self.voiceView.hidden = YES;
            _quickReplyExpandView.hidden = YES;
            [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
            self.robotActionToolBar.hidden = YES;
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.maskView.frame = CGRectMake(0, self.chatToolBar.bottom, CGRectGetWidth(self.frame), kFacePanelHeight);
            [self.expandPanel displayItems];
            
            [self updateAssociateTableViewFrame];
        } completion:^(BOOL finisher) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
        }];
    }
    else if (self.chatToolBar.voiceSelected) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            self.voiceView.hidden = NO;
            self.expandPanel.hidden = YES;
            self.maskView.hidden = YES;
            self.emotionPanel.hidden = YES;
            _quickReplyExpandView.hidden = YES;
            [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
            self.robotActionToolBar.hidden = YES;
//            QIMVerboseLog(@"chatToolBar.voiceSelecte)");
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.maskView.frame = CGRectMake(0, self.chatToolBar.bottom, CGRectGetWidth(self.frame), kFacePanelHeight);
            [self updateAssociateTableViewFrame];
        } completion:^(BOOL finisher) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.25 animations:^{
            
            CGRect begin = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
            CGRect end = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
            CGFloat duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
            
            
            CGFloat chatToolBarHeight = CGRectGetHeight(self.frame) - kMorePanelHeight;
            
            CGFloat targetY = end.origin.y - chatToolBarHeight - (SCREEN_HEIGHT - [self getSuperViewH] - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
            
            if((begin.origin.y-end.origin.y>=0))
            {
                // 键盘弹起 (包括，第三方键盘回调三次问题，监听仅执行最后一次)
//                QIMVerboseLog(@" 键盘弹起 (包括，第三方键盘回调三次问题，监听仅执行最后一次)");
                self.voiceView.hidden = NO;
                self.expandPanel.hidden = YES;
                self.maskView.hidden = NO;
                self.emotionPanel.hidden = YES;
                _quickReplyExpandView.hidden = YES;
                [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
                self.robotActionToolBar.hidden = YES;
                self.lastChatKeyboardY = self.frame.origin.y;
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
                self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
                self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
                self.robotActionToolBar.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kQIMChatToolBarHeight);
                self.maskView.frame = CGRectMake(0, self.chatToolBar.bottom, CGRectGetWidth(self.frame), kFacePanelHeight);
                [self updateAssociateTableViewFrame];
                [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
            }
            else if (end.origin.y == SCREEN_HEIGHT && begin.origin.y!=end.origin.y && duration > 0)
            {
                self.lastChatKeyboardY = self.frame.origin.y;
                //键盘收起
                //                QIMVerboseLog(@" 键盘收起");
                if (self.keyBoardStyle == KeyBoardStyleChat)
                {
                    self.frame = CGRectMake(0, targetY - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT], CGRectGetWidth(self.frame), self.frame.size.height);
                    
                }else if (self.keyBoardStyle == KeyBoardStyleComment)
                {
                    if (self.chatToolBar.voiceSelected)
                    {
                        self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                    }
                    else
                    {
                        self.frame = CGRectMake(0, [self getSuperViewH], CGRectGetWidth(self.frame), self.frame.size.height);
                    }
                }
                [self updateAssociateTableViewFrame];
                
            }
            else if ((begin.origin.y-end.origin.y<0) && duration == 0)
            {
//                QIMVerboseLog(@"键盘切换");
                self.lastChatKeyboardY = self.frame.origin.y;
                //键盘切换
                self.frame = CGRectMake(0, targetY, CGRectGetWidth(self.frame), self.frame.size.height);
                [self updateAssociateTableViewFrame];
            }
        }];
    }
}

#pragma mark -- setter and getter

- (void)setAssociateTableView:(UITableView *)associateTableView {
    if (_associateTableView != associateTableView) {
        _associateTableView = associateTableView;
    }
}

- (void)setPlaceHolder:(NSString *)placeHolder
{
    _placeHolder = placeHolder;
    
    [self.chatToolBar setTextViewPlaceHolder:placeHolder];
}

- (void)setPlaceHolderColor:(UIColor *)placeHolderColor
{
    _placeHolderColor = placeHolderColor;
    
    [self.chatToolBar setTextViewPlaceHolderColor:placeHolderColor];
}

-(void)setAllowVoice:(BOOL)allowVoice
{
    self.chatToolBar.allowVoice = allowVoice;
}

- (void)setAllowFace:(BOOL)allowFace
{
    self.chatToolBar.allowFace = allowFace;
}

- (void)setAllowMore:(BOOL)allowMore
{
    self.chatToolBar.allowMoreFunc = allowMore;
}

- (void)setAllowSwitchBar:(BOOL)allowSwitchBar
{
    self.chatToolBar.allowSwitchBar = allowSwitchBar;
}

- (void)keyBoardUp {
    if (self.keyBoardStyle == KeyBoardStyleChat) {
        [self.chatToolBar prepareForBeginComment];
        [self.chatToolBar.textView becomeFirstResponder];
    } else {
        NSException *excp = [NSException exceptionWithName:@"ChatKeyBoardException" reason:@"键盘开启了评论风格请使用- (void)keyboardUpforComment" userInfo:nil];
        [excp raise];
    }
}

- (CGFloat)getSuperViewH
{
    if (self.superview == nil) {
        return 0;
    }
    return self.superview.frame.size.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT];
}

- (void)keyBoardDown {
    if (self.keyBoardStyle == KeyBoardStyleChat) {
        if ([self.chatToolBar.textView isFirstResponder]) {
            
            [self.chatToolBar.textView resignFirstResponder];
        } else {
            
            if(([self getSuperViewH] - CGRectGetMinY(self.frame)) > self.chatToolBar.frame.size.height) {
                [UIView animateWithDuration:0.25 animations:^{
                    
                    self.lastChatKeyboardY = self.frame.origin.y;
                    CGFloat y = self.frame.origin.y;
                    y = [self getSuperViewH] - self.chatToolBar.frame.size.height;
                    self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
                    self.voiceView.hidden = YES;
                    self.expandPanel.hidden = YES;
                    _quickReplyExpandView.hidden = YES;
                    [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
                    self.emotionPanel.hidden = YES;
                    self.robotActionToolBar.hidden = YES;
                    [self updateAssociateTableViewFrame];
                    
                }];
            } else {
                
            }
        }
    } else {
        NSException *excp = [NSException exceptionWithName:@"ChatKeyBoardException" reason:@"键盘开启了评论风格请使用- (void)keyboardDownForComment" userInfo:nil];
        [excp raise];
    }
}

#pragma mark -- QIMChatToolBarDelegate

/**
 *  语音按钮选中，此刻键盘没有弹起
 *  @param change  键盘是否弹起
 */
- (void)chatToolBar:(QIMChatToolBar *)toolBar voiceBtnPressed:(BOOL)select keyBoardState:(BOOL)change
{
//    QIMVerboseLog(@"第n次点击语音");
    if (select && change == NO) {
        self.voiceView.hidden = NO;
        _quickReplyExpandView.hidden = YES;
        [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
        self.emotionPanel.hidden = YES;
        self.expandPanel.hidden = YES;
        self.robotActionToolBar.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            
//            QIMVerboseLog(@"第n次点击语音2");
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kMorePanelHeight, CGRectGetWidth(self.frame), kMorePanelHeight);
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            [self updateAssociateTableViewFrame];
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
        }];
    }
}

/**
 *  表情按钮选中，此刻键盘没有弹起
 *  @param change  键盘是否弹起
 */
- (void)chatToolBar:(QIMChatToolBar *)toolBar faceBtnPressed:(BOOL)select keyBoardState:(BOOL)change
{
    if (select && change == NO)
    {
        self.voiceView.hidden =  YES;
        self.expandPanel.hidden = YES;
        _quickReplyExpandView.hidden = YES;
        [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
        self.robotActionToolBar.hidden = YES;
        self.emotionPanel.hidden = NO;
        if (self.faceView == nil) {
            [self initEmotionViews];
        }
        [UIView animateWithDuration:0.25 animations:^{
            
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kFacePanelHeight, CGRectGetWidth(self.frame), kFacePanelHeight);
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            
            [self updateAssociateTableViewFrame];
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
            
        }];
    }
}

/**
 *  more按钮选中，此刻键盘没有弹起
 *  @param change  键盘是否弹起
 */
- (void)chatToolBar:(QIMChatToolBar *)toolBar moreBtnPressed:(BOOL)select keyBoardState:(BOOL)change
{
    if (select && change == NO)
    {
        self.voiceView.hidden = YES;
        self.expandPanel.hidden = NO;
        self.emotionPanel.hidden = YES;
        _quickReplyExpandView.hidden = YES;
        [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
        self.robotActionToolBar.hidden = YES;
        [UIView animateWithDuration:0.25 animations:^{
            
            self.lastChatKeyboardY = self.frame.origin.y;
            self.frame = CGRectMake(0, [self getSuperViewH]-CGRectGetHeight(self.frame), self.width, CGRectGetHeight(self.frame));
            self.voiceView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            self.expandPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame)-kMorePanelHeight, CGRectGetWidth(self.frame), kMorePanelHeight);
            self.emotionPanel.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), kFacePanelHeight);
            [self.expandPanel displayItems];
            [self updateAssociateTableViewFrame];
            [[NSNotificationCenter defaultCenter] postNotificationName:kQIMTextBarIsFirstResponder object:nil];
        }];
    }
}
- (void)chatToolBarSwitchToolBarBtnPressed:(QIMChatToolBar *)toolBar keyBoardState:(BOOL)change
{
    if (change == NO)
    {
        [UIView animateWithDuration:0.25 animations:^{
            
            self.lastChatKeyboardY = self.frame.origin.y;
            self.voiceView.hidden = YES;
            self.expandPanel.hidden = NO;
            self.emotionPanel.hidden = YES;
            _quickReplyExpandView.hidden = YES;
            [self.expandPanel sendSubviewToBack:_quickReplyExpandView];
            CGFloat y = self.frame.origin.y;
            y = [self getSuperViewH] - kQIMChatToolBarHeight;
            self.frame = CGRectMake(0,[self getSuperViewH], self.frame.size.width, self.frame.size.height);
            [self onShowActionBarClick:nil];
            self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
            
            [self updateAssociateTableViewFrame];
            
        }];
    }
    else
    {
        self.lastChatKeyboardY = self.frame.origin.y;
        
        CGFloat y = [self getSuperViewH] - kQIMChatToolBarHeight;
        self.frame = CGRectMake(0, [self getSuperViewH], self.frame.size.width, self.frame.size.height);
        [self onShowActionBarClick:nil];
        self.frame = CGRectMake(0, y, self.frame.size.width, self.frame.size.height);
        
        [self updateAssociateTableViewFrame];
    }
}

//将要开始编辑
- (void)chatToolBarTextViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(sendTyping)]) {
        
        [self.delegate sendTyping];
    }
}

- (void)chatToolBarSendText:(NSString *)text {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendText:)]) {
        
        [self.delegate sendText:text];
        [self.chatToolBar clearTextViewContent];
        /*
         if (self.replyName&&[_myTextView.text isEqualToString:self.replyName]) {
         [self.delegate emptyText:@"暂无回复内容"];
         }
         else {
         _isScrollToBottom = YES;
         [self.delegate sendText:text];
         }*/
    }
}

- (void)chatToolBarTextViewDidChange:(UITextView *)textView {
    if (textView.text.length > 0) {
        //        QIMVerboseLog(@"键盘彩蛋：打开输入历史Vc");
        //键盘彩蛋：打开输入历史Vc
        //        if ([_myTextView.text hasPrefix:@"#h"] || [_myTextView.text hasSuffix:@"#H"]) {
        //            QIMHistoryMsgListViewController *historyMsgListVc = [[QIMHistoryMsgListViewController alloc] init];
        //            historyMsgListVc.delegate = self;
        //            QIMNavController *nav = [[QIMNavController alloc] initWithRootViewController:historyMsgListVc];
        //            [(UIViewController *)self.delegate presentViewController:nav animated:YES completion:nil];
        //        }
    }
}

- (void)chatToolBarTextView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (text.length == 0) {
        //删除
        if (range.location == 0 && textView.text.length == 0) {
            _placeholderLabel.hidden = NO;
        }
        if (range.location == 0 && range.length == 0) {
            if (self.isRefer && _referDelCount < 1) {
                _referDelCount ++;
                BOOL notDisplay = [[[QIMKit sharedInstance] userObjectForKey:kReferAlertViewNotDisplay] boolValue];
                if (notDisplay == NO) {
                    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"再次删除操作将取消消息引用！" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:@"不再提醒", nil];
                    alertView.tag = kReferAlertViewTag;
                    [alertView show];
                }
            }else{
                _referDelCount = 0;
                if (self.isRefer) {
                    self.isRefer = NO;
                    self.referMsg = nil;
                    [self resetTextStyle];
                }
            }
        }else{
            _referDelCount = 0;
        }
    } else {
        _referDelCount = 0;
        //输入
        if ([text isEqualToString:@"@"] && self.expandViewType == QIMTextBarExpandViewTypeGroup) {
            //@ 弹出联系人
            QIMGroupATNotifyVC * qNoticeVC = [[QIMGroupATNotifyVC alloc] init];
            [qNoticeVC setGroupID:self.chatId];
            __weak __typeof(&*self) weakSelf = self;
            [qNoticeVC selectMember:^(NSDictionary *memberInfoDic) {
                if (memberInfoDic.count > 0) {
                    NSString *name = [memberInfoDic objectForKey:@"name"];
                    NSString *jid = [memberInfoDic objectForKey:@"jid"];
                    NSString *memberName = [NSString stringWithFormat:@"@%@ ", name];
                    if ([[QIMKit sharedInstance] getIsIpad]) {
                        memberName = [NSString stringWithFormat:@"%@ ", name];
                    }

                    QIMATGroupMemberTextAttachment *atTextAttachment = [[QIMATGroupMemberTextAttachment alloc] init];
                    atTextAttachment.groupMemberName = name;
                    atTextAttachment.groupMemberJid = jid;
                    
                    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc] init];
                    NSAttributedString *textAtt2 = [NSAttributedString attributedStringWithAttachment:atTextAttachment];
                    [textAtt appendAttributedString:textAtt2];
                    [textAtt appendAttributedString:[[NSAttributedString alloc] initWithString:memberName]];
                    
                    [self.chatToolBar.textView.textStorage insertAttributedString:textAtt atIndex:self.chatToolBar.textView.selectedRange.location];
                    weakSelf.chatToolBar.textView.selectedRange = NSMakeRange(weakSelf.chatToolBar.textView.selectedRange.location + _myTextView.selectedRange.length + memberName.length + 1, 0);
                    [weakSelf resetTextStyle];
                } else {
                    QIMVerboseLog(@"未选择要艾特的群成员");
                    [self.chatToolBar.textView.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:text] atIndex:self.chatToolBar.textView.selectedRange.location];
                    weakSelf.chatToolBar.textView.selectedRange = NSMakeRange(weakSelf.chatToolBar.textView.selectedRange.location + _myTextView.selectedRange.length + 1, 0);
                    [weakSelf resetTextStyle];
                }
            }];            
            if ([[QIMKit sharedInstance] getIsIpad]) {
                Class RunC = NSClassFromString(@"QIMIPadWindowManager");
                SEL sel = NSSelectorFromString(@"detaiPushViewController:");
                if ([RunC respondsToSelector:sel]) {
                    [RunC performSelector:sel withObject:qNoticeVC];
                }
            } else {
                QIMNavController *qtalNav = [[QIMNavController alloc] initWithRootViewController:qNoticeVC];
                [(UIViewController *)weakSelf.delegate presentViewController:qtalNav animated:YES completion:nil];
            }
        }
    }
}

- (void)chatToolBarTextViewDeleteBackward:(QTalkTextView *)textView {
    NSRange range = textView.selectedRange;
    NSString *handleText;
    NSString *appendText;
    if (range.location == textView.text.length) {
        handleText = textView.text;
        appendText = @"";
    }else {
        handleText = [textView.text substringToIndex:range.location];
        appendText = [textView.text substringFromIndex:range.location];
    }
    
    if (handleText.length > 0) {
        
        //        [self deleteBackward:handleText appendText:appendText];
    }
}

/**
 *  调整关联的表的高度
 */
- (void)updateAssociateTableViewFrame
{
    //表的原来的偏移量
    CGFloat original =  _associateTableView.contentOffset.y;
    
    //键盘的y坐标的偏移量
    CGFloat keyboardOffset = self.frame.origin.y - self.lastChatKeyboardY;
    
    //更新表的frame
    _associateTableView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.origin.y);
    
    //表的超出frame的内容高度
    CGFloat tableViewContentDiffer = _associateTableView.contentSize.height - _associateTableView.frame.size.height;
    
    
    //是否键盘的偏移量，超过了表的整个tableViewContentDiffer尺寸
    CGFloat offset = 0;
    if (fabs(tableViewContentDiffer) > fabs(keyboardOffset)) {
        offset = original-keyboardOffset;
    }else {
        offset = tableViewContentDiffer;
    }
    
    if (_associateTableView.contentSize.height +_associateTableView.contentInset.top+_associateTableView.contentInset.bottom> _associateTableView.frame.size.height) {
        _associateTableView.contentOffset = CGPointMake(0, offset);
    }
}

- (void)initEmotionViews {

    NSInteger i = 1;
    NSString *currentPKId = [[QIMEmotionManager sharedInstance] currentPackageId];
    if (_emotionSegScrollView == nil) {
        
        [self.emotionPanel addSubview:self.addEmotionsBtn];
        
        [self.emotionPanel addSubview:self.emotionSegScrollView];
    }
    
    for (NSString *packageId in [[QIMEmotionManager sharedInstance] getEmotionPackageIdList]) {
        
        if ([packageId isEqualToString:kEmotionCollectionPKId]) {
            
            continue;
        }
        
        NSInteger index = [[[QIMEmotionManager sharedInstance] getEmotionPackageIdList] indexOfObject:packageId];
        QIMEmotionManagerView *faceView = [self.faceViewsDic objectForKey:packageId];
        faceView.delegate = self;
        if (faceView == nil) {
            [[QIMEmotionManager sharedInstance] setCurrentPackageId:packageId];
            faceView = [[QIMEmotionManagerView alloc] initWithFrame:CGRectMake(0, 0, self.width, 220 - 38.5) WithPkId:packageId];
            faceView.delegate = self;
            [faceView setHidden:![packageId isEqualToString:currentPKId]];
        } else {
            [faceView removeFromSuperview];
        }
        if (_faceView) {
            [self.emotionPanel insertSubview:faceView belowSubview:_faceView];
        } else{
            _faceView = faceView;
            [self.emotionPanel addSubview:_faceView];
        }
        [self.faceViewsDic setObject:faceView forKey:packageId];
        
        NSString *imageStr = [[QIMEmotionManager sharedInstance] getEmotionPackageCoverImagePathForPackageId:packageId];
        UIImage * btnImage = [[QIMEmotionManager sharedInstance] getEmotionThumbIconWithImageStr:imageStr BySize:CGSizeMake(24, 24)];
        UIButton * defalutEmoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        float btnWidth = 38.5;
        defalutEmoBtn.frame = CGRectMake(btnWidth * i++, 0, btnWidth, btnWidth);
        defalutEmoBtn.tag = kEmotionBtnFrom + index;
        defalutEmoBtn.selected = [currentPKId isEqualToString:packageId];
        [defalutEmoBtn setImage:btnImage forState:UIControlStateNormal];
        [defalutEmoBtn setBackgroundImage:_image forState:UIControlStateSelected];
        [defalutEmoBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [defalutEmoBtn addTarget:self action:@selector(emoticonsHandle:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.emotionSegScrollView addSubview:defalutEmoBtn];
    }
    {
        QIMEmotionManagerView *collectionViewBg = [self.faceViewsDic objectForKey:kEmotionCollectionPKId];
        
        if (collectionViewBg == nil) {
            collectionViewBg = [[QIMEmotionManagerView alloc] initWithFrame:CGRectMake(0, 0, self.width, 220 - 38.5) WithPkId:kEmotionCollectionPKId];
            collectionViewBg.hidden = YES;
            [self.faceViewsDic setObject:collectionViewBg forKey:kEmotionCollectionPKId];
        } else {
            [collectionViewBg removeFromSuperview];
        }
        [self.faceViewsDic setObject:collectionViewBg forKey:kEmotionCollectionPKId];
        [self.emotionPanel addSubview:collectionViewBg];
        
        [self.emotionSegScrollView addSubview:self.collectEmotionBtn];
    }
    [[QIMEmotionManager sharedInstance] setCurrentPackageId:currentPKId];
    [self.emotionPanel addSubview:self.sendButton];
}

#pragma mark - setter and getter

- (NSMutableDictionary *)faceViewsDic {
    
    if (!_faceViewsDic) {
        
        _faceViewsDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _faceViewsDic;
}

- (QIMChatToolBar *)chatToolBar {
    if (!_chatToolBar) {
        _chatToolBar = [[QIMChatToolBar alloc] initWithFrame:CGRectMake(0, 0, self.width, 49)];
        _chatToolBar.delegate = self;
    }
    return _chatToolBar;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, self.chatToolBar.bottom, self.width, kFacePanelHeight)];
        _maskView.backgroundColor = [UIColor qtalkChatBgColor];
        [self addSubview:_maskView];
    }
    return _maskView;
}

- (UIView *)emotionPanel {
    if (!_emotionPanel) {
        _emotionPanel = [[UIView alloc] initWithFrame:CGRectMake(0, kChatKeyBoardHeight - kFacePanelHeight, self.width, kFacePanelHeight)];
        _emotionPanel.backgroundColor = [UIColor qtalkChatBgColor];
        [self addSubview:_emotionPanel];
    }
    return _emotionPanel;
}

- (QIMTextBarExpandView *)expandPanel {
    if (!_expandPanel) {
        _expandPanel = [[QIMTextBarExpandView alloc] initWithFrame:CGRectMake(0, kChatKeyBoardHeight - kFacePanelHeight, self.width, kFacePanelHeight)];
        _expandPanel.backgroundColor = [UIColor qtalkChatBgColor];
        _expandPanel.delegate = self;
        _expandPanel.type = self.expandViewType;
        _expandPanel.parentVC = (UIViewController *)self.delegate;
        [self addSubview:_expandPanel];
        [_expandPanel addItems];
        [_expandPanel addSubview:self.expandPageControl];
    }
    return _expandPanel;
}

- (QIMOfficialAccountToolbar *)robotActionToolBar {
    if (!_robotActionToolBar) {
        _robotActionToolBar = [[QIMOfficialAccountToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame), self.width, kQIMChatToolBarHeight)];
        [self addSubview:_robotActionToolBar];
    }
    return _robotActionToolBar;
}

//voiceView
- (QIMVoiceChatView *)voiceView {
    
    if (!_voiceView) {
        
        _voiceView = [[QIMVoiceChatView alloc] initWithFrame:CGRectMake(0, kChatKeyBoardHeight - kFacePanelHeight, self.width, kFacePanelHeight)];
        _voiceView.hidden = YES;
        _voiceView.delegate = self;
        _voiceView.backgroundColor = [UIColor qtalkChatBgColor];
        [self addSubview:_voiceView];
    }
    return _voiceView;
}

- (QIMQuickReplyExpandView *)quickReplyExpandView {
    if (!_quickReplyExpandView) {
        _quickReplyExpandView = [[QIMQuickReplyExpandView alloc] initWithFrame:CGRectMake(0, 0, self.expandPanel.width, self.expandPanel.height)];
        _quickReplyExpandView.hidden = YES;
        [self.expandPanel addSubview:_quickReplyExpandView];
    }
    return _quickReplyExpandView;
}

//referButton
- (UIButton *)referButton {
    
    if (!_referButton) {
        
        _referButton = [[UIButton alloc] initWithFrame:CGRectMake(3, 0, 30, 30)];
        [_referButton setImage:[UIImage imageNamed:@"chat_bottom_refer"] forState:UIControlStateNormal];
        [_referButton setImage:[UIImage imageNamed:@"chat_bottom_refer"] forState:UIControlStateSelected];
        [_referButton addTarget:self action:@selector(referBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _referButton;
}

- (UIScrollView *)emotionSegScrollView {
    
    NSInteger emotionsNum = [[QIMEmotionManager sharedInstance] getEmotionPackageIdList].count + 1;
    if (!_emotionSegScrollView) {
        
        _emotionSegScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(38.5, self.expandPanel.height - 38.5, self.width - 100, 38.5)];
        _emotionSegScrollView.contentSize = CGSizeMake(38.5 * emotionsNum, 38.5);
        _emotionSegScrollView.showsHorizontalScrollIndicator = NO;
        _emotionSegScrollView.backgroundColor = [UIColor whiteColor];
        //这一句话很重要，影响chatvc能不能点击状态栏滚到顶部
        _emotionSegScrollView.scrollsToTop = NO;
    }
    return _emotionSegScrollView;
}

/**
 添加表情包按钮
 */
- (UIButton *)addEmotionsBtn {
    
    if (!_addEmotionsBtn) {
        
        CGFloat btnWidth = 38.5;
        _addEmotionsBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.expandPanel.height - 38.5, btnWidth, 36 + 2.5)];
        [_addEmotionsBtn setImage:[UIImage imageNamed:@"Card_AddIcon"] forState:UIControlStateNormal];
        [_addEmotionsBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_addEmotionsBtn addTarget:self action:@selector(addEmotionBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addEmotionsBtn;
}

/**
 自定义表情
 */
- (UIButton *)collectEmotionBtn {
    
    NSString * currentPKId = [[QIMEmotionManager sharedInstance] currentPackageId];
    UIImage * colBtnImage = [UIImage imageNamed:@"braceletLiked"];
    
    if (!_collectEmotionBtn) {
        
        _collectEmotionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_collectEmotionBtn setAccessibilityIdentifier:@"collectionFaceBtn"];
        _collectEmotionBtn.frame = CGRectMake(0, 0, 38.5, 38.5);
        _collectEmotionBtn.tag = kEmotionBtnFrom + 0;
        [_collectEmotionBtn setImage:colBtnImage forState:UIControlStateNormal];
        [_collectEmotionBtn setBackgroundImage:_image forState:UIControlStateSelected];
        [_collectEmotionBtn setBackgroundImage:normalImage forState:UIControlStateNormal];
        [_collectEmotionBtn addTarget:self action:@selector(emoticonsHandle:) forControlEvents:UIControlEventTouchUpInside];
    }
    _collectEmotionBtn.selected = [currentPKId isEqualToString:kEmotionCollectionPKId];
    
    return _collectEmotionBtn;
}

//表情发送按钮
- (UIButton *)sendButton {
    
    _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.width - 100, self.expandPanel.height - 38.5, 100, 38.5)];
    [_sendButton.titleLabel setFont:[UIFont fontWithName:FONT_NAME size:FONT_SIZE]];
    [_sendBtn setAccessibilityIdentifier:@"SendTheContent"];
    [_sendButton setTitle:[NSBundle qim_localizedStringForKey:@"common_send"] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor spectralColorWhiteColor] forState:UIControlStateNormal];
    [_sendButton setTitleColor:[UIColor spectralColorGrayDarkColor] forState:UIControlStateSelected];
    [_sendButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor spectralColorBlueColor]] forState:UIControlStateNormal];
    [_sendButton setBackgroundImage:[UIImage qim_imageFromColor:[UIColor spectralColorDarkBlueColor]] forState:UIControlStateSelected];
    [_sendButton addTarget:self action:@selector(SendTheContent) forControlEvents:UIControlEventTouchUpInside];
    return _sendButton;
}

- (UIActivityIndicatorView *)activityView {
    
    if (!_activityView) {
        
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activityView.frame = CGRectMake(10, 0, 40, 40);
    }
    return _activityView;
}

- (UILabel *)loadingLabel {
    
    if (!_loadingLabel) {
        
        _loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.activityView.right, 10, 150 - self.activityView.right, 20)];
        _loadingLabel.backgroundColor = [UIColor clearColor];
        _loadingLabel.font = [UIFont boldSystemFontOfSize:16];
        _loadingLabel.textAlignment = NSTextAlignmentLeft;
        _loadingLabel.text = @"正在压缩...";
        _loadingLabel.textColor = [UIColor whiteColor];
    }
    return _loadingLabel;
}

- (UIView *)loadView {
    
    if (!_loadView) {
        
        _loadView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 40)];
        _loadView.backgroundColor = [UIColor qim_colorWithHex:0x0 alpha:0.5];
        _loadView.layer.cornerRadius = 5.0f;
        _loadView.layer.masksToBounds = YES;
    }
    return _loadView;
}

- (UIPageControl *)expandPageControl {
    
    if (!_expandPageControl) {
        
        _expandPageControl = [[UIPageControl alloc] init];
        NSArray * items = [[QIMKit sharedInstance] getMsgTextBarButtonInfoList];
        NSInteger pages = ceilf(items.count / 8.0f);
        CGSize pagesize = [_expandPageControl sizeForNumberOfPages:pages];
        _expandPageControl.size = pagesize;
        _expandPageControl.y = 185;
//        _expandPageControl.centerY = CGRectGetMaxY(self.expandPanel.frame) - 35 - HOME_INDICATOR_HEIGHT;
        _expandPageControl.centerX = self.centerX;
        _expandPageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _expandPageControl.currentPageIndicatorTintColor = [UIColor redColor];
        
        _expandPageControl.numberOfPages = pages;
    }
    _expandPageControl.currentPage   = 0;
    
    return _expandPageControl;
}

- (QIMVoiceOperator *)voiceOperator {
    if (!_voiceOperator) {
        _voiceOperator = [[QIMVoiceOperator alloc] init];
        _voiceOperator.voiceOperatorDelegate = self;
    }
    return _voiceOperator;
}

#pragma mark - Method


/**
 下载表情包
 */
- (void)addEmotionBtnHandle:(id)sender{
    
    QIMEmotionsDownloadViewController * myEmotionsVC = [[QIMEmotionsDownloadViewController alloc] init];
    QIMNavController * nav = [[QIMNavController alloc] initWithRootViewController:myEmotionsVC];
    [(UIViewController *)self.delegate presentViewController:nav animated:YES completion:nil];
}

- (void)emoticonsHandle:(UIButton *)btn {
    [self segmentBtnDidClickedAtIndex:btn.tag - kEmotionBtnFrom];
    //    [_faceView.delegate segmentBtnDidClickedAtIndex:btn.tag - kEmotionBtnFrom];
}

- (void)updateFilrStatus:(BOOL) on {
    if (on) {
        if (!_fireButton) {
            _fireButton = [[UIButton alloc] initWithFrame:CGRectMake(_myTextView.right - 28, _myTextView.top + 2.5, 25, 25)];
            [_fireButton setImage:[UIImage imageNamed:@"iconfont-fire_select"] forState:UIControlStateNormal];
            [self addSubview:_fireButton];
        }
        [self bringSubviewToFront:_fireButton];
        _fireButton.hidden = NO;
    } else {
        _fireButton.hidden = YES;
    }
}

- (void)atSomeOneNotifacationHandle:(NSNotification *)notify {
    NSString *userXmppId = notify.object;
    NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:userXmppId];
    NSString *name = [userInfo objectForKey:@"Name"];
    NSString *jid = userXmppId;
    NSString *memberName = nil;
    NSString *textName = [self.chatToolBar.textView.text substringWithRange:NSMakeRange(self.chatToolBar.textView.selectedRange.location-1, 1)];
    if ([textName isEqualToString:@"@"]) {
        memberName = [NSString stringWithFormat:@"%@ ", name];
    } else {
        memberName = [NSString stringWithFormat:@"@%@ ", name];
    }
    
    QIMATGroupMemberTextAttachment *atTextAttachment = [[QIMATGroupMemberTextAttachment alloc] init];
    atTextAttachment.groupMemberName = name;
    atTextAttachment.groupMemberJid = jid;
    
    NSMutableAttributedString *textAtt = [[NSMutableAttributedString alloc] init];
    NSAttributedString *textAtt2 = [NSAttributedString attributedStringWithAttachment:atTextAttachment];
    [textAtt appendAttributedString:textAtt2];
    [textAtt appendAttributedString:[[NSAttributedString alloc] initWithString:memberName]];
    
    [self.chatToolBar.textView.textStorage insertAttributedString:textAtt atIndex:self.chatToolBar.textView.selectedRange.location];
    self.chatToolBar.textView.selectedRange = NSMakeRange(self.chatToolBar.textView.selectedRange.location + _myTextView.selectedRange.length + memberName.length + 1, 0);
    [self resetTextStyle];
}

#pragma mark - Property
- (void)setIsRefer:(BOOL)isRefer {
    _isRefer = isRefer;
    [self resetTextStyle];
}

- (void)setBackgroundImage:(UIImage *)image{
    [_bgImageView setImage:[image stretchableImageWithLeftCapWidth:23 topCapHeight:15]];
}

- (UIImage *)backgroundImage{
    return _bgImageView.image;
}

- (void)setTextViewBackgroundColor:(UIColor *)textViewBackgroundColor{
    _myTextViewBgImageView.backgroundColor = textViewBackgroundColor;
}

- (UIColor *)textViewBackgroundColor{
    return _myTextViewBgImageView.backgroundColor;
}

- (void)setTextViewBackgroundImage:(UIImage *)textViewBackgroundImage{
    _myTextViewBgImageView.image = textViewBackgroundImage;
}

- (UIImage *)textViewBackgroundImage{
    return _myTextViewBgImageView.image;
}

- (void)dealloc{
    
    [self setReplyName:nil];
#if kHasVoice
    _voiceOperator = nil;
#endif
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self removeObserver:self forKeyPath:@"self.chatToolBar.frame"];
    [_voiceView stopPlayVoice];
    _voiceView.delegate = nil;
    _voiceView = nil;
    _remoteAudioPlayer.delegate = nil;
    _remoteAudioPlayer = nil;
}

- (NSArray *)getAttributedTextItems{
    
    __block NSMutableArray * items = [NSMutableArray arrayWithCapacity:1];
    
    //遍历
    [self.chatToolBar.textView.attributedText enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, self.chatToolBar.textView.attributedText.length)
                                                         options:0
                                                      usingBlock:^(id value, NSRange range, BOOL *stop) {
                                                          //检查类型是否是自定义NSTextAttachment类
                                                          if (value && [value isKindOfClass:[QIMEmojiTextAttachment class]]) {
                                                              [items addObject:[NSString stringWithFormat:@"%@____%@____%@",[(QIMEmojiTextAttachment *)value packageId],[(QIMEmojiTextAttachment *)value shortCut],[(QIMEmojiTextAttachment *)value tipsName]]];
                                                          }else if (value == nil) {
                                                              [items addObject:[NSString stringWithFormat:@"%@",[self.chatToolBar.textView.text substringWithRange:range]]];
                                                          }
                                                      }];
    return items;
}

- (void)setQIMAttributedTextWithItems:(NSArray *)items{
    if (![items isKindOfClass:[NSArray class]] && items) {
        return;
    }
    NSMutableAttributedString * mulAttStr = [[NSMutableAttributedString alloc] init];
    for (NSString * item in items) {
        if ([item isKindOfClass:[NSString class]]) {
            NSArray * itemInfoArr = [item componentsSeparatedByString:@"____"];
            if (itemInfoArr.count == 3) {
                QIMEmojiTextAttachment *emojiTextAttachment = [QIMEmojiTextAttachment new];
                //设置表情图片
                emojiTextAttachment.image = [UIImage imageWithContentsOfFile:[[QIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:itemInfoArr[1] withPackageId:itemInfoArr[0]]];
                emojiTextAttachment.packageId = itemInfoArr[0];
                emojiTextAttachment.shortCut = itemInfoArr[1];
                emojiTextAttachment.tipsName = itemInfoArr[2];
                NSMutableAttributedString *emjoAtr = [[NSMutableAttributedString alloc] init];
                [emjoAtr appendAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]];
                [mulAttStr appendAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]];
            }else{
                [mulAttStr appendAttributedString:[[NSAttributedString alloc] initWithString:item]];
            }
        }
    }
    self.chatToolBar.textView.attributedText = mulAttStr;
    [self resetTextStyle];
}

- (NSRange) selectedRange {
    return [_myTextView selectedRange];
}

- (void)setText:(NSString *)text {
    if (text.length > 0) {
        [self.chatToolBar setTextViewContent:text];
    }
}

- (NSAttributedString *)getTextBarAttributedText {
    return self.chatToolBar.textView.attributedText;
}

- (NSString *)getSendAttributedText{
    NSString *attributedText = [self.chatToolBar.textView.attributedText getPlainString];
    if (attributedText.length > 0) {
        return attributedText;
    }
    return self.chatToolBar.textView.text;
}


- (NSArray *)encodeInputItems{
    NSMutableArray * encodeItems = [NSMutableArray arrayWithCapacity:1];
    for (IMTextBarInputItem * item in self.inputItems) {
        [encodeItems addObject:[NSString stringWithFormat:@"%@____%@____%@",@(item.type),item.dispalyStr,item.emotionPKId]];
    }
    return encodeItems;
}

- (void)decodeInputItems:(NSArray *)items{
    self.inputItems = [NSMutableArray arrayWithCapacity:1];
    for (NSString * itemStr in items) {
        NSArray * itemInfoArr = [itemStr componentsSeparatedByString:@"____"];
        if (itemInfoArr.count == 3) {
            IMTextBarInputItem * item = [[IMTextBarInputItem alloc] init];
            item.type = (IMTextBarInputItemType)[[itemInfoArr firstObject] integerValue];
            item.dispalyStr = itemInfoArr[1];
            item.emotionPKId = itemInfoArr[2];
            [self.inputItems addObject:item];
        }
    }
}

- (void)needFirstResponder:(BOOL)isFirst {
    
    if (isFirst) {
        [self keyBoardUp];
    } else {
        [self keyBoardDown];
    }
}

#if kHasVoice
#pragma mark - 长按录音

- (void)recordBtnHandle:(UIButton * )btn {
    //输入框状态，_recordButton还是会触发，点击输入框附近时
    if (_voiceButton.selected == NO) {
        return;
    }
    _isFirst = !btn.selected;
    if (btn.selected) {
        [UIView animateWithDuration:_keyboardDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.frame = CGRectMake(0, self.rootFrame.size.height-(_voiceButton.selected ? _voiceButton.bottom : _myTextView.bottom) - 10, self.frame.size.width, self.frame.size.height);
                         } completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(setKeyBoardHeight: WithScrollToBottom:)]) {
            [self.delegate setKeyBoardHeight:(_voiceButton.selected ? _voiceButton.frame.size.height : _myTextView.frame.size.height) - 27 WithScrollToBottom:_isScrollToBottom];
        }
    }else{
        [UIView animateWithDuration:_keyboardDuration
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.frame = CGRectMake(0, self.rootFrame.size.height-_myTextView.frame.size.height - (self.removeStateBarHeight?0:20) - 216, self.frame.size.width, self.frame.size.height);
                         } completion:nil];
        
        if ([self.delegate respondsToSelector:@selector(setKeyBoardHeight: WithScrollToBottom:)]) {
            [self.delegate setKeyBoardHeight:216 + _myTextView.frame.size.height - 30 WithScrollToBottom:_isScrollToBottom];
        }
    }
    btn.selected = !btn.selected;
}

#endif
#pragma mark - send action

- (void)referBtnHandle:(UIButton *)sender {
    //引用消息详情
    if ([self.delegate respondsToSelector:@selector(textBarReferBtnDidClicked:)]) {
        [self.delegate textBarReferBtnDidClicked:self];
    }
    [self needFirstResponder:NO];
}

#pragma mark - imagePicker delegate
//获取文件大小
- (CGFloat) getFileSize:(NSString *)path {
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    float filesize = -1.0;
    if ([fileManager fileExistsAtPath:path]) {
        NSDictionary *fileDic = [fileManager attributesOfItemAtPath:path error:nil];
        unsigned long long size = [[fileDic objectForKey:NSFileSize] longLongValue];
        filesize = 1.0*size;
    }
    return filesize;
}

//获取video长度
- (CGFloat) getVideoLength:(NSURL *)URL {
    NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts];
    float second = 0;
    second = urlAsset.duration.value/urlAsset.duration.timescale;
    return second;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kReferAlertViewTag) {
        if (buttonIndex == 1) {
            [[QIMKit sharedInstance] setUserObject:@(YES) forKey:kReferAlertViewNotDisplay];
        }
    }else{
        if ([alertView isKindOfClass:[IMAlertView class]]) {
            IMAlertView *alert = (IMAlertView *)alertView;
            if (buttonIndex == 1) {
                NSString *videoOutPath = alert.videoOutPath;
                NSString *fileSizeStr = alert.fileSizeStr;
                UIImage *thumbImage = alert.thumbImage;
                float videoDuration = alert.videoDuration;
                [self.delegate sendVideoPath:videoOutPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:videoDuration];
                [[alert picker] dismissViewControllerAnimated:YES completion:nil];
            }else if (buttonIndex == 2){
                
                NSString *videoOutPath = alert.videoOutPath;
                NSString *fileSizeStr = alert.fileSizeStr;
                UIImage *thumbImage = alert.thumbImage;
                float videoDuration = alert.videoDuration;
                [self.delegate sendVideoPath:videoOutPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:videoDuration];
                _picker = [alert picker];
                [self saveVideoForPath:_videoPath];
            } else {
                
                [self.activityView stopAnimating];
                [self.loadView removeFromSuperview];
                [alertView dismissWithClickedButtonIndex:0 animated:YES];
            }
        }
    }
}

- (void)saveVideoForPath : (NSString *) path {
    // 保存视频
    UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
}

// 视频保存回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    
    if (!error) {
        
    }else{
        UIAlertView * alertView  = [[UIAlertView alloc] initWithTitle:@"保存失败！" message:@"请到“设置->隐私->照片”中允许访问相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }
    [_picker dismissViewControllerAnimated:YES completion:nil];
    
    QIMVerboseLog(@"%@",videoPath);
    
    QIMVerboseLog(@"%@",error);
}

- (void)imagePickerBrowserDidFinish:(QIMUIImagePickerBrowserVC *)pickerBrowser {
    UIImage* editedImage = pickerBrowser.sourceImage;
    NSData *imageData = UIImageJPEGRepresentation(editedImage, 0.8);
    [self.delegate sendImageData:imageData];
    _isScrollToBottom = YES;
    //    [self needFirstResponder:NO];
    [pickerBrowser dismissViewControllerAnimated:NO completion:nil];
}

- (void)imagePickerBrowserDidCancel:(QIMUIImagePickerBrowserVC *)pickerBrowser {
    [pickerBrowser.navigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        QIMUIImagePickerBrowserVC *vc = [[QIMUIImagePickerBrowserVC alloc] init];
        UIImage* editedImage = [QIMImageUtil fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
        [vc setSourceImage:editedImage];
        [vc setDelegate:self];
        [picker pushViewController:vc animated:YES];
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        _videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        
        //菊花转起来
        [self.activityView startAnimating];
        [self.loadView addSubview:self.activityView];
        [self.loadView addSubview:self.loadingLabel];
        
        self.loadView.center = picker.view.center;
        [picker.view addSubview:self.loadView];
        
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        CGFloat videoLength = [self getVideoLength:sourceURL];
        NSString *resultQuality = AVAssetExportPresetMediumQuality;
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:resultQuality];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在。若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"yyyyMMddHHmmss"];
        NSString *videoResultPath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/video_%@.mp4", [formater stringFromDate:[NSDate date]]];
        exportSession.outputURL = [NSURL fileURLWithPath:videoResultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     QIMVerboseLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoResultPath] options:nil];
                         AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
                         gen.appliesPreferredTrackTransform = YES;
                         CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                         NSError *error = nil;
                         CMTime actualTime;
                         CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                         UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                         CGImageRelease(image);
                         
                         NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:[self getFileSize:videoResultPath]];
                         IMAlertView *alertView = [[IMAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩视频后的大小为%@,确定要发送吗？",fileSizeStr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"直接发送",@"保存相册并发送", nil];
                         [alertView setVideoOutPath:videoResultPath];
                         [alertView setThumbImage:thumb];
                         [alertView setFileSizeStr:fileSizeStr];
                         [alertView setVideoDuration:videoLength];
                         [alertView setPicker:picker];
                         [alertView show];
                     });
                 }
                     break;
                 case AVAssetExportSessionStatusFailed:
                     dispatch_async(dispatch_get_main_queue(), ^{
                         IMAlertView *alertView = [[IMAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩失败{%@}",exportSession.error] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                         [alertView setPicker:picker];
                         [alertView show];
                     });
                     break;
             }
         }];
        
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.delegate sendImageData:nil];
}

- (void)onPhotoButtonClick:(UIButton *)sender{
    [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
        QTPHImagePickerController *picker = [[QTPHImagePickerController alloc] init];
        picker.delegate = self;
        picker.title = @"选取照片";
        picker.customDoneButtonTitle = @"";
        picker.customCancelButtonTitle = @"取消";
        picker.customNavigationBarPrompt = nil;
        
        picker.colsInPortrait = 4;
        picker.colsInLandscape = 5;
        picker.minimumInteritemSpacing = 2.0;
        [[[UIApplication sharedApplication] visibleViewController] presentViewController:picker animated:YES completion:nil];
//        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:nil];
    };
    [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypePhotos];
}

- (void)onCamerButtonClick:(UIButton *)sender {
    [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
        CameraViewController * cameraVC = [[CameraViewController alloc] init];
        cameraVC.delegate = self;
        QIMNavController * nav = [[QIMNavController alloc] initWithRootViewController:cameraVC];
        [(UIViewController *)self.delegate presentViewController:nav animated:YES completion:nil];
    };
    [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypeCamera];
    
#pragma --qam
    /*
     AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
     if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
     {
     //无权限
     UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"请前往“设置-QTalk-相机”,开启访问权限。" preferredStyle:UIAlertControllerStyleAlert];
     UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
     
     }];
     [alertController addAction:cancelAction];
     [(UIViewController *)self.delegate presentViewController:alertController animated:YES completion:nil];
     return;
     }
     
     CameraViewController * cameraVC = [[CameraViewController alloc] init];
     cameraVC.delegate = self;
     QIMNavController * nav = [[QIMNavController alloc] initWithRootViewController:cameraVC];
     [(UIViewController *)self.delegate presentViewController:nav animated:YES completion:nil];
     */
}

//判断内容是否全部为空格  YES 全部为空格
- (BOOL)isEmpty:(NSString *)str {
    
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return YES;
        } else {
            return NO;
        }
    }
}

- (void)sendButtonClick:(UIButton *)sender{
    if (_myTextView.text.length > 0 && ![self isEmpty:_myTextView.text]) {
        [[QIMHistoryMsgManager sharedInstance] saveMsgText:_myTextView.text];
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendText:)]) {
            
            if (self.replyName&&[_myTextView.text isEqualToString:self.replyName]) {
                [self.delegate emptyText:@"暂无回复内容"];
            }
            else {
                _isScrollToBottom = YES;
                [self.delegate sendText:_myTextView.text];
            }
        }
        [_myTextView setText:@""];
        [self resetTextStyle];
        [self textViewDidChange:_myTextView];
        //fix bug:多行发送后 tableView 回不到底部
        if ([_myTextView isFirstResponder]) {
            if ([self.delegate respondsToSelector:@selector(setKeyBoardHeight:WithScrollToBottom:)]) {
                [self.delegate setKeyBoardHeight:_myTextView.frame.size.height - 30 + _keyboardRect.size.height WithScrollToBottom:_isScrollToBottom];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(setKeyBoardHeight: WithScrollToBottom:)]) {
                [self.delegate setKeyBoardHeight:216 + _myTextView.frame.size.height - 30 WithScrollToBottom:_isScrollToBottom];
            }
        }
        //        _isExpand = NO;
        //        [_myTextView resignFirstResponder];
    }
    else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(emptyText:)]) {
            [_myTextView setText:@""];
            [self resetTextStyle];
            [self textViewDidChange:_myTextView];
            [self.delegate emptyText:@"暂无评论内容"];
        }
    }
}

#pragma mark - CameraViewControllerDelegate

-(void)cameraViewCaontroller:(CameraViewController *)cameraVC didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString* mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    //public.image / public.movie
    //判断是静态图像还是视频
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //获取用户编辑之后的图像
        QIMUIImagePickerBrowserVC *vc = [[QIMUIImagePickerBrowserVC alloc] init];
        UIImage* editedImage = [QIMImageUtil fixOrientation:[info objectForKey:UIImagePickerControllerOriginalImage]];
        //        editedImage = [QIMImageUtil fixOrientation:editedImage rotation:UIImageOrientationUp];
        [vc setSourceImage:editedImage];
        [vc setDelegate:self];
        [cameraVC.navigationController pushViewController:vc animated:YES];
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        _videoPath = (NSString *)[[info objectForKey:UIImagePickerControllerMediaURL] path];
        [self.activityView startAnimating];
        [self.loadView addSubview:self.activityView];
        [self.loadView addSubview:self.loadingLabel];
        self.loadView.center = cameraVC.view.center;
        [cameraVC.view addSubview:self.loadView];
        //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"高质量压缩",@"中质量压缩",@"低质量压缩", nil];
        //        [actionSheet showInView:picker.view];
        
        NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
        CGFloat videoLength = [self getVideoLength:sourceURL];
        NSString *resultQuality = AVAssetExportPresetMediumQuality;
        AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceURL options:nil];
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:resultQuality];
        NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
        [formater setDateFormat:@"yyyyMMddHHmmss"];
        NSString *videoResultPath = [[[QIMKit sharedInstance] getDownloadFilePath] stringByAppendingFormat:@"/video_%@.mp4", [formater stringFromDate:[NSDate date]]];
        exportSession.outputURL = [NSURL fileURLWithPath:videoResultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
         {
             switch (exportSession.status) {
                 case AVAssetExportSessionStatusUnknown:
                     QIMVerboseLog(@"AVAssetExportSessionStatusUnknown");
                     break;
                 case AVAssetExportSessionStatusWaiting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusWaiting");
                     break;
                 case AVAssetExportSessionStatusExporting:
                     QIMVerboseLog(@"AVAssetExportSessionStatusExporting");
                     break;
                 case AVAssetExportSessionStatusCompleted:
                 {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         
                         AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL fileURLWithPath:videoResultPath] options:nil];
                         AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:avAsset];
                         gen.appliesPreferredTrackTransform = YES;
                         CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                         NSError *error = nil;
                         CMTime actualTime;
                         CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                         UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                         CGImageRelease(image);
                         
                         NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:[self getFileSize:videoResultPath]];
                         IMAlertView *alertView = [[IMAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩视频后的大小为%@,确定要发送吗？",fileSizeStr] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"直接发送",@"保存相册并发送", nil];
                         [alertView setVideoOutPath:videoResultPath];
                         [alertView setThumbImage:thumb];
                         [alertView setFileSizeStr:fileSizeStr];
                         [alertView setVideoDuration:videoLength];
                         [alertView setPicker:cameraVC];
                         [alertView show];
                     });
                 }
                     break;
                 case AVAssetExportSessionStatusFailed:
                     dispatch_async(dispatch_get_main_queue(), ^{
                         IMAlertView *alertView = [[IMAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"压缩失败{%@}",exportSession.error] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                         [alertView setPicker:cameraVC];
                         [alertView show];
                     });
                     break;
             }
         }];
        
    }
}

-(void)cameraViewCaontrollerDidCancel:(CameraViewController *)cameraVC {
    
}

#pragma mark - QIMTextViewDelegate
//textView高度改变时，按照用户体验的设计，对其他控件进行布局
- (void)textView:(QIMTextView *)textView heightChanged:(NSInteger)height
{
    if (ABS(height) < 16) {
        return;
    }
    self.frame = CGRectMake(0, self.frame.origin.y - height, self.frame.size.width, self.frame.size.height + height);
    
    CGRect textViewBGFrame = _myTextView.frame;
    textViewBGFrame.origin.y -= 2.5;
    textViewBGFrame.size.height = MAX(textViewBGFrame.size.height + 5, 30);
    _myTextViewBgImageView.frame = textViewBGFrame;
    self.voiceButton.frame = CGRectMake(_voiceButton.frame.origin.x, CGRectGetMaxY(textViewBGFrame) - 35, 35, 35);
    self.showActionBtn.frame = CGRectMake(_showActionBtn.frame.origin.x, _showActionBtn.frame.origin.y  + height, _showActionBtn.frame.size.width, _showActionBtn.frame.size.height);
    
    self.expandButton.frame = CGRectMake(self.width - 5 - 35, CGRectGetMaxY(textViewBGFrame) - 35, 35, 35);
    self.emotionButton.frame = CGRectMake(self.width - 5 - (self.hasVoice ? 70 : 35), CGRectGetMaxY(textViewBGFrame) - 35, 35, 35);
    self.expandPanel.frame = CGRectMake(0, self.expandPanel.frame.origin.y + height, self.width, 220);
    
    self.voiceView.frame = CGRectMake(self.voiceView.frame.origin.x, self.voiceView.frame.origin.y + height, self.width, 215);
}

-(void)textView:(QIMTextView *)textView handleResponderAction:(SEL)action{
    if (action == @selector(copy:) || action == @selector(cut:)) {
        [self saveCopyOrCutTextInfoWithRange:_myTextView.selectedRange];
    }else if (action == @selector(paste:)){
        NSDictionary * copyOrCutInfo = [[QIMHistoryMsgManager sharedInstance] getCopyOrCutTextInfo];
        if (copyOrCutInfo) {
            for (IMTextBarInputItem * item in copyOrCutInfo[@"inputItems"]) {
                [self refreshTextInputCacheWithRange:_myTextView.selectedRange text:item.dispalyStr itemType:item.type isDel:NO];
            }
        } else {
            if ([[UIPasteboard generalPasteboard] image]) {
                /*
                UIImage *image = [[UIPasteboard generalPasteboard] image];
                if (image) {
                    if (image.images.count) {
                        UIAlertController *notSupportGifCopyVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"暂不支持Gif动图拷贝发送" preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"ok", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        }];
                        [notSupportGifCopyVc addAction:okAction];
                        [[[UIApplication sharedApplication].keyWindow rootViewController] presentViewController:notSupportGifCopyVc animated:YES completion:nil];
                    } else {
                        QIMCustomAlertView *customAlertView = [[QIMCustomAlertView alloc] init];
                        [customAlertView setContainerView:[self createImagePreViewWithImage:image]];
                        [customAlertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"cancel", nil), NSLocalizedString(@"send", nil), nil]];
                        [customAlertView setDelegate:self];
                        [customAlertView setOnButtonTouchUpInside:^(QIMCustomAlertView *alertView, int buttonIndex) {
                            [alertView close];
                        }];
                        [customAlertView setUseMotionEffects:YES];
                        [customAlertView show];
                        [self resignFirstResponder];
                    }
                }
                */
            } else if ([[UIPasteboard generalPasteboard] string]) {
                [self refreshTextInputCacheWithRange:_myTextView.selectedRange text:[[UIPasteboard generalPasteboard] string] itemType:IMTextBarInputItemTypeText isDel:NO];
                _placeholderLabel.hidden = YES;
            }
        }
    }
}

/*
- (void)customIOS7dialogButtonTouchUpInside: (QIMCustomAlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [alertView close];
    } else {
        UIImage *image = [[UIPasteboard generalPasteboard] image];
        if (image.images.count) {
            if (image.images[0] && ![image.images[0] isKindOfClass:[NSNull class]]) {
                image = image.images[0];
            }
        }
        NSData *imageData = UIImageJPEGRepresentation(image, 1);
        [self.delegate sendImageData:imageData];
        _isScrollToBottom = YES;
        [self needFirstResponder:NO];
    }
}
*/

- (UIView *)createImagePreViewWithImage:(UIImage *)image
{
    UIView *backImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 290, 200)];
    
    YLImageView *imageView = [[YLImageView alloc] initWithFrame:CGRectMake(10, 10, 270, 180)];
    [imageView setImage:image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backImageView addSubview:imageView];
    return backImageView;
}

/**
 发送表情
 
 @param faceStr 表情str
 @param packageId 表情包Id
 @param dele 是否为删除
 */
- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId isDelete:(BOOL)dele
{
    if (dele) {
        if (self.chatToolBar.textView.text.length == 0) {
            self.chatToolBar.textView.text = @"";
            //            [self textViewDidChange:self.chatToolBar.textView];
            return;
        }
        
        NSRange delRange = self.chatToolBar.textView.selectedRange;
        if (delRange.length == 0) {
            delRange = NSMakeRange(delRange.location > 1 ? delRange.location - 1 : self.chatToolBar.textView.text.length - 1, 1);
        }
        [self.chatToolBar.textView.textStorage deleteCharactersInRange:delRange];
        
        //        NSUInteger location = (_currentRange.location == 0) ? 0 : _currentRange.location - 1;
        
        //        [self textView:_myTextView shouldChangeTextInRange:NSMakeRange(location, 1) replacementText:@""];
        return;
    }
    if ([faceStr length] > 0 && _onEmotionSelected ) {
        
        [_placeholderLabel setHidden:YES];
        self.currentPKId = packageId;
        _onEmotionSelected(faceStr);
    }
}

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId {
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendNormalEmotion:WithPackageId:)]) {
        [self.delegate sendNormalEmotion:faceStr WithPackageId:packageId];
    }
}

-(void)segmentBtnDidClickedAtIndex:(NSInteger)index{
    NSString * selectPKId = [[QIMEmotionManager sharedInstance] getEmotionPackageIdList][index];
    if ([selectPKId isEqualToString:kEmotionCollectionPKId]) {
        [[QIMCollectionFaceManager sharedInstance] checkForUploadLocalCollectionFace];
    }
    for (NSString * pkId in self.faceViewsDic.allKeys) {
        [[self.faceViewsDic objectForKey:pkId] setHidden:![pkId isEqualToString:selectPKId]];
        [(UIButton *)[self.emotionPanel viewWithTag:kEmotionBtnFrom + [[[QIMEmotionManager sharedInstance] getEmotionPackageIdList] indexOfObject:pkId]] setSelected:[pkId isEqualToString:selectPKId]];
    }
    [[QIMEmotionManager sharedInstance] setCurrentPackageId:selectPKId];
}

- (int)leftBorderIndexForText:(NSString *)text index:(NSInteger)index
{
    int textIndex = -1;
    if (index >= 0 && text && index < text.length && [text characterAtIndex:index] == '[') {
        return (int)index;
    }else{
        index --;
    }
    for (int i = (int)index; i >= 0 && text && i < text.length; i--) {
        if ([text characterAtIndex:i] == '[') {
            textIndex = i;
            break;
        }
        if ([text characterAtIndex:i] == ']') {
            break;
        }
    }
    return textIndex;
}

- (int)rightBorderIndexForText:(NSString *)text index:(NSInteger)index
{
    int textIndex = -1;
    if (index >= 0 && text && index < text.length && [text characterAtIndex:index] == ']') {
        return (int)index;
    }else{
        index ++;
    }
    for (int i = (int)index; i < text.length && text; i++) {
        if ([text characterAtIndex:i] == ']') {
            textIndex = i;
            break;
        }
        if ([text characterAtIndex:i] == '[') {
            break;
        }
    }
    return textIndex;
}

- (void)resetTextWithDelInRange:(NSRange)range forTextView:(UITextView *)textView
{
    NSMutableString * mulTextStr = [NSMutableString stringWithString:textView.text];
    if (range.location + range.length > mulTextStr.length) {
        return;
    }
    [mulTextStr replaceCharactersInRange:range withString:@""];
    textView.text = mulTextStr;
    textView.selectedRange = NSMakeRange(range.location, 0);
    _currentRange = textView.selectedRange;
}

- (void)delFullFaceTextForTextView:(UITextView *)textView inRange:(NSRange)range
{
    NSMutableString * mulTextStr = [NSMutableString stringWithString:textView.text];
    NSInteger startIndex = range.location;
    NSInteger endIndex = range.location;
    BOOL  flag = (startIndex = [self leftBorderIndexForText:mulTextStr index:startIndex - 1]) > -1;
    [self resetTextWithDelInRange:flag ? NSMakeRange(startIndex, endIndex - startIndex + 1) : NSMakeRange(range.location, 1) forTextView:textView];
    
}

- (void) delTextForTextView:(UITextView *)textView inRange:(NSRange)range
{
    //光标在最前面，删除无效
    if (range.location + range.length == 0) {
        return;
    }
    NSMutableString * mulTextStr = [NSMutableString stringWithString:textView.text];
    NSInteger startIndex = range.location;
    NSInteger endIndex = range.location;
    //    if ([mulTextStr characterAtIndex:startIndex] == ']') {
    //        [self delFullFaceTextForTextView:textView inRange:range];
    //        return;
    //    }
    BOOL  flag = (startIndex = [self leftBorderIndexForText:mulTextStr index:startIndex]) > -1;
    if (flag) {
        flag = (endIndex = [self rightBorderIndexForText:mulTextStr index:endIndex]) > -1;
    }
    [self resetTextWithDelInRange:flag ? NSMakeRange(startIndex, endIndex - startIndex + 1) : NSMakeRange(range.location, 1) forTextView:textView];
    
}

- (void)setCurrentRangeForTextView:(UITextView *)textView
{
    NSInteger index = textView.selectedRange.location + textView.selectedRange.length;
    BOOL  flag = (index = [self leftBorderIndexForText:textView.text index:index]) > -1;
    if (flag) {
        flag = (index = [self rightBorderIndexForText:textView.text index:index]) > -1;
    }
    _currentRange = flag ? NSMakeRange(index + 1, 0) : NSMakeRange(textView.selectedRange.location + textView.selectedRange.length, 0);
    textView.selectedRange = _currentRange;
}

-(void)SendTheContent
{
    [self.delegate sendText:self.chatToolBar.textView.text];
    [self.chatToolBar clearTextViewContent];
}

- (void)saveCopyOrCutTextInfoWithRange:(NSRange)range{
    if (range.length) {
        __block NSRange currentRange = NSMakeRange(0, 0);
        __block NSMutableString * textMulStr = [NSMutableString stringWithCapacity:1];
        __block NSMutableArray  * items = [NSMutableArray arrayWithCapacity:1];
        [self.inputItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            IMTextBarInputItem * item = self.inputItems[idx];
            currentRange.length = item.dispalyStr.length;
            if (range.location >= currentRange.location && range.location <= currentRange.location + currentRange.length)
            {
                if (item.type == IMTextBarInputItemTypeEmotion) {
                    [textMulStr appendString:item.dispalyStr];
                    [items addObject:item];
                }else{
                    NSRange selRange = NSMakeRange(range.location - currentRange.location, MIN(range.location + range.length, currentRange.location + currentRange.length) - range.location);
                    [textMulStr appendString:[item.dispalyStr substringWithRange:selRange]];
                    IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                    newItem.type = IMTextBarInputItemTypeText;
                    newItem.dispalyStr = [item.dispalyStr substringWithRange:selRange];
                    [items addObject:newItem];
                    
                }
                if(range.location + range.length >= currentRange.location && range.location + range.length <= currentRange.location + currentRange.length){
                    *stop = YES;
                    [[QIMHistoryMsgManager sharedInstance] saveCopyOrCutTextInfoWithText:textMulStr inputItems:items];
                }
            }else if(range.location + range.length >= currentRange.location && range.location + range.length <= currentRange.location + currentRange.length){
                if (item.type == IMTextBarInputItemTypeEmotion) {
                    [textMulStr appendString:item.dispalyStr];
                    [items addObject:item];
                }else{
                    NSRange selRange = NSMakeRange(0, range.location + range.length - currentRange.location);
                    [textMulStr appendString:[item.dispalyStr substringWithRange:selRange]];
                    IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                    newItem.type = IMTextBarInputItemTypeText;
                    newItem.dispalyStr = [item.dispalyStr substringWithRange:selRange];
                    [items addObject:newItem];
                    
                }
                [[QIMHistoryMsgManager sharedInstance] saveCopyOrCutTextInfoWithText:textMulStr inputItems:items];
                *stop = YES;
            }else{
                [textMulStr appendString:item.dispalyStr];
                [items addObject:item];
            }
            currentRange.location += currentRange.length;
            currentRange.length = 0;
        }];
    }
}


- (void)delTextForRange:(NSRange)range{
    if (range.length) {
        __block NSRange currentRange = NSMakeRange(0, 0);
        __block NSMutableString * mulText = [NSMutableString stringWithString:_myTextView.text];
        __block NSRange delRange = NSMakeRange(0, 0);
        __block NSRange afterRange = _myTextView.selectedRange;
        [self.inputItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            IMTextBarInputItem * item = self.inputItems[idx];
            currentRange.length = item.dispalyStr.length;
            if (range.location >= currentRange.location && range.location < currentRange.location + currentRange.length)
            {
                if (item.type == IMTextBarInputItemTypeEmotion) {
                    //                    [mulText replaceCharactersInRange:currentRange withString:@""];
                    [self.inputItems removeObjectAtIndex:idx];
                    afterRange = NSMakeRange(currentRange.location, 0);
                    delRange.location = currentRange.location;
                    delRange.length = currentRange.length;
                }else{
                    NSRange selRange = NSMakeRange(range.location - currentRange.location, MIN(range.location + range.length, currentRange.location + currentRange.length) - range.location);
                    //                    [mulText replaceCharactersInRange:selRange withString:@""];
                    IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                    newItem.type = IMTextBarInputItemTypeText;
                    newItem.dispalyStr = [NSString stringWithFormat:@"%@%@",[item.dispalyStr substringToIndex:selRange.location],[item.dispalyStr substringFromIndex:selRange.location + selRange.length]];
                    if (newItem.dispalyStr.length == 0) {
                        [self.inputItems removeObjectAtIndex:idx];
                    }else{
                        [self.inputItems replaceObjectAtIndex:idx withObject:newItem];
                    }
                    afterRange = NSMakeRange(range.location, 0);
                    delRange.location = range.location;
                    delRange.length = selRange.length;
                    //                    currentRange.length = newItem.dispalyStr.length;
                }
                if(range.location + range.length >= currentRange.location && range.location + range.length <= currentRange.location + currentRange.length){
                    [mulText replaceCharactersInRange:delRange withString:@""];
                    _myTextView.text = mulText;
                    //记录光标位置，设置光标位置
                    self.currentRange = afterRange;
                    _myTextView.selectedRange = afterRange;
                    *stop = YES;
                }
            }else if(range.location + range.length >= currentRange.location && range.location + range.length < currentRange.location + currentRange.length){
                if (item.type == IMTextBarInputItemTypeEmotion) {
                    //                    [mulText replaceCharactersInRange:currentRange withString:@""];
                    [self.inputItems removeObjectAtIndex:idx];
                    afterRange = NSMakeRange(currentRange.location, 0);
                    //                    currentRange.length = 0;
                    delRange.length += currentRange.length;
                }else{
                    NSRange selRange = NSMakeRange(0, range.location + range.length - currentRange.location);
                    //                    [mulText replaceCharactersInRange:selRange withString:@""];
                    IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                    newItem.type = IMTextBarInputItemTypeText;
                    newItem.dispalyStr = [NSString stringWithFormat:@"%@%@",[item.dispalyStr substringToIndex:selRange.location],[item.dispalyStr substringFromIndex:selRange.location + selRange.length]];
                    if (newItem.dispalyStr.length == 0) {
                        [self.inputItems removeObjectAtIndex:idx];
                    }else{
                        [self.inputItems replaceObjectAtIndex:idx withObject:newItem];
                    }
                    afterRange = NSMakeRange(currentRange.location, 0);
                    //                    currentRange.length = newItem.dispalyStr.length;
                    delRange.length += selRange.length;
                }
                [mulText replaceCharactersInRange:delRange withString:@""];
                _myTextView.text = mulText;
                //记录光标位置，设置光标位置
                self.currentRange = afterRange;
                _myTextView.selectedRange = afterRange;
                *stop = YES;
            }else if(currentRange.location > range.location && currentRange.location + currentRange.length < range.location + range.length){
                //                [mulText replaceCharactersInRange:currentRange withString:@""];
                [self.inputItems removeObjectAtIndex:idx];
                afterRange = NSMakeRange(currentRange.location, 0);
                delRange.length = currentRange.length;
                //                currentRange.length = 0;
            }
            currentRange.location += currentRange.length;
            currentRange.length = 0;
        }];
    }
}

- (void)refreshTextInputCacheWithRange:(NSRange )range text:(NSString *)text itemType:(IMTextBarInputItemType)type isDel:(BOOL)isDel{
    if (self.inputItems == nil) {
        //懒加载
        self.inputItems = [NSMutableArray arrayWithCapacity:1];
    }
    
    if (range.length) {
        [self delTextForRange:range];
    }
    
    if (isDel) {
        return;
    }
    
    __block NSRange currentRange = NSMakeRange(0, 0);
    
    if (self.inputItems.count == 0) {
        //inputItems 中没有元素，不会遍历，单独处理
        if (isDel) {
            return;
        }else{
            IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
            newItem.type = type;
            newItem.dispalyStr = text;
            if (type == IMTextBarInputItemTypeEmotion) {
                newItem.emotionPKId = self.currentPKId;
            }
            [self.inputItems addObject:newItem];
            _myTextView.text = text;
            return;
        }
    }
    
    
    //遍历inputItems,找到插入/删除位置
    [self.inputItems enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        IMTextBarInputItem * item = self.inputItems[idx];
        currentRange.length = item.dispalyStr.length;
        if (range.location >= currentRange.location && range.location <= currentRange.location + currentRange.length) {
            //该判断原因：如果是add 应该包含右边界；而如果是del location==右边界 时，应该算入下次遍历
            if (!(range.location == currentRange.location + currentRange.length && isDel)) {
                NSRange afterRange = _myTextView.selectedRange;
                NSMutableString * mulText = [NSMutableString stringWithString:_myTextView.text];
                if (isDel) {//删除
                    
                }else{
                    //要添加一个表情
                    if (type == IMTextBarInputItemTypeEmotion) {
                        if (item.type == IMTextBarInputItemTypeEmotion) {
                            [mulText replaceCharactersInRange:NSMakeRange(currentRange.location + currentRange.length, 0) withString:text];
                            IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                            newItem.type = IMTextBarInputItemTypeEmotion;
                            newItem.dispalyStr = text;
                            newItem.emotionPKId = self.currentPKId;
                            [self.inputItems insertObject:newItem atIndex:idx + 1];
                            afterRange = NSMakeRange(currentRange.location + currentRange.length + text.length, 0);
                        }else{
                            [mulText replaceCharactersInRange:range withString:text];
                            
                            IMTextBarInputItem * subPreItem = [[IMTextBarInputItem alloc] init];
                            subPreItem.type = IMTextBarInputItemTypeText;
                            subPreItem.dispalyStr = [item.dispalyStr substringToIndex:range.location - currentRange.location];
                            [self.inputItems replaceObjectAtIndex:idx withObject:subPreItem];
                            
                            IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                            newItem.type = IMTextBarInputItemTypeEmotion;
                            newItem.dispalyStr = text;
                            newItem.emotionPKId = self.currentPKId;
                            [self.inputItems insertObject:newItem atIndex:idx + 1];
                            
                            IMTextBarInputItem * subSufItem = [[IMTextBarInputItem alloc] init];
                            subSufItem.type = IMTextBarInputItemTypeText;
                            subSufItem.dispalyStr = [item.dispalyStr substringFromIndex:range.location - currentRange.location];
                            [self.inputItems insertObject:subSufItem atIndex:idx + 2];
                            afterRange = NSMakeRange(currentRange.location + subPreItem.dispalyStr.length + text.length, 0);
                        }
                        
                    }
                    //添加字符串
                    else if (type == IMTextBarInputItemTypeText){
                        //当前位置在一个表情中，可能需要顺延插入表情后面
                        if (item.type == IMTextBarInputItemTypeEmotion) {
                            BOOL willAddNew = NO;
                            //看看该item后面还有元素没
                            if (idx + 1 < self.inputItems.count) {
                                IMTextBarInputItem * itemNext = self.inputItems[idx + 1];
                                //下一个item是一个表情，需新建字符串类型item
                                if (itemNext.type == IMTextBarInputItemTypeEmotion) {
                                    willAddNew = YES;
                                }
                                //下一个item是字符串，插入该字符串前面
                                else if (itemNext.type == IMTextBarInputItemTypeText){
                                    currentRange.location += currentRange.length;
                                    currentRange.length = itemNext.dispalyStr.length;
                                    itemNext.dispalyStr = [NSString stringWithFormat:@"%@%@",text,itemNext.dispalyStr];
                                    [mulText replaceCharactersInRange:NSMakeRange(currentRange.location, 0) withString:text];
                                    afterRange = NSMakeRange(currentRange.location + text.length, 0);
                                }
                            }
                            //该item后面没有元素了，需新建字符串类型item
                            else{
                                willAddNew = YES;
                            }
                            
                            //新建字符串类型item，插入当前item后面
                            if (willAddNew == YES) {
                                [mulText replaceCharactersInRange:NSMakeRange(currentRange.location + currentRange.length, 0) withString:text];
                                IMTextBarInputItem * newItem = [[IMTextBarInputItem alloc] init];
                                newItem.type = IMTextBarInputItemTypeText;
                                newItem.dispalyStr = text;
                                [self.inputItems insertObject:newItem atIndex:idx + 1];
                                
                                afterRange = NSMakeRange(currentRange.location + currentRange.length + text.length, 0);
                            }
                            
                        }
                        //当前位置在字符串类型item中，直接插入
                        else if (item.type == IMTextBarInputItemTypeText){
                            NSMutableString * descMulStr = [NSMutableString stringWithString:item.dispalyStr];
                            [descMulStr replaceCharactersInRange:NSMakeRange(range.location - currentRange.location, 0) withString:text];
                            item.dispalyStr = descMulStr;
                            [mulText replaceCharactersInRange:NSMakeRange(range.location, 0) withString:text];
                            afterRange = NSMakeRange(range.location + text.length, 0);
                        }
                    }
                }
                _myTextView.text = mulText;
                //记录光标位置，设置光标位置
                self.currentRange = afterRange;
                _myTextView.selectedRange = afterRange;
                
                //                //删除的text可能是选中的某一段，可能包含多个字符串/表情串的全部/部分的组合，不一定都在这一个item中
                //                if (remainLenth > 0 && isDel) {
                //                    //跨模块 递归
                //                    [self refreshTextInputCacheWithRange:NSMakeRange(afterRange.location, remainLenth) text:[mulText substringWithRange:NSMakeRange(afterRange.location, remainLenth)] itemType:type isDel:isDel];
                //                }
                *stop = YES;
            }
        }
        currentRange.location += currentRange.length;
        currentRange.length = 0;
    }];
}


- (void)resetTextStyle {
    //After changing text selection, should reset style.
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.firstLineHeadIndent = self.isRefer ? kTextViewFirstLineHeadIndent : 0;    /**首行缩进宽度*/
    if (self.chatToolBar.textView.textStorage.length <= 0) {
        NSDictionary *attributes = @{
                                     NSFontAttributeName:kTextFont,
                                     NSParagraphStyleAttributeName:paragraphStyle
                                     };
        self.chatToolBar.textView.attributedText = [[NSAttributedString alloc] initWithString:@" " attributes:attributes];
        self.chatToolBar.textView.attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];
        //        [_myTextView.textStorage insertAttributedString:[[NSAttributedString alloc] initWithString:@" " attributes:attributes] atIndex:0];
    }else{
        NSRange wholeRange = NSMakeRange(0, self.chatToolBar.textView.textStorage.length);
        [self.chatToolBar.textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
        [self.chatToolBar.textView.textStorage addAttribute:NSFontAttributeName value:kTextFont range:wholeRange];
        [self.chatToolBar.textView.textStorage removeAttribute:NSParagraphStyleAttributeName range:wholeRange];
        if (self.isRefer) {
            [self.chatToolBar.textView.textStorage addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeRange];
        }
    }
    [self.chatToolBar.textView setFont:kTextFont];
//    self.chatToolBar.chatToolTextViewShow = NO;
    
    if (self.isRefer) {
        [self.chatToolBar.textView addSubview:self.referButton];
    }else{
        [self.referButton removeFromSuperview];
    }
}

- (void)insertEmojiTextWithTipsName:(NSString *)tipsName shortCut:(NSString *)shortCut{
    QIMEmojiTextAttachment *emojiTextAttachment = [QIMEmojiTextAttachment new];
    
    //设置表情图片
    emojiTextAttachment.image = [UIImage imageWithContentsOfFile:[[QIMEmotionManager sharedInstance] getEmotionImagePathForShortCut:shortCut withPackageId:self.currentPKId]];
    emojiTextAttachment.packageId = self.currentPKId;
    emojiTextAttachment.shortCut = shortCut;
    emojiTextAttachment.tipsName = tipsName;
    NSMutableAttributedString *emjoAtr = [[NSMutableAttributedString alloc] init];
    [emjoAtr appendAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment]];
    [emjoAtr setAttributes:@{NSFontAttributeName:self.chatToolBar.textView.font} range:NSMakeRange(0, emjoAtr.length)];
    
    //插入表情
    [self.chatToolBar.textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:emojiTextAttachment] atIndex:self.chatToolBar.textView.selectedRange.location];
    self.chatToolBar.textView.selectedRange = NSMakeRange(MIN(self.chatToolBar.textView.selectedRange.location + 1, self.chatToolBar.textView.text.length - self.chatToolBar.textView.selectedRange.length), self.chatToolBar.textView.selectedRange.length);
    [self resetTextStyle];
}


//是否是系统表情
-(BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop){
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff){
             if (substring.length > 1){
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f){
                     returnValue = YES;
                 }
             }
         }
         else if (substring.length > 1){
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3){
                 returnValue = YES;
             }
         }else{
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff){
                 returnValue = YES;
             }else if (0x2B05 <= hs && hs <= 0x2b07){
                 returnValue = YES;
             }else if (0x2934 <= hs && hs <= 0x2935){
                 returnValue = YES;
             }else if (0x3297 <= hs && hs <= 0x3299){
                 returnValue = YES;
             }else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50){
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}

#pragma mark - method

-(void)setSelectedEmotion:(void (^)(NSString *))onEmotionSelected{
    
    _onEmotionSelected = [onEmotionSelected copy];
}

-(UIButton *)exportExpandButton
{
    if (self.hasExpandKeyboard) {
        return _expandButton;
    }
    return nil;
}

#pragma mark -QIMVoiceOperatorFinishedRecordDelegate & QIMVoiceOperatorUpdateViewDalegate -add by dan.zheng 15/4/24

//声音录制完成以后，在这里面进行声音的录制、保存、压缩和上传。再将文件名、文件大小和获取到的url返回给delagate，由delegate来进行有关于文件的描述信息的提交
- (void)voiceOperatorFinishedRecordWithFilepath:(NSString *)filePath andFilename:(NSString *)fileName andTimeCount:(CGFloat)timeCount
{
    if (fileName && filePath) {
        [self.delegate voiceRecordWillFinishedIsTrue:YES andCancelByUser:NO];
        NSData *amrData = EncodeWAVEToAMR([NSData dataWithContentsOfFile:filePath], 1, 16);
        [QIMPathManage deleteFileAtPath:filePath];
        NSString *amrFilePath = [QIMPathManage getPathToSaveWithSaveData:amrData ToFileName:fileName ofType:@"amr"];
        //将armData文件上传，获取到相应的url
        NSString *httpUrl = [QIMKit updateLoadVoiceFile:amrData WithFilePath:amrFilePath];
        if (_recordingStatus == VoiceChatRecordingStatusAudition) {
            if (!_voiceInfoDic) {
                _voiceInfoDic = [NSMutableDictionary dictionaryWithCapacity:1];
            }
            [_voiceInfoDic setQIMSafeObject:httpUrl forKey:@"httpUrl"];
            [_voiceInfoDic setQIMSafeObject:@(timeCount + 1) forKey:@"timeCount"];
            [_voiceInfoDic setQIMSafeObject:amrData forKey:@"amrData"];
            [_voiceInfoDic setQIMSafeObject:fileName forKey:@"fileName"];
            [_voiceInfoDic setQIMSafeObject:amrFilePath forKey:@"amrFilePath"];
        }else{
            [self.delegate sendVoiceUrl:httpUrl WithDuration:timeCount + 1 WithSmallData:amrData WithFileName:fileName AndFilePath:amrFilePath];
        }
    } else {
        if (timeCount < 1.0) {
            [self.delegate voiceRecordWillFinishedIsTrue:NO andCancelByUser:NO];
        } else {
            [self.delegate voiceRecordWillFinishedIsTrue:NO andCancelByUser:YES];
        }
    }
}

- (void)sendVoice
{
    [self.delegate sendVoiceUrl:[_voiceInfoDic objectForKey:@"httpUrl"] WithDuration:[[_voiceInfoDic objectForKey:@"timeCount"] intValue] WithSmallData:[_voiceInfoDic objectForKey:@"amrData"] WithFileName:[_voiceInfoDic objectForKey:@"fileName"] AndFilePath:[_voiceInfoDic objectForKey:@"amrFilePath"]];
}

- (void)updateVoiceViewHeightWithPower:(float)power
{
    if ([self.delegate respondsToSelector:@selector(updateVoiceViewHeightInVCWithPower:)])
    {
        [self.delegate updateVoiceViewHeightInVCWithPower:power];
    }
}

//- (void)updateViewToAlertUserWithRemainTime:(float)remainTime
//{
//    if ([self.delegate respondsToSelector:@selector(updateViewToAlertUserInVCWithRemainTime:)])
//    {
//        [self.delegate updateViewToAlertUserInVCWithRemainTime:remainTime];
//    }
//}

#pragma mark -UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - QIMTextBarExpandViewDelegate

- (void)didClickExpandItemForTrdextendId:(NSString *)trdextendId {
    
    if ([trdextendId isEqualToString:QIMTextBarExpandViewItem_Photo]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self onPhotoButtonClick:nil];
        }
    } else if ([trdextendId isEqualToString:QIMTextBarExpandViewItem_Camera]) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            [self onCamerButtonClick:nil];
        }
    } else if ([trdextendId isEqualToString:QIMTextBarExpandViewItem_QuickReply]) {
        self.quickReplyExpandView.hidden = NO;
        [self.expandPanel bringSubviewToFront:self.quickReplyExpandView];
    } else {
        
    }
}

- (void)textBarExpandView:(QIMTextBarExpandView *)expandView forItemIndex:(NSInteger)itemIndex
{
    switch (itemIndex) {
        case QIMTextBarExpandViewItemType_Photo:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self onPhotoButtonClick:nil];
            }
        }
            break;
        case QIMTextBarExpandViewItemType_Camer:
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                [self onCamerButtonClick:nil];
            }
        }
            break;
        case QIMTextBarExpandViewItemType_QuickReply:
        {
            self.quickReplyExpandView.hidden = NO;
            [self.expandPanel bringSubviewToFront:self.quickReplyExpandView];
        }
            break;
        default:
            break;
    }
}

- (void)scrollViewDidScrollToIndex:(NSInteger)currentPage {
    
    self.expandPageControl.currentPage = currentPage;
}

#pragma mark - QIMVoiceChatViewDelegate

//录制声音状态
-(void)voiceChatView:(QIMVoiceChatView *)voiceChatView RecordingAtStatus:(VoiceChatRecordingStatus)status
{
    _recordingStatus = status;
    switch (status) {
        case VoiceChatRecordingStatusStart:
        {
            //设置文件名
            self.fileName = [QIMUUIDTools UUID];
            QIMVerboseLog(@"UUID == %@",self.fileName);
            //开始录音
            //            [recorderVC beginRecordByFileName:self.fileName];
            if ([self.delegate respondsToSelector:@selector(beginDoVoiceRecord)]) {
                [self.delegate beginDoVoiceRecord];
            }
            [self.voiceOperator doVoiceRecordByFilename:self.fileName];
        }
            break;
        case VoiceChatRecordingStatusRecording:
        {
            
        }
            break;
        case VoiceChatRecordingStatusEnd:
        {
            [self.voiceOperator finishRecoderWithSave:YES];
        }
            break;
        case VoiceChatRecordingStatusCancel:
        {
            [self.voiceOperator finishRecoderWithSave:NO];
        }
            break;
        case VoiceChatRecordingStatusAudition:
        {
            [self.voiceOperator finishRecoderWithSave:YES];
        }
            break;
        case VoiceChatRecordingStatusSend:
        {
            [self sendVoice];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - QIMRemoteAudioPlayerDelegate

- (void)remoteAudioPlayerDidFinishPlaying:(QIMRemoteAudioPlayer *)player
{
    [self.voiceView stopPlayVoice];
}

-(QIMRemoteAudioPlayer *)playCurrentVoice
{
    // 开始播放
    if (!_remoteAudioPlayer) {
        _remoteAudioPlayer = [[QIMRemoteAudioPlayer alloc] init];
        _remoteAudioPlayer.delegate = self;
    }
    NSString * filePath = [_voiceInfoDic objectForKey:@"httpUrl"];
    if ([filePath qim_hasPrefixHttpHeader]) {
        
        [_remoteAudioPlayer prepareForURL:filePath playAfterReady:YES];
        
    } else {
        
        [_remoteAudioPlayer prepareForFilePath:filePath playAfterReady:YES];
        [_remoteAudioPlayer prepareForFileName:[_voiceInfoDic objectForKey:@"fileName"] andVoiceUrl:[_voiceInfoDic objectForKey:@"httpUrl"] playAfterReady:YES];
        
    }
    return _remoteAudioPlayer;
}

-(void)stopCurrentVoice
{
    [_remoteAudioPlayer stop];
}

- (NSTimeInterval)getCurrentVoiceTimeout
{
    return [[_voiceInfoDic objectForKey:@"timeCount"] doubleValue];
}

- (void)remoteAudioPlayerReady:(QIMRemoteAudioPlayer *)player{
    
}

- (void)remoteAudioPlayerErrorOccured:(QIMRemoteAudioPlayer *)player withErrorCode:(QIMRemoteAudioPlayerErrorCode)errorCode{
    
}



- (void)remoteAudioPlayerDidStartPlaying:(QIMRemoteAudioPlayer *)player{
    
}

#pragma mark - QTImagePickerControllerDelegate
- (void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingVideo:(NSDictionary *)videoDic{
    
    NSString *videoOutPath = [videoDic objectForKey:@"VideoOutPath"];
    UIImage *thumbImage = [videoDic objectForKey:@"ThumbImage"];
    NSString *fileSizeStr = [videoDic objectForKey:@"FileSizeStr"];
    float videoDuration = [[videoDic objectForKey:@"VideoDuration"] floatValue];
    
    [self.delegate sendVideoPath:videoOutPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:videoDuration];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets ToOriginal:(BOOL)flag
{
    for (ALAsset * asset in assets) {
        NSData * imageData = nil;
        if (flag) {
            uint8_t *buffer = (uint8_t *)malloc(asset.defaultRepresentation.size);
            NSInteger length = [asset.defaultRepresentation getBytes:buffer fromOffset:0 length:asset.defaultRepresentation.size error:nil];
            imageData = [NSData dataWithBytes:buffer length:length];
            UIImage * image = [QIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
            imageData = UIImageJPEGRepresentation(image, 1.0);
        }else{
            UIImage * image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage                                         scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            image = [QIMImageUtil fixOrientation:image];
            imageData = UIImageJPEGRepresentation(image, 0.5);
        }
        [self.delegate sendImageData:imageData];
    }
    _isScrollToBottom = YES;
    [self needFirstResponder:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didFinishPickingImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 0.9);
    [self.delegate sendImageData:imageData];
    _isScrollToBottom = YES;
    [self needFirstResponder:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

-(void)qtImagePickerControllerDidCancel:(QTImagePickerController *)picker
{
    
}

-(void)qtImagePickerController:(QTImagePickerController *)picker didSelectAsset:(ALAsset*)asset
{
    
}


-(void)qtImagePickerController:(QTImagePickerController *)picker didDeselectAsset:(ALAsset*)asset
{
    
}

-(void)qtImagePickerControllerDidMaximum:(QTImagePickerController *)picker
{
    
}

-(void)qtImagePickerControllerDidMinimum:(QTImagePickerController *)picker
{
    
}

#pragma mark - GMImagePickerControllerDelegate
- (void)sendAssetList:(NSMutableArray *)assetList ForPickerController:(QTPHImagePickerController *)picker{
    PHCachingImageManager * imageManager = [[PHCachingImageManager alloc] init];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize targetSize = picker.isOriginal ? PHImageManagerMaximumSize : screenSize;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    
    __block PHAsset *asset = assetList.firstObject;
    [assetList removeObject:asset];
    if (asset) {
        if (asset.mediaType ==  PHAssetMediaTypeImage) {
            if (_tipHUD.hidden) {
                [[self tipHUDWithText:@"正在获取图片..."] show:YES];
            }
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                //gif 图片
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate sendImageData:imageData];
                            _isScrollToBottom = YES;
                            [self closeHUD];
                        });
                    }
                } else {
                    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downloadFinined) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage * imageFix = [QIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
                            if ((imageFix.size.width > 512 || imageFix.size.height > 512) && (!picker.isOriginal)) {
                                CGFloat height = (imageFix.size.height / imageFix.size.width) * 512;
                                imageFix = [imageFix qim_imageByScalingAndCroppingForSize:CGSizeMake(512, height)];
                            }
                            [self.delegate sendImageData:UIImageJPEGRepresentation(imageFix, 0.8)];
                            _isScrollToBottom = YES;
                            [self closeHUD];
                        });
                    }
                }
            }];
            [self sendAssetList:assetList ForPickerController:picker];
        }else if (asset.mediaType == PHAssetMediaTypeVideo){
            int videoDuration = (int)(asset.duration);
            [imageManager requestAVAssetForVideo:asset
                                         options:nil
                                   resultHandler:
             ^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                 NSString * videoResultPath = nil;
                 if (picker.videoPath) {
                     videoResultPath = picker.videoPath;
                 }else{
                     NSString * key = [info objectForKey:@"PHImageFileSandboxExtensionTokenKey"];
                     videoResultPath = [[key componentsSeparatedByString:@";"] lastObject];
                 }
                 NSString *fileSizeStr = [QIMStringTransformTools CapacityTransformStrWithSize:[self getFileSize:videoResultPath]];
                 AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
                 gen.appliesPreferredTrackTransform = YES;
                 CMTime time = CMTimeMakeWithSeconds(0.0, 600);
                 NSError *error = nil;
                 CMTime actualTime;
                 CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
                 UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
                 CGImageRelease(image);
                 NSString *videoOutPath = videoResultPath;
                 UIImage *thumbImage = thumb;
                 //
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self.delegate sendVideoPath:videoOutPath WithThumbImage:thumbImage WithFileSizeStr:fileSizeStr WithVideoDuration:videoDuration];
                 });
             }];
            [self sendAssetList:assetList ForPickerController:picker];
        }
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)assetsPickerController:(QTPHImagePickerController *)picker didFinishPickingAssets:(NSArray *)assetArray
{
    [self sendAssetList:[NSMutableArray arrayWithArray:assetArray] ForPickerController:picker];
}

//Optional implementation:
-(void)assetsPickerControllerDidCancel:(QTPHImagePickerController *)picker{
    ////mahp
}

-(void)assetsPickerController:(QTPHImagePickerController *)picker didFinishEditWithImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
    [self.delegate sendImageData:imageData];
    _isScrollToBottom = YES;
    [self needFirstResponder:NO];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - QIMHistoryMsgListViewControllerDelegate

-(void)QIMHistoryMsgListViewController:(QIMHistoryMsgListViewController *)vc didSelectedText:(NSString *)text{
    _myTextView.text = text;
}

#pragma mark - HUD
- (MBProgressHUD *)tipHUDWithText:(NSString *)text {
    if (!_tipHUD) {
        _tipHUD = [[MBProgressHUD alloc] initWithView:[(UIViewController *)self.delegate view]];
        _tipHUD.minSize = CGSizeMake(120, 120);
        _tipHUD.minShowTime = 1;
        [_tipHUD setLabelText:@""];
        [[(UIViewController *)self.delegate view] addSubview:_tipHUD];
    }
    [_tipHUD setDetailsLabelText:text];
    return _tipHUD;
}

- (void)closeHUD{
    if (_tipHUD) {
        [_tipHUD hide:YES];
    }
}

@end
