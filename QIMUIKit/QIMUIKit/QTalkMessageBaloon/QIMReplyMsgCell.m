//
//  ReplayMsgCell.m
//  qunarChatIphone
//
//  Created by chenjie on 15/9/9.
//
//
#import "QIMMsgBaloonBaseCell.h"
#import "QIMReplyMsgCell.h"
#import "QIMGroupChatCell.h"
#import "NSAttributedString+Attributes.h"
#import "QIMGroupNickNameHelper.h"
#import "QIMAttributedLabel.h"
#import "QIMMessageParser.h"
#import "QIMTextContainer.h"

#define kReplyMsgFontSize           13
#define kReplyMsgCap                3

#define kHeadImageWidth         45

@class ReplyMsgView;
@protocol ReplyMsgViewDelegate <NSObject>

- (void)replyMsgView : (ReplyMsgView *)view didClickedUserNickName:(NSString *)userNickName;

@end

@interface ReplyMsgView : UIView <QIMAttributedLabelDelegate>

@property (nonatomic,strong) Message            * message;
@property (nonatomic,copy) NSString             * originalUserNickName;
@property (nonatomic,assign) id<ReplyMsgViewDelegate> delegate;

@property (nonatomic, strong)     QIMAttributedLabel         *nameLabel;
@property (nonatomic, strong)     QIMAttributedLabel         *textLabel;

@property (nonatomic, strong) QIMTextContainer *textContainer;

@end

@implementation ReplyMsgView

- (QIMAttributedLabel *)nameLabel {
    
    if (!_nameLabel) {
        
        _nameLabel = [[QIMAttributedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 0)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.linesSpacing = 2;
        _nameLabel.isWidthToFit = YES;
        _nameLabel.delegate = self;
    }
    return _nameLabel;
}

- (QIMAttributedLabel *)textLabel {
    
    if (!_textLabel) {
        
        _textLabel = [[QIMAttributedLabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.nameLabel.frame), 0, self.width - CGRectGetMaxX(self.nameLabel.frame), 0)];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.linesSpacing = 2;
        _textLabel.isWidthToFit = YES;
    }
    return _textLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self addSubview:self.nameLabel];
        [self addSubview:self.textLabel];
    }
    return self;
}


- (void)refreshUI {
    
    _textContainer = [QIMMessageParser textContainerForMessage:self.message];
    //否则，下载完的图片回调时cell已经滚出去了，显示会错乱
    [_textLabel clearOwnerView];
    _textLabel.textContainer = _textContainer;
    //    _textLabel.delegate = self.delegate;
    
    if (self.message.fromUser) {
        
        [_nameLabel appendLinkWithText:[NSString stringWithFormat:@"%@: ",self.message.fromUser] linkFont:[UIFont boldSystemFontOfSize:kReplyMsgFontSize] linkColor:[UIColor qtalkReplyUserNameColor] underLineStyle:kCTUnderlineStyleNone linkData:self.message.fromUser];
        
        //        [_textLabel appendLinkWithText:self.message.fromUser linkFont:[UIFont boldSystemFontOfSize:kReplyMsgFontSize] linkColor:[UIColor qtalkReplyUserNameColor] underLineStyle:kCTUnderlineStyleNone linkData:self.message.fromUser];
    }
    if (self.message.replyUser && ![self.message.replyUser isEqualToString:self.originalUserNickName] && ![self.message.replyUser isEqualToString:self.message.fromUser]) {
        
        [_nameLabel appendLinkWithText:@"回复" linkFont:[UIFont systemFontOfSize:kReplyMsgFontSize] linkColor:[UIColor qim_colorWithHex:0x666666 alpha:1.0] underLineStyle:kCTUnderlineStyleNone linkData:nil];
        [_nameLabel appendLinkWithText:[NSString stringWithFormat:@"回复%@: ",self.message.replyUser] linkFont:[UIFont boldSystemFontOfSize:kReplyMsgFontSize] linkColor:[UIColor qtalkReplyUserNameColor] underLineStyle:kCTUnderlineStyleNone linkData:self.message.replyUser];
    }

    [_nameLabel setFrameWithOrign:CGPointMake(0, 0) Width:self.width];
    [_nameLabel sizeToFit];
    
    CGFloat nameLabelMaxX = CGRectGetMaxX(_nameLabel.frame);
    [_textLabel setFrameWithOrign:CGPointMake(nameLabelMaxX, 0) Width:self.width - nameLabelMaxX];
    [_textLabel sizeToFit];
    CGRect rect = self.frame;
    CGFloat textLabelMaxX = CGRectGetMaxX(_textLabel.frame);
    self.frame = CGRectMake(rect.origin.x, rect.origin.y, textLabelMaxX + 5, _textLabel.height + 5);
    
}

- (void)backBtnTouchUpHandle:(UIButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReplyMsgDidTapedNotification object:self.message userInfo:@{@"replyMsgId":self.message.replyMsgId,@"replyUser":self.message.fromUser ? self.message.fromUser : self.message.from}];
    });
}

- (void)fromUserBtnTouchUpHandle : (UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyMsgView:didClickedUserNickName:)]) {
        [self.delegate replyMsgView:self didClickedUserNickName:self.message.fromUser];
    }
}

- (void)replyUserBtnTouchUpHandle : (UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyMsgView:didClickedUserNickName:)]) {
        [self.delegate replyMsgView:self didClickedUserNickName:self.message.replyUser];
    }
}

#pragma mark - QIMAttributedLabelDelegate

-(void)attributedLabel:(QIMAttributedLabel *)attributedLabel textStorageClicked:(id<QIMTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    if ([textStorage isMemberOfClass:[QIMLinkTextStorage class]]) {
        NSString * user = [(QIMLinkTextStorage *)textStorage linkData];
        if ([user isEqualToString:self.message.fromUser]) {
            [self fromUserBtnTouchUpHandle:nil];
        }else if ([user isEqualToString:self.message.fromUser]) {
            [self replyUserBtnTouchUpHandle:nil];
        }else {
            [self backBtnTouchUpHandle:nil];
        }
    }
}

@end

@interface QIMReplyMsgCell ()<ReplyMsgViewDelegate>
{
    QIMMsgBaloonBaseCell              * _originalMsgCell;
    
    UIImageView                         * _headImageView;
    UILabel                             * _nickNameLabel;
    QIMAttributedLabel                             * _mainMsgLabel;
    
    NSMutableArray                      * _replyViews;
    UIView                              * _backView;
    UIView                              * _replyBackView;
    UIView                              * _sepLine;
    
    UILabel                             * _timeLabel;
    
    UIButton                            * _replyBtn;
}
@end

@implementation QIMReplyMsgCell


+ (float)getCellHeightForMessage:(Message *)message replyMsgList:(NSArray *)replyMsgList
{
    float cellHeight = 0;
    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
    
    cellHeight += [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth] + 50;
    
    for (Message * replyMsg in replyMsgList) {
        cellHeight += [QIMReplyMsgCell getSizeForMessage:replyMsg fontSize:kReplyMsgFontSize forWidth:[[UIScreen mainScreen] applicationFrame].size.width - 30].height + 10;
    }
    
    cellHeight += 30;
    
    return cellHeight;

}

+ (float )getCellMainMsgHeightForMessage:(Message *)message {
    
    QIMTextContainer *textContaner = [QIMMessageParser textContainerForMessage:message];
    return [textContaner getHeightWithFramesetter:nil width:textContaner.textWidth];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = nil;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _replyBackView = [[UIView alloc] initWithFrame:CGRectZero];
        _replyBackView.backgroundColor = [UIColor qim_colorWithHex:0xf1f1f1 alpha:1];
        [self.contentView addSubview:_replyBackView];
        
        _backView = [[UIView alloc] initWithFrame:CGRectZero];
        _backView.backgroundColor = [UIColor clearColor];
//        _backView.layer.cornerRadius = 3;
        [self.contentView addSubview:_backView];
        
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [_timeLabel setTextColor:[UIColor qtalkTextLightColor]];
        [_backView addSubview:_timeLabel];
        
        _replyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_replyBtn setImage:[UIImage imageNamed:@"AlbumOperateMore"] forState:UIControlStateNormal];
        [_replyBtn setImage:[UIImage imageNamed:@"AlbumOperateMoreHL"] forState:UIControlStateHighlighted];
        [_replyBtn addTarget:self action:@selector(replyBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [_backView addSubview:_replyBtn];
        
        _sepLine = [[UIView alloc] initWithFrame:CGRectZero];
        _sepLine.backgroundColor = [UIColor qtalkSplitLineColor];
        [self.contentView addSubview:_sepLine];
    }
    return self;
}

- (void)setUpOriginalMsgCell
{
    if (_headImageView == nil) {
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kHeadImageWidth, kHeadImageWidth)];;
        _headImageView.contentMode = UIViewContentModeScaleAspectFit;
        _headImageView.clipsToBounds = YES;
        [_backView addSubview:_headImageView];
    }
    [_headImageView qim_setImageWithJid:self.message.nickName];
    if (_nickNameLabel == nil) {
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_headImageView.right + 10, 0, [[UIScreen mainScreen] applicationFrame].size.width - 10 - 10 - 20 - kHeadImageWidth, 20)];
        [_nickNameLabel setTextColor:[UIColor qtalkReplyUserNameColor]];
        [_nickNameLabel setFont:[UIFont boldSystemFontOfSize:FONT_SIZE - 3]];
        [_backView addSubview:_nickNameLabel];
    }
    NSString * nickName = self.message.nickName;
    if (nickName) {
        nickName = [QIMGroupNickNameHelper getGroupMemberNickNameByQnrId:self.message.nickName];
    }
    [_nickNameLabel setText:nickName];
    
    if (_mainMsgLabel == nil) {
        _mainMsgLabel = [[QIMAttributedLabel alloc] init];
        _mainMsgLabel.backgroundColor = [UIColor clearColor];
        _mainMsgLabel.textContainer = [QIMMessageParser textContainerForMessage:self.message];
        _mainMsgLabel.frame = CGRectMake(_nickNameLabel.left, _nickNameLabel.bottom + 5, _nickNameLabel.width, [_mainMsgLabel.textContainer getHeightWithFramesetter:nil width:_nickNameLabel.width]);
        [_backView addSubview:_mainMsgLabel];
    }
    return ;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _backView.frame = CGRectMake(10, 10, self.contentView.width - 10 * 2, self.contentView.height - 20);
    
    _replyBtn.frame = CGRectMake(_replyBackView.right - 7 - 25, _timeLabel.top - (25 - _timeLabel.height) / 2.0, 25, 25);
    _sepLine.frame = CGRectMake(0, self.contentView.height - 1, self.contentView.width, 0.5);
}

- (void)replyBtnHandle:(UIButton *)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kReplyMsgDidTapedNotification object:self.message userInfo:@{@"replyMsgId":self.message.messageId,@"replyUser":self.message.from}];
}



- (void)refreshUI
{
    self.message.messageDirection = MessageDirection_Received;
    
    [_originalMsgCell removeFromSuperview];
    [self setUpOriginalMsgCell];
    long long msgDate = self.message.messageDate; 
    _timeLabel.text = [[NSDate qim_dateWithTimeIntervalInMilliSecondSince1970:msgDate] qim_formattedDateDescription];
    _timeLabel.frame = CGRectMake(_nickNameLabel.left, _mainMsgLabel.bottom + 10, _mainMsgLabel.width - 100, 20);
    
    if (!_replyViews) {
        _replyViews = [NSMutableArray arrayWithCapacity:1];
    }
    
    for (UIView * view in _replyViews) {
        [view removeFromSuperview];
    }
    NSInteger i = 0;
    float heightSum = 0;
    for (Message * replyMsg in self.replyMsgList) {
        
        replyMsg.messageDirection = MessageDirection_Sent;
        ReplyMsgView * replyMsgView = [[ReplyMsgView alloc] initWithFrame:CGRectMake(_nickNameLabel.left + 3, _timeLabel.bottom + 10 + heightSum, _mainMsgLabel.width - 6, 0)];
        replyMsgView.delegate = self;
        replyMsgView.message = replyMsg;
        replyMsgView.originalUserNickName = self.message.from;
        replyMsgView.backgroundColor = [UIColor clearColor];
        [_backView addSubview:replyMsgView];
        [_replyViews addObject:replyMsgView];
        [replyMsgView refreshUI];
        heightSum += replyMsgView.height;
        i++;
    }
    
    _replyBackView.frame = CGRectMake(_nickNameLabel.left + 10, 7 + _timeLabel.bottom + 8, _mainMsgLabel.width, self.replyMsgList.count ? heightSum + 3 : 0);
    _backView.frame = CGRectMake(10, 10, self.contentView.width - 10 * 2, self.contentView.height - 20);
    
    _replyBtn.frame = CGRectMake(_replyBackView.right - 7 - 25, _timeLabel.top - (25 - _timeLabel.height) / 2.0, 25, 25);
    _sepLine.frame = CGRectMake(0, self.contentView.height - 1, self.contentView.width, 0.5);
}

+ (CGSize )getSizeForMessage:(Message *)message fontSize:(float)fontSize forWidth:(float )width
{
    Message *msg = [Message new];
    NSString * prefixStr = @"";
    if (message.fromUser) {
        prefixStr = [prefixStr stringByAppendingString:message.fromUser];
    }
    if (message.replyUser) {
        prefixStr = [prefixStr stringByAppendingString:[NSString stringWithFormat:@"回复%@",message.replyUser]];
    }
    prefixStr = [prefixStr stringByAppendingString:@":"];
    msg.message = [prefixStr stringByAppendingString:[NSString stringWithFormat:@"%@",message.message]];
   if ([msg.message length] > 0) {
       QIMTextContainer * textContainer = [[QIMTextContainer alloc] init];
       textContainer.text = msg.message;
       textContainer.linesSpacing = 2;
       textContainer.isWidthToFit = YES;
       [textContainer setTextColor:[UIColor qim_colorWithHex:0x666666 alpha:1.0]];
       [textContainer setFont:[UIFont systemFontOfSize:fontSize]];
       textContainer = [textContainer createTextContainerWithTextWidth:width];
       return [textContainer getSuggestedSizeWithFramesetter:nil width:width];
   }
    return CGSizeZero;
}

#pragma  mark - ReplyMsgViewDelegate

-(void)replyMsgView:(ReplyMsgView *)view didClickedUserNickName:(NSString *)userNickName
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyMsgCell:didClickedUserNickName:)]) {
        [self.delegate replyMsgCell:self didClickedUserNickName:userNickName];
    }
}

@end
