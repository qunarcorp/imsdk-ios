
#define kBurnAfterReadMsgCellHeight    50
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMBurnAfterReadMsgCell.h"
#import "QIMMsgBaloonBaseCell.h"
#import "YLImageView.h"

@interface QIMBurnAfterReadMsgCell()
{
    UILabel         * _titleLabel;
    YLImageView     * _flagView;
}
@end

@implementation QIMBurnAfterReadMsgCell
@synthesize delegate;


+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType
{
    return kBurnAfterReadMsgCellHeight + 20 + (chatType == ChatType_GroupChat ? 20 : 0);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_titleLabel];
        
        _flagView = [[YLImageView alloc] initWithImage:[UIImage imageNamed:@"fire_icon_receive"]];
        [self.contentView addSubview:_flagView];
    }
    return self;
}

- (void)refreshUI
{
    [self.backView setMenuActionTypeList:@[@(MA_Delete)]];
    
    self.backView.message = self.message;
    if (self.message.messageState != MessageState_didDestroyed) {
        _titleLabel.text = @"此消息为阅后即焚消息";
        _flagView.image = [UIImage imageNamed:@"fire_icon_receive"];
    }else{
        _titleLabel.text = @"此消息为阅后即焚消息,已销毁~";
        _flagView.image = [UIImage imageNamed:@"fire_icon_fired"];
    }
    
    float backWidth = 200;
    float backHeight = 50;
    
    
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
            CGRect frame = {{kBackViewCap + self.HeadView.width + 10,kCellHeightCap / 2.0 + self.nameLabel.bottom},{backWidth,backHeight}};
            [self.backView setFrame:frame];
            [self.backView setImage:[QIMMsgBaloonBaseCell leftBallocImage]];
            
            
            _flagView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 23, 34);
            _titleLabel.frame = CGRectMake(_flagView.right + 5, self.backView.top + (self.backView.height - 40) / 2, self.backView.width - _flagView.width - 20, 40);
        }
            break;
        case MessageDirection_Sent:
        {
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
            
            CGRect frame = {{self.frameWidth - kBackViewCap - backWidth,kBackViewCap},{backWidth,backHeight}};
            [self.backView setFrame:frame];
             
            [self.backView setImage:[QIMMsgBaloonBaseCell rightBallcoImage]];
            
            
            _flagView.frame = CGRectMake(self.backView.left + 5, self.backView.top + 5, 23, 34);
            
            _titleLabel.frame = CGRectMake(_flagView.right + 5, self.backView.top + (self.backView.height - 40) / 2, self.backView.width - _flagView.width - 20, 40);
        }
            break;
        default:
            break;
    }
    [super refreshUI];
}

- (void)tapHandle:(UITapGestureRecognizer *)tap
{
    if (self.message.messageState == MessageState_didDestroyed) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(browserMessage:)]) {
        if (self.message.extendInformation) {
            self.message.message = self.message.extendInformation;
        }
        [self.delegate browserMessage:self.message];
    }
}

@end
