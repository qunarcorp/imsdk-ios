//
//  QIMContactUserCell.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/16.
//
//


#define NAME_LABEL_FONT     (FONT_SIZE - 1)  //名字字体
#define CONTENT_LABEL_FONT  (FONT_SIZE - 4)  //新消息字体,时间字体
#define COLOR_TIME_LABEL [UIColor blueColor] //时间颜色;

#import "QIMContactUserCell.h"

@implementation QIMContactUserCell{
    UIImageView *_headerView;
    UILabel *_nameLabel;
    UIImageView * _prefrenceImageView;
}

+ (CGFloat)getCellHeight{
    return 60;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView* view = [[UIView alloc]initWithFrame:self.contentView.frame];
        view.backgroundColor=[UIColor clearColor];
        self.selectedBackgroundView = view;
        [self setBackgroundColor:[UIColor whiteColor]];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kUserStatusChange object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCell:) name:kGroupHeaderImageUpdate object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOnlineState) name:kNotifyUserOnlineStateUpdate object:nil];
        
        _headerView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        [_headerView setImage:[UIImage imageNamed:@"singleHeaderDefault"]];
        _headerView.layer.masksToBounds = YES;
        _headerView.layer.cornerRadius  = 5;
        [_headerView setClipsToBounds:YES];
        [self.contentView addSubview:_headerView];
        
        _prefrenceImageView = [[UIImageView alloc] initWithFrame:CGRectMake(35, 35, 15, 15)];
        [_prefrenceImageView setHidden:YES];
        _prefrenceImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_prefrenceImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, [UIScreen mainScreen].bounds.size.width - 70, 20)];
        [_nameLabel setFont:[UIFont fontWithName:FONT_NAME size:NAME_LABEL_FONT]];
        [_nameLabel setTextColor:[UIColor qtalkTextBlackColor]];
        [_nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:_nameLabel];
    }
    return self;
}

- (void)updateCell:(NSNotification *)notify{
    NSString *userId = [notify object];
    if ([userId isEqualToString:self.jid]) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self refreshUI];
        });
    }
}

- (void)updateOnlineState{
    if (!self.isGroup) {
        [self refreshUI];
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    
}

- (void)refreshUI{
    
    self.selectedBackgroundView.frame = self.contentView.frame;    
    [_prefrenceImageView setHidden:YES];
    if (self.isGroup) {
        [_headerView qim_setImageWithJid:self.jid WithChatType:ChatType_GroupChat];
        if (!self.name) {
            NSDictionary *groupVcard = [[QIMKit sharedInstance] getGroupCardByGroupId:self.jid];
            if (groupVcard) {
                NSString *groupName = [groupVcard objectForKey:@"Name"];
                self.name = groupName;
            }
        }
        [_nameLabel setText:self.name];
    } else if (self.isSystem) {
        [_headerView qim_setImageWithJid:self.jid WithChatType:ChatType_System];
        [_nameLabel setText:@"系统消息"];
    } else {
         [_headerView qim_setImageWithJid:self.jid WithChatType:ChatType_SingleChat];
        switch ([[QIMKit sharedInstance] getUserPrecenseStatus:_jid]) {
            case UserPrecenseStatus_Away:{
                UIImage *image = [UIImage imageNamed:@"Header+Search_Away_Normal"];
                [_prefrenceImageView setHidden:NO];
                [_prefrenceImageView setImage:image];
            }
                break;
            case UserPrecenseStatus_Dnd:{
                UIImage *image = [UIImage imageNamed:@"Header+Search_Busy_Normal"];
                [_prefrenceImageView setHidden:NO];
                [_prefrenceImageView setImage:image];
            }
                break;
            default:
                [_prefrenceImageView setHidden:YES];
                break;
        }
        NSDictionary *userInfo = [[QIMKit sharedInstance] getUserInfoByUserId:self.jid];
        NSString *userName = [userInfo objectForKey:@"Name"];
        NSString *remarkName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:self.jid];
        NSString *showName = (remarkName.length > 0) ? remarkName : userName;
        if (!showName) {
            showName = self.jid;
        }
        [_nameLabel setText:showName];
    }
}

@end
