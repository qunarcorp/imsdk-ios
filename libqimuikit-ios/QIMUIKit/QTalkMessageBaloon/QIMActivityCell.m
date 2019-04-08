//
//  QIMActivityCell.m
//  qunarChatIphone
//
//  Created by chenjie on 16/4/7.
//
//

#define kActivityCellWidth      240
#define kActiviifyCellHeight    130

#import "QIMMsgBaloonBaseCell.h"
#import "QIMActivityCell.h"
#import "QIMJSONSerializer.h"
#import "UIImageView+WebCache.h"

@interface QIMActivityCell(){
    UILabel         * _titleLabel;          //活动标题
    UIImageView     * _imageView;           //活动图标
    UIView          * _descInfoView;        //活动详情View
    
    UILabel         * _activityLocaltionLabel;  //IP城市-活动城市
    UILabel         * _activityCategoryLabel;   //活动分类（例如：自驾、骑行、登山等）
    UILabel         * _activityStartTimeLabel;   //活动开始时间
    UILabel         * _activityEndTimeLabel;   //活动结束时间
    
    UILabel         * _lineView;
    UILabel         * _activityTypeLabel;   //线上活动|线下活动
}

@end

@implementation QIMActivityCell

+ (CGFloat)getCellHeightWihtMessage:(Message *)message chatType:(ChatType)chatType{
    return  kActiviifyCellHeight;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        self.contentView.backgroundColor = [UIColor qtalkChatBgColor];
        
        [self.backView setMenuActionTypeList:@[]];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor qtalkTextBlackColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _titleLabel.text = @"活动";
        [self.backView addSubview:_titleLabel];
        
        _descInfoView = [[UIView alloc] initWithFrame:CGRectMake(_titleLabel.left, _titleLabel.bottom, kActivityCellWidth, 60)];
        [self.backView addSubview:_descInfoView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_titleLabel.left, 8, 40, 40)];
        [_descInfoView addSubview:_imageView];
        
        _activityLocaltionLabel = [[UILabel alloc] initWithFrame:CGRectMake(_imageView.right + 5, 0, 100, 20)];
        _activityLocaltionLabel.adjustsFontSizeToFitWidth = YES;
        _activityLocaltionLabel.text = @"";
        _activityLocaltionLabel.font = [UIFont systemFontOfSize:13];
        _activityLocaltionLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_activityLocaltionLabel];
        
        _activityCategoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(_activityLocaltionLabel.right + 5, 0, 50, 20)];
        _activityCategoryLabel.text = @"";
        _activityCategoryLabel.adjustsFontSizeToFitWidth = YES;
        _activityCategoryLabel.font = [UIFont systemFontOfSize:13];
        _activityCategoryLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_activityCategoryLabel];

        
        _activityStartTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_activityLocaltionLabel.left, _activityLocaltionLabel.bottom, kActivityCellWidth - _activityLocaltionLabel.left, 20)];
        _activityStartTimeLabel.adjustsFontSizeToFitWidth = YES;
        _activityStartTimeLabel.text = @"";
        _activityStartTimeLabel.font = [UIFont systemFontOfSize:13];
        _activityStartTimeLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_activityStartTimeLabel];

        _activityEndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_activityStartTimeLabel.left, _activityStartTimeLabel.bottom, kActivityCellWidth - _activityStartTimeLabel.left, 20)];
        _activityEndTimeLabel.adjustsFontSizeToFitWidth = YES;
        _activityEndTimeLabel.text = @"";
        _activityEndTimeLabel.font = [UIFont systemFontOfSize:13];
        _activityEndTimeLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [_descInfoView addSubview:_activityEndTimeLabel];
        
        _activityTypeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _activityTypeLabel.text = @"活动";
        _activityTypeLabel.font = [UIFont systemFontOfSize:9];
        _activityTypeLabel.textColor = [UIColor qim_colorWithHex:0x9E9E9E];
        [self.backView addSubview:_activityTypeLabel];
                
    }
    return self;
}

-(void)refreshUI{
    
    NSString * infoStr = self.message.extendInformation.length <= 0 ? self.message.message : self.message.extendInformation;
    /*
     url：活动链接
     type： 消息分类（字段值：旅途活动）
     title：活动标题
     img：气泡活动图片
     intro：活动介绍
     activity_city：活动城市（例如：北京）
     address：活动具体地址（例如：海淀区维亚大厦）
     ip_city：IP定位当前城市（发布活动人的ip城市）
     start_date：活动开始时间（例如：2018-06-30）
     end_date：活动结束时间（例如：2018-07-01）
     category：活动分类（例如：自驾、骑行、登山等）
     activity_type：线上活动|线下活动
     */
    if (infoStr.length > 0) {
        NSDictionary * infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:infoStr error:nil];
        NSString *title = [infoDic objectForKey:@"title"];
        NSString *activity_city = [infoDic objectForKey:@"activity_city"];
        NSString *ip_city = [infoDic objectForKey:@"ip_city"];
        NSString *startTime = [infoDic objectForKey:@"start_date"];
        NSString *end_date = [infoDic objectForKey:@"end_date"];
        
        NSString *category = [infoDic objectForKey:@"category"];
        NSString *activity_type = [infoDic objectForKey:@"activity_type"];
        
        NSString *imgStr = [infoDic objectForKey:@"img"];
        if ([imgStr isKindOfClass:[NSString class]]) {
            [_imageView qim_setImageWithURL:[NSURL URLWithString:imgStr] placeholderImage:[QIMKit defaultCommonTrdInfoImage]];
        } else{
            [_imageView setImage:[QIMKit defaultCommonTrdInfoImage]];
        }
        NSString *locationStr = [NSString stringWithFormat:@"%@-%@", ip_city, activity_city];
        [_activityLocaltionLabel setText:(ip_city.length && activity_city.length) ? locationStr : @""];
        _activityCategoryLabel.text = category ? category : @"";
        
        _activityStartTimeLabel.text = startTime ? [NSString stringWithFormat:@"开始时间: %@", startTime] : @"";
        _activityEndTimeLabel.text = end_date ? [NSString stringWithFormat:@"结束时间: %@", end_date] : @"";
        
        _activityTypeLabel.text = activity_type ? activity_type : @"活动";
    }
    
    [self.backView setMessage:self.message];
    [self setBackViewWithWidth:kActivityCellWidth WihtHeight:kActiviifyCellHeight - 20];
    CGFloat leftOffset = (self.message.messageDirection == MessageDirection_Sent) ? 15 : 20;
    _titleLabel.frame = CGRectMake(leftOffset, 5, self.backView.width - 25, 25);
    _descInfoView.frame = CGRectMake(_titleLabel.left, _titleLabel.bottom, kActivityCellWidth, 60);
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(leftOffset - 15, _descInfoView.bottom - 0.5f, kActivityCellWidth - leftOffset + 5.0f, 0.5f)];
    if (self.message.messageDirection == MessageDirection_Received) {
        _lineView.frame = CGRectMake(leftOffset - 10, _descInfoView.bottom, kActivityCellWidth - leftOffset + 10, 0.5f);
    }
    _lineView.backgroundColor = [UIColor qim_colorWithHex:0x9E9E9E];
    _lineView.contentMode   = UIViewContentModeBottom;
    _lineView.clipsToBounds = YES;
    [self.backView addSubview:_lineView];
    _activityTypeLabel.frame = CGRectMake(_titleLabel.left, _lineView.bottom, kActivityCellWidth - _titleLabel.left, 18);
    [self.backView setBubbleBgColor:[UIColor whiteColor]];
    [super refreshUI];
}

@end
