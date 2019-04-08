//
//  QIMWorkMomentCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMarginLabel.h"

NS_ASSUME_NONNULL_BEGIN

@class QIMWorkMomentCell;
@class QIMWorkMomentModel;
@class QIMWorkMomentLabel;
@class QIMWorkMomentImageListView;

@protocol MomentCellDelegate <NSObject>

@optional

//操作Moment
- (void)didControlPanelMoment:(QIMWorkMomentCell *)cell;
//操作Moment
- (void)didControlDebugPanelMoment:(QIMWorkMomentCell *)cell;
// 评论
- (void)didAddComment:(QIMWorkMomentCell *)cell;
// 查看全文/收起
- (void)didSelectFullText:(QIMWorkMomentCell *)cell withFullText:(BOOL)isFullText;

- (void)didClickSmallImage:(QIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag;
// 点击高亮文字
//- (void)didClickLink:(MLLink *)link linkText:(NSString *)linkText;

@end

@interface QIMWorkMomentCell : UITableViewCell

// 头像
@property (nonatomic, strong) UIImageView *headImageView;
// 名称
@property (nonatomic, strong) UILabel *nameLab;
//组织架构Label
@property (nonatomic, strong) QIMMarginLabel *organLab;
//服务器IdLabel
@property (nonatomic, strong) UILabel *rIdLabe;
// 时间
@property (nonatomic, strong) UILabel *timeLab;
// 操作按钮
@property (nonatomic, strong) UIButton *controlBtn;
//操作按钮
@property (nonatomic, strong) UIButton *controlDebugBtn;
// 查看全文按钮
@property (nonatomic, strong) UIButton *showAllBtn;
// 内容
@property (nonatomic, strong) QIMWorkMomentLabel *contentLabel;

// 图片
@property (nonatomic, strong) QIMWorkMomentImageListView *imageListView;

//点赞按钮
@property (nonatomic, strong) UIButton *likeBtn;

//评论按钮
@property (nonatomic, strong) UIButton *commentBtn;

@property (nonatomic, strong) UIView *lineView;

// 动态
@property (nonatomic, strong) QIMWorkMomentModel *moment;
// 代理
@property (nonatomic, assign) id<MomentCellDelegate> delegate;

//点赞按钮开关
@property (nonatomic, assign) BOOL likeActionHidden;

//评论按钮开关
@property (nonatomic, assign) BOOL commentActionHidden;

@property (nonatomic, assign) BOOL alwaysFullText;

@property (nonatomic, assign) BOOL notShowControl;

@end

NS_ASSUME_NONNULL_END
