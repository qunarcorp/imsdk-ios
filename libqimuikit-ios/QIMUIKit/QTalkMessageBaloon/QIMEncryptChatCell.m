//
//  QIMEncryptChatCell.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/7.
//
//
#define kEncryptChatCellWidth 135
#define kEncryptChatCellHeight 40
#define kTextLabelTop       10
#define kTextLableLeft      10
#define kTextLableBottom    10
#define kTextLabelRight     10
#define kMinTextWidth       30
#define kMinTextHeight      30

#import "QIMMsgBaloonBaseCell.h"
#import "UIImageView+WebCache.h"
#import "QIMEncryptChatCell.h"
#if defined (QIMNoteEnable) && QIMNoteEnable == 1
    #import "QIMEncryptChat.h"
#endif

@interface QIMEncryptChatCell () <QIMMenuImageViewDelegate>
{
    UIImageView     * _imageView;
    UILabel         * _titleLabel;
}

@end

@implementation QIMEncryptChatCell


+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType
{
    return kEncryptChatCellHeight + ((message.messageDirection == MessageDirection_Received) ? 40 : 20);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"explore_tab_password"]];
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

- (void)refreshUI {
    self.backView.message = self.message;
    
    float backWidth = kEncryptChatCellWidth;
    float backHeight = kEncryptChatCellHeight;
    [self setBackViewWithWidth:backWidth WihtHeight:backHeight];
    [super refreshUI];
    switch (self.message.messageDirection) {
        case MessageDirection_Received:
        {
            _titleLabel.textColor = [UIColor blackColor];
            _imageView.frame = CGRectMake(self.backView.left + 16, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, self.backView.top, self.backView.width - 10, self.backView.height);
            _titleLabel.textColor = [UIColor qim_leftBallocFontColor];
        }
            break;
        case MessageDirection_Sent:
        {
            _titleLabel.textColor = [UIColor whiteColor];
            _imageView.frame = CGRectMake(self.backView.left + 10, self.backView.top + 5, 24, 24);
            _titleLabel.frame = CGRectMake(_imageView.right + 5, 5, self.backView.width - 10, self.backView.height);
            _titleLabel.textColor = [UIColor qim_rightBallocFontColor];
        }
            break;
        default:
            break;
    }
#if defined (QIMNoteEnable) && QIMNoteEnable == 1

    QIMEncryptChatState state = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.message.from];
    QIMEncryptChatState state2 = [[QIMEncryptChat sharedInstance] getEncryptChatStateWithUserId:self.message.to];
    if (state == QIMEncryptChatStateDecrypted || state == QIMEncryptChatStateEncrypting || state2 == QIMEncryptChatStateDecrypted || state2 == QIMEncryptChatStateEncrypting) {
        if (self.message.extendInformation.length > 0) {
            _titleLabel.text = self.message.extendInformation;
        } else {
            _titleLabel.text = @"[加密消息]";
        }
    } else {
        _titleLabel.text = @"[加密消息]";
    }
#else
    _titleLabel.text = @"[加密消息]";
#endif
    _imageView.image = [UIImage imageNamed:@"explore_tab_password"];
    _imageView.centerY = self.backView.centerY;
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
