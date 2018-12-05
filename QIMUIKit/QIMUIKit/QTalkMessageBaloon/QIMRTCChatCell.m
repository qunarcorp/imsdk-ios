//
//  QIMRTCChatCell.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/22.
//
//

#define kRTCCellWidth       170
#define kRTCCellHeight      40
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMMsgBaloonBaseCell.h"
#import "UIImageView+WebCache.h"
#import "QIMRTCChatCell.h"

@interface QIMRTCChatCell () <QIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel         * _titleLabel;
}

@end

@implementation QIMRTCChatCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType
{
    return kRTCCellHeight + ((chatType == ChatType_GroupChat) && (message.messageDirection == MessageDirection_Received) ? 40 : 20);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"QIMRTCChatCell_Call"]];
        _imageView.clipsToBounds = YES;
        _imageView.userInteractionEnabled = NO;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)tapGesHandle:(UITapGestureRecognizer *)tap{
    if (self.message.messageState == MessageState_Faild) {
        if (self.message.extendInformation) {
            self.message.message = self.message.extendInformation;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kXmppStreamReSendMessage object:self.message];
    }
}

- (void)refreshUI
{
    [super refreshUI];
    
    self.backView.message = self.message;
    
    float backWidth = kRTCCellWidth;
    float backHeight = kRTCCellHeight;
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];

    switch (self.message.messageDirection) {
        case MessageDirection_Received: {
            _titleLabel.textColor = [UIColor blackColor];
            _imageView.frame = CGRectMake(self.backView.left + 16, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top, self.backView.width - 40 - 10, self.backView.height);
            _titleLabel.centerY = self.backView.centerY;
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case MessageDirection_Sent: {
            _titleLabel.textColor = [UIColor whiteColor];
            _imageView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, 5, self.backView.width - 40 - 10, self.backView.height);
            _titleLabel.centerY = self.backView.centerY;
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
    if (self.message.messageType == QIMWebRTC_MsgType_Audio) {
        _titleLabel.text = @"发起了语音聊天";
        _imageView.image = [UIImage imageNamed:@"QTalkRTCChatCell_Call"];
    } else if (self.message.messageType == QIMWebRTC_MsgType_Video) {
        _titleLabel.text = @"发起了视频聊天";
        _imageView.image = [UIImage imageNamed:@"QTalkRTCChatCell_Video"];
    } else if (self.message.messageType == QIMMessageTypeWebRtcMsgTypeVideoMeeting) {
        _titleLabel.text = @"发起了视频会议";
        _imageView.image = [UIImage imageNamed:@"QTalkRTCChatCell_Meeting"];
    }
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
