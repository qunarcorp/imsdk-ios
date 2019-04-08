//
//  QIMAACollectionCell.m
//  qunarChatIphone
//
//  Created by admin on 16/1/18.
//
//

#define kQIMAACollectionCellWidth   ([UIScreen mainScreen].bounds.size.width * 5 / 7)
#define kScale                   ([UIScreen mainScreen].bounds.size.width / 320)

#define kAACollectionCellWidth      240
#define kAACollectionCellWidthHeight    130
#import "QIMIconInfo.h"
#import "QIMMsgBaloonBaseCell.h"
#import "QIMAACollectionCell.h"
#import "QIMJSONSerializer.h"
#import "UIImageView+WebCache.h"

@interface QIMAACollectionCell (){
    UILabel         * _titleLabel;          //活动标题
    UIView          * _imageView;           //活动图标
    UIView          * _descInfoView;        //活动详情View
    
    UILabel         * _person_numStrLabel;  //参与人数
    UILabel         * _totalMoneyLabel;   //总金钱数
    
    UILabel         * _lineView;
    UILabel         * _activityTypeLabel;   //线上活动|线下活动
}

@end

@implementation QIMAACollectionCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    return kAACollectionCellWidthHeight;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.backView setMenuActionTypeList:@[]];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor qtalkTextBlackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.text = @"AA收款";
        [self.backView addSubview:_titleLabel];
        
        _descInfoView = [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, kAACollectionCellWidth, 60)];
        [self.backView addSubview:_descInfoView];
        
        _imageView = [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, 8, 40, 40)];
        _imageView.backgroundColor = [UIColor qim_colorWithHex:0xFF9800];
        [_descInfoView addSubview:_imageView];
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 4, 32, 32)];
        iconView.image = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f0e4" size:28 color:[UIColor qim_colorWithHex:0xFFFFFF alpha:1.0]]];
        [_imageView addSubview:iconView];
        
        _person_numStrLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.right + 5, _titleLabel.bottom + 5, 100, 20)];
        _person_numStrLabel.adjustsFontSizeToFitWidth = YES;
        _person_numStrLabel.text = @"";
        _person_numStrLabel.font = [UIFont systemFontOfSize:13];
        _person_numStrLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_person_numStrLabel];
        
        _totalMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(_person_numStrLabel.left, _person_numStrLabel.bottom, kAACollectionCellWidth - _person_numStrLabel.left, 20)];
        _totalMoneyLabel.adjustsFontSizeToFitWidth = YES;
        _totalMoneyLabel.text = @"";
        _totalMoneyLabel.font = [UIFont systemFontOfSize:13];
        _totalMoneyLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_totalMoneyLabel];
        
        _activityTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _activityTypeLabel.text = @"来自QTalk";
        _activityTypeLabel.font = [UIFont systemFontOfSize:9];
        _activityTypeLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [self.backView addSubview:_activityTypeLabel];
        
    }
    return self;
}

-(void)refreshUI{
    
    NSString * infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    /*
     url：aa收款链接
     type：消息分类（字段值：AA收款）
     typestr：用户输入的aa收款内容
     total_money：总金额
     person_num：总人数
     avg_money：平均每人待付金额
     aa_type：aa收款分类：single|total。single是指定人情况下的aa收款，avg_money没用；total是总人数平均收款方式。
     */
    if (infoStr.length > 0) {
        NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
        NSString *type = [infoDic objectForKey:@"type"];
        NSString *avg_money = [infoDic objectForKey:@"avg_money"];
        NSString *person_num = [infoDic objectForKey:@"person_num"];
        NSString *total_money = [infoDic objectForKey:@"total_money"];
        NSString *aa_type = [infoDic objectForKey:@"aa_type"];
        
        if ([aa_type isEqualToString:@"total"]) {
            _titleLabel.text = (type.length && avg_money.length) ? [NSString stringWithFormat:@"%@，每人%@元", type, avg_money] : @"AA收款";
        } else {
            _titleLabel.text = type.length ? type : @"";
        }
        
        NSString *person_numStr = [NSString stringWithFormat:@"%@人参与", person_num];
        [_person_numStrLabel setText:person_num.length ? person_numStr : @""];
        
        _totalMoneyLabel.text = total_money ? [NSString stringWithFormat:@"共%@元", total_money] : @"";
    }
    
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:kAACollectionCellWidth WihtHeight:kAACollectionCellWidthHeight - 20];
    CGFloat leftOffset = (self.message.messageDirection == MessageDirection_Sent) ? 15 : 20;
    _titleLabel.frame = CGRectMake(leftOffset, 5, self.backView.width - 25, 25);
    _descInfoView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom + 5, kAACollectionCellWidth, 60);
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(leftOffset - 15, _descInfoView.bottom, kAACollectionCellWidth - leftOffset + 5.0f, 0.5f)];
    if (self.message.messageDirection == MessageDirection_Received) {
        _lineView.frame = CGRectMake(leftOffset - 10, _descInfoView.bottom, kAACollectionCellWidth - leftOffset + 10, 0.5f);
    }
    _lineView.backgroundColor = [UIColor qim_colorWithHex:0x9E9E9E];
    _lineView.contentMode   = UIViewContentModeBottom;
    _lineView.clipsToBounds = YES;
    [self.backView addSubview:_lineView];
    _activityTypeLabel.frame = CGRectMake(_titleLabel.left, _lineView.bottom, kAACollectionCellWidth - _titleLabel.left, 18);
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [super refreshUI];
}


@end
