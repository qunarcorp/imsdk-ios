//
//  QIMGroupChatCell.m
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/17.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMGroupChatCell.h"
#import <QuartzCore/QuartzCore.h>

//#import "NSAttributedString+Attributes.h"
#import "QIMMenuImageView.h"

#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"
#import "YLImageView.h"

#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMyCellHeightCap    14
#define kMyBackViewCap      55
#define kMinTextWidth       30
#define kMinTextHeight      30

@interface QIMGroupChatCell()<QIMMenuImageViewDelegate,UIActionSheetDelegate, QIMAttributedLabelDelegate>
{
    QIMAttributedLabel       * _textLabel;
    UIView    * _propressView;
    UILabel   * _progressLabel;
    
    UILabel *_relpyIconLabel;
    UILabel *_dateLabel;
    UITapGestureRecognizer  * _singleGes;
    NSString *_imageMd5;
}

@property (nonatomic, strong) QIMTextContainer *textContainer;
@end

@implementation QIMGroupChatCell
@dynamic delegate;

- (void)setMessage:(Message *)aMessage {
    [super setMessage:aMessage];
    _textContainer = nil;
    if (aMessage) {
        _textContainer = [QIMMessageParser textContainerForMessage:self.message];
    } else {
        _textContainer = nil;
    }
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        UIView *view = [[UIView alloc] initWithFrame:self.contentView.frame];
        view.backgroundColor = [UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor clearColor]];
        _textLabel = [[QIMAttributedLabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        [self.backView addSubview:_textLabel];
        
        _propressView = [[UIView alloc] initWithFrame:CGRectMake(_textLabel.left, _textLabel.top, _textLabel.width, _textLabel.height)];
        _propressView.backgroundColor = [UIColor lightGrayColor];
        _propressView.alpha = 0.5;
        _propressView.hidden = YES;
        [self.backView addSubview:_propressView];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _propressView.width, _propressView.height)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setText:@""];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_propressView addSubview:_progressLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationFileManagerUpdate:) name:kNotifyFileManagerUpdate object:nil];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.backView addGestureRecognizer:doubleTapGestureRecognizer];
        
        //这行很关键，意思是只有当没有检测到doubleTapGestureRecognizer 或者 检测doubleTapGestureRecognizer失败，singleTapGestureRecognizer才有效
        //        [singleTapGestureRecognizer requireGestureRecognizerToFail:doubleTapGestureRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markNameUpdate:) name:kMarkNameUpdate object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeaderImgUpdate:) name:kUserHeaderImgUpdate object:nil];
    }
    return self;
}

- (void)markNameUpdate:(NSNotification *)noti {
    NSDictionary * info = noti.object;
    if ([info[@"nickName"] isEqualToString:self.message.nickName]) {
        [self refreshUI];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(browserMessage:)]) {
        [self.delegate browserMessage:self.message];
    }
}

- (void)userHeaderImgUpdate:(NSNotification *)notify {
    if ([notify.object isEqualToString:self.message.nickName]) {
        [self.HeadView qim_setImageWithJid:self.message.nickName];
    }
}

- (void)applicationFileManagerUpdate:(NSNotification *)notify {
    NSDictionary * infoDic = notify.object;
    Message * message = [infoDic objectForKey:@"message"];
    float propress = [[infoDic objectForKey:@"propress"] floatValue];
    NSString * status = [infoDic objectForKey:@"status"];
    if ([message.messageId isEqualToString:self.message.messageId] || [message.messageId isEqualToString:_imageMd5]) {
        message.propress = (int)MAX((1-propress) * 100, 0);
        if (propress <= 1) {
            //update进度条
            _propressView.hidden = NO;
            _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height * (1 - propress));
            [_progressLabel setText:[NSString stringWithFormat:@"%d%%",message.propress]];
        }else{
            if ([status isEqualToString:@"failed"]) {
                self.message.messageState = MessageState_Faild;
                
                _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height);
                _propressView.hidden = YES;
            }else{
                _propressView.hidden = YES;
            }
        }
    }
}

- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location
{
    return 0;
}

- (void)singleTag:(id)sender {
    if (_textLabel.delegate && [_textLabel.delegate respondsToSelector:@selector(attributedLabel:textStorageClicked:atPoint:)]) {
        for (id storage in _textContainer.textStorages) {
            if ([storage isMemberOfClass:[QIMImageStorage class]]) {
                [_textLabel.delegate attributedLabel:_textLabel textStorageClicked:storage atPoint:CGPointMake(0, 0)];
                break;
            }
        }
    }
}

- (void)checkForSingleImageStorage {
    BOOL isSingleImageStorage = NO;
    for (id storage in _textContainer.textStorages) {
        if ([storage isMemberOfClass:[QIMImageStorage class]]) {
            if (isSingleImageStorage) {
                isSingleImageStorage = NO;
                break;
            }else {
                isSingleImageStorage = YES;
                QIMImageStorage *imageStorage = (QIMImageStorage *)storage;
                _imageMd5 = [[QIMKit sharedInstance] getFileNameFromUrl:[imageStorage.imageURL absoluteString] width:0 height:0];
            }
        }else if([storage isMemberOfClass:[QIMLinkTextStorage class]]){
            isSingleImageStorage = NO;
            break;
        }
    }
    [self.backView removeGestureRecognizer:_singleGes];
    if (isSingleImageStorage) {
        if (_singleGes == nil) {
            _singleGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTag:)];
        }
        [self.backView addGestureRecognizer:_singleGes];
    }
}

- (void)refreshUI {
    self.selectedBackgroundView.frame = self.contentView.frame;
    if (!self.textContainer) {
        self.textContainer = [QIMMessageParser textContainerForMessage:self.message];
    }
    //否则，下载完的图片回调时cell已经滚出去了，显示会错乱
    [_textLabel clearOwnerView];
    _textLabel.textContainer = _textContainer;
    _textLabel.delegate = self.delegate;
    [self checkForSingleImageStorage];
    float backWidth = _textLabel.textContainer.textWidth + 2*kTextLableLeft + 10;
    float backHeight = _textLabel.textContainer.textHeight +  20;
    [self.backView setText:self.message.message];
    self.backView.message = self.message;
    if (self.message.messageType == QIMMessageType_ImageNew) {
        self.backView.image = [UIImage new];
        self.backView.backgroundColor = [UIColor clearColor];
    }
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];

    _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height * (self.message.propress / 100.0f));
}

//判断是否有文字
- (BOOL)hasTextWithArray:(NSArray *)textStroages {
    
    BOOL flag = YES;
    for (id textStorage in textStroages) {
        
        if ([textStorage isKindOfClass:[QIMImageStorage class]]) {
            
            flag = NO;
            continue;
            
        } else {
            
            flag = YES;
            return YES;
            break;
        }
    }
    return flag;
}

- (NSInteger)getImageStroagesCount {
    NSInteger count = 0;
    for (id textStorage in self.textContainer.textStorages) {
        
        if ([textStorage isKindOfClass:[QIMImageStorage class]]) {
            
            count ++;
            
        }
    }
    return count;
}

//判断是否包含非Emotion表情和文字
- (BOOL)hasNoEmotionOrTestWithArray:(NSArray *)textStroages {
    
    BOOL flag = NO;
    NSInteger count = 0;
    for (id textStorage in textStroages) {
        
        if ([textStorage isKindOfClass:[QIMImageStorage class]]) {
            
            QIMImageStorage *imageStorage = textStorage;
            if (imageStorage.storageType == QIMImageStorageTypeEmotion) {
                
                flag = NO;
            } else {
                
                flag = YES;
                count++;
            }
            continue;
            
        }
    }
    if (count==1) {
        return YES;
    } else {
        return NO;
    }
    return flag;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [_textLabel setFrameWithOrign:CGPointMake(kTextLableLeft + (self.message.messageDirection == MessageDirection_Sent ? 0 : 10),10) Width:_textContainer.textWidth];
}

- (NSArray *)showMenuActionTypeList {
    NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Copy)];
            }
            if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Collection)];
            }
            [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        case MessageDirection_Sent: {
            if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Copy)];
            }
            if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Collection)];
            }
            [menuList addObjectsFromArray:@[@(MA_Refer), @(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete), @(MA_Forward)]];
        }
            break;
        default:
            break;
    }
    if (self.chatType == ChatType_System) {
        [menuList removeObject:@(MA_Refer)];
        [menuList removeObject:@(MA_Delete)];
        [menuList removeObject:@(MA_Forward)];
    } else if (self.chatType == ChatType_CollectionChat) {
        [menuList removeAllObjects];
    }
    if ([[[QIMKit sharedInstance] qimNav_getDebugers] containsObject:[QIMKit getLastUserName]]) {
        [menuList addObject:@(MA_CopyOriginMsg)];
    }
    if ([[QIMKit sharedInstance] getIsIpad]) {
        [menuList removeAllObjects];
    }
    return menuList;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
