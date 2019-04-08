//
//  QIMSingleChatCell.m
//  Marquette
//
//  Created by ping.xue on 14-2-13.
//
//

#import "QIMSingleChatCell.h"
#import <QuartzCore/QuartzCore.h>
#import "QIMMsgBaloonBaseCell.h"
//#import "NSAttributedString+Attributes.h"
#import "QIMWebView.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"
#import "QIMCollectionFaceManager.h"

#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kCellHeightCap      10
#define kBackViewCap        5
#define kMinTextWidth       30
#define kMinTextHeight      30

@interface QIMSingleChatCell() <QIMMenuImageViewDelegate, UIActionSheetDelegate>
{
    QIMAttributedLabel   * _textLabel;
    UIWebView * _webView;
    UIView    * _propressView;
    UILabel   * _progressLabel;
    UIActivityIndicatorView * _actIndView;//加载菊花
    UIImageView             * _msgSendFailedImageView;
    UITapGestureRecognizer  * _singleGes;
}

@property (nonatomic, strong) QIMTextContainer *textContainer;

@end

@implementation QIMSingleChatCell

static double _global_message_cell_width = 0;

#pragma mark - setter and getter

- (void)setMessage:(Message *)message {
    _message = message;
    _textContainer = [QIMMessageParser textContainerForMessage:message];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
//        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor clearColor]];
        
        _backView = [[QIMMenuImageView alloc] initWithFrame:CGRectZero];
        [_backView setDelegate:self];
        [_backView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_backView];
        
        _textLabel = [[QIMAttributedLabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
//        _textLabel.delegate = self;
//        _textLabel.tag = kTextLabelTag;
        [_backView addSubview:_textLabel];
        self.imageIndex = -1;
        
        _propressView = [[UIView alloc] initWithFrame:CGRectMake(_textLabel.left, _textLabel.top, _textLabel.width, _textLabel.height)];
        _propressView.backgroundColor = [UIColor lightGrayColor];
        _propressView.alpha = 0.5;
        _propressView.hidden = YES;
        [_backView addSubview:_propressView];
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _propressView.width, _propressView.height)];
        [_progressLabel setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
        [_progressLabel setBackgroundColor:[UIColor clearColor]];
        [_progressLabel setText:@""];
        [_progressLabel setTextAlignment:NSTextAlignmentCenter];
        [_progressLabel setTextColor:[UIColor whiteColor]];
        [_propressView addSubview:_progressLabel];
        
        _actIndView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _actIndView.hidesWhenStopped = YES;
        [self.contentView addSubview:_actIndView];
        
        _msgSendFailedImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tips_message_failed"]];
        _msgSendFailedImageView.hidden = YES;
        _msgSendFailedImageView.userInteractionEnabled = YES;
        [self.contentView addSubview:_msgSendFailedImageView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationFileManagerUpdate:) name:kNotifyFileManagerUpdate object:nil];
        
        UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
        [self.backView addGestureRecognizer:doubleTapGestureRecognizer];
        
        UITapGestureRecognizer * tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        [_msgSendFailedImageView addGestureRecognizer:tapGes];
        
        //消息发送成功
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDidSendNotificationHandle:) name:kXmppStreamDidSendMessage object:nil];
    }
    return self;
}

- (void)applicationFileManagerUpdate : (NSNotification *)notify
{
    NSDictionary * infoDic = notify.object;
    Message * message = [infoDic objectForKey:@"message"];
    float propress = [[infoDic objectForKey:@"propress"] floatValue];
    NSString * status = [infoDic objectForKey:@"status"];
    if ([message.messageId isEqualToString:self.message.messageId]) {
        message.propress = (int)MAX((1-propress) * 100, 0);
        if (propress <= 1) {
            //update进度条
            _propressView.hidden = NO;
            _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height * (1 - propress));
            [_progressLabel setText:[NSString stringWithFormat:@"%d%%",message.propress]];
        }else{
            if ([status isEqualToString:@"failed"]) {
                //                UILabel * failedLabel = [[UILabel alloc] initWithFrame:_propressView.frame];
                //                failedLabel.textAlignment = NSTextAlignmentCenter;
                //                failedLabel.backgroundColor = [UIColor clearColor];
                //                failedLabel.text = @"发送失败";
                //                [_backView addSubview:failedLabel];
                _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height);
                _propressView.hidden = YES;
            }else{
                _propressView.hidden = YES;
            }
        }
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tap{
    if ([self.delegate respondsToSelector:@selector(browserMessage:)]) {
        [self.delegate browserMessage:self.message];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    } else if (buttonIndex == 1) {
        [[self delegate] processEvent:MA_Delete withMessage:[self message]];
    }
}

- (void)tapHandle:(UITapGestureRecognizer *)tap{
    if (self.message.messageState == MessageState_Faild) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
        //        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"重发",@"删除", nil];
        //        [actionSheet showInView:[(UIViewController *)self.delegate view]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)onMenuActionWithType:(MenuActionType)type{
    switch (type) {
        case MA_Copy:
        {
            NSMutableString *str = [[NSMutableString alloc] initWithCapacity:3];
            for (QIMTextStorage *textStorage in self.textContainer.textStorages) {
                
                if (![textStorage isKindOfClass:[QIMTextStorage class]]) {
                    
                    continue;
                } else {
                    
                    [str appendString:textStorage.text];
                }
            }
            
            [_backView setClipboardWitxthText:str];
        }
            break;
        case MA_Favorite:
        {
            //6.26收藏
            [[self delegate] processEvent:type withMessage:[self message]];

        }
            break;
        case MA_Delete:
        case MA_ToWithdraw:
        case MA_Forward:
        case MA_Refer:
        case MA_Repeater: {
            [[self delegate] processEvent:type withMessage:[self message]];
            
        }
            break;
            //添加为表情
        case MA_Collection: {
            
            
            //
            // 因为咱们有两种格式，所以需要根据情况来判定url
            // 1. http://qt.qunar.com/cgi_bin/get_file.pl?name=md5.jpg
            // 2. http://qt.qunar.com/file/v2/download/temp/md5.jpg
            // 楼下的做法只能处理第二种
            
            for (QIMImageStorage * imageStorage in self.textContainer.textStorages) {
                
                
                if (![imageStorage isKindOfClass:[QIMImageStorage class]]) {
                    
                    return;
                } else {
                    
                    NSURL *imageUrl = imageStorage.imageURL;
                    
                    [[QIMKit sharedInstance] getPermUrlWithTempUrl:[imageUrl absoluteString] PermHttpUrl:^(NSString *httpPermUrl) {
                        [[QIMCollectionFaceManager sharedInstance] insertCollectionEmojiWithEmojiUrl:httpPermUrl];
                    }];
                }
            }
        }
            break;
        default:
            break;
    }
}

- (void)msgDidSendNotificationHandle:(NSNotification *)notify
{
    NSString * msgID = [notify.object objectForKey:@"messageId"];
    //消息发送成功，更新消息状态
    if ([[self.message messageId] isEqualToString:msgID]) {
        if (self.message.messageState < MessageState_Success) {
            self.message.messageState = MessageState_Success;
        }
        [self refreshUI];
    }
    
}

- (CGRect)getCellBackViewFrame{
    CGRect backFrame = [self convertRect:_backView.frame fromView:self.contentView];
    return CGRectMake(self.left + backFrame.origin.x, self.top + backFrame.origin.y, backFrame.size.width, backFrame.size.height);
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
            }
        }else if([storage isMemberOfClass:[QIMLinkTextStorage class]]){
            isSingleImageStorage = NO;
            break;
        }
    }
    [_backView removeGestureRecognizer:_singleGes];
    if (isSingleImageStorage) {
        if (_singleGes == nil) {
            _singleGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTag:)];
        }
        [_backView addGestureRecognizer:_singleGes];
    }
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if (self.editing == editing)
    {
        return;
    }
    [super setEditing:editing animated:animated];
    float moveSpace = 38;
    CGRect rect = _backView.frame;
    if (self.editing) {
        if (self.message.messageDirection == MessageDirection_Sent) {
            rect.origin.x = rect.origin.x - moveSpace;
            _backView.frame = rect;
        }
    }else{
        if (self.message.messageDirection == MessageDirection_Sent) {
            rect.origin.x = rect.origin.x + moveSpace;
            _backView.frame = rect;
        }
    }
}

- (void)refreshUI{
    
    self.selectedBackgroundView.frame = self.contentView.frame;
    
    [self checkForSingleImageStorage];
    //否则，下载完的图片回调时cell已经滚出去了，显示会错乱
    [_textLabel clearOwnerView];
    _textLabel.textContainer = _textContainer;
    _textLabel.delegate = self.delegate;

    [_backView setText:self.message.message];
    _backView.message = self.message;
    
    float backWidth = _textLabel.textContainer.textWidth + 2*kTextLableLeft + 10;
    float backHeight = _textLabel.textContainer.textHeight +  20;
    
    _msgSendFailedImageView.hidden = YES;
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
            CGRect frame = {{kBackViewCap,kCellHeightCap / 2.0},{backWidth,backHeight}};
            [_backView setFrame:frame];
            NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
            if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Copy)];
            }
            if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                
                [menuList addObject:@(MA_Collection)];
            }
            [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete) /*, @(MA_Favorite)*/]];
            
            
            [_backView setMenuActionTypeList:menuList];
//            [_textLabel setTextColor:[UIColor qim_leftBallocFontColor]];
            [_backView setImage:[QIMMsgBaloonBaseCell leftBallocImage]];
            
        }
            break;
        case MessageDirection_Sent:
        {
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth,kBackViewCap},{backWidth,backHeight}};
            [_backView setFrame:frame];
            NSMutableArray *menuList = [NSMutableArray arrayWithCapacity:4];
            if (self.message.messageState == MessageState_Success || self.message.messageState == MessageState_didRead || self.message.messageState == MessageState_none) {
                
                if (self.textContainer.textStorages.count > 0 && [self hasTextWithArray:self.textContainer.textStorages]) {
                    
                    [menuList addObject:@(MA_Copy)];
                }
                if (self.textContainer.textStorages.count > 0 && [self hasNoEmotionOrTestWithArray:self.textContainer.textStorages]) {
                    
                    [menuList addObject:@(MA_Collection)];
                }
                [menuList addObjectsFromArray:@[@(MA_Refer),@(MA_Repeater), @(MA_ToWithdraw), @(MA_Delete) /*, @(MA_Favorite)*/]];
            }
            [_backView setMenuActionTypeList:menuList];

//            [_textLabel setTextColor:[UIColor qim_rightBallocFontColor]];
            [_backView setImage:[QIMMsgBaloonBaseCell rightBallcoImage]];
            //            dispatch_async(dispatch_get_main_queue(), ^{
            if (self.message.messageState == MessageState_Waiting) {
                _actIndView.frame = CGRectMake(_backView.left - 30, _backView.bottom - 35, 30, 30);
                [_actIndView startAnimating];
            }else if(self.message.messageState == MessageState_Faild){
                _msgSendFailedImageView.frame = CGRectMake(_backView.left - 30, _backView.bottom - 35, 30, 30);
                _msgSendFailedImageView.hidden = NO;
            }else{
                [_actIndView stopAnimating];
            }
            //            });
        }
            break;
        default:
            break;
    }
    _propressView.frame = CGRectMake(_textLabel.left, _textLabel.top, _textLabel.textContainer.textWidth, _textLabel.height * (self.message.propress / 100.0f));
    float moveSpace = 38;
    CGRect rect = _backView.frame;
    if (self.editing) {
        if (self.message.messageDirection == MessageDirection_Sent) {
            rect.origin.x = rect.origin.x - moveSpace;
            _backView.frame = rect;
        }
    }
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
