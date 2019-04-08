//
//  QIMRedPackDescCell.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/5.
//
//

#define kQIMRedPackDescCellWidth       150

#import "QIMMsgBaloonBaseCell.h"
#import "QIMRedPackDescCell.h"
#import "QIMUserInfoUtil.h"
#import "QIMJSONSerializer.h"

@interface QIMRedPackDescCell () {
    UIImageView             * _flagView;
    UILabel                 * _descLabel;
    UIView                  * _bgView;
}

@end

@implementation QIMRedPackDescCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message  chatType:(ChatType)chatType{
    return  30;
}

+ (CGFloat)selfViewWidth{
    if ([[QIMKit sharedInstance] getIsIpad]) {
        return [[UIScreen mainScreen] qim_rightWidth];
    }else{
        return [UIScreen mainScreen].bounds.size.width;
    }
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _bgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bgView.backgroundColor = [UIColor qtalkSplitLineColor];
        _bgView.layer.cornerRadius = 3;
        [self.contentView addSubview:_bgView];
        
        _flagView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _flagView.image = [UIImage imageNamed:@"SystemMessages_HongbaoIcon"];
        [_bgView addSubview:_flagView];
        
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.font = [UIFont systemFontOfSize:12];
        [_bgView addSubview:_descLabel];
        
    }
    return self;
}

-(void)refreshUI{
    
    _flagView.frame = CGRectMake(5, 3, 14, 14);
    
//    Url        //红包页面
//    From_User  //发送红包的人例:suozhu.li
//    Open_User  //打开红包的人例:suozhu.li
//    Type      //红包类型,normal=普通红包,lucky=拼手气 例:normal
//    Typestr    //红包类型字符串 例:普通红包
//    Balance    //红包剩余个数，如果为0则为抢完了例:0
    NSString * infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    QIMVerboseLog(@"红包Info：%@", infoStr);
    if (infoStr.length > 0) {
        NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
        NSString *Open_User = [infoDic objectForKey:@"Open_User"];
        NSString *openUserName = [[QIMKit sharedInstance] getUserMarkupNameWithUserId:Open_User];
        
        NSMutableAttributedString * mulStr = [[NSMutableAttributedString alloc] initWithString:@""];
        [mulStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@抢到了你的",(openUserName.length > 0) ? openUserName : [[Open_User componentsSeparatedByString:@"@"] firstObject]] attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:12]}]];
        NSString *typeStr = [infoDic objectForKey:@"Typestr"];
        [mulStr appendAttributedString:[[NSAttributedString alloc] initWithString:typeStr?typeStr:@"红包" attributes:@{ NSForegroundColorAttributeName:[UIColor redColor],NSFontAttributeName:[UIFont systemFontOfSize:12]}]];
        int balance = [infoDic[@"Balance"] intValue];
        if (balance == 0) {
            [mulStr appendAttributedString:[[NSAttributedString alloc] initWithString:@",你的红包被领完了" attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:12]}]];
        } else { 
            [mulStr appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@",还剩%d个红包",balance] attributes:@{ NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:12]}]];
        }
        _descLabel.attributedText = mulStr;
        
        CGSize textSize = [mulStr.string qim_sizeWithFontCompatible:[UIFont systemFontOfSize:12] forWidth:self.contentView.width lineBreakMode:NSLineBreakByCharWrapping];
        _bgView.frame = CGRectMake(([QIMRedPackDescCell selfViewWidth] - (textSize.width + 15 + _flagView.width)) / 2, 5, textSize.width + 15 + _flagView.width, 20);
        _descLabel.frame = CGRectMake(_flagView.right + 5, 3, _bgView.width - _flagView.right - 5, 14);
    }else{
        _descLabel.text = @"某人领取了红包";
        _bgView.frame = CGRectMake(([QIMRedPackDescCell selfViewWidth] - kQIMRedPackDescCellWidth) / 2, 5, kQIMRedPackDescCellWidth, 20);
        
        _descLabel.frame = CGRectMake(_flagView.right + 5, 3, kQIMRedPackDescCellWidth - _flagView.right - 10, 14);
    }
    [super refreshUI];
    self.HeadView.hidden = YES;
    self.nameLabel.hidden = YES;
}

- (NSArray *)showMenuActionTypeList {
    return @[];
}

@end
