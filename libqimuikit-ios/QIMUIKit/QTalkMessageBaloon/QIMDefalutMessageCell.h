//
//  QIMDefalutMessageCell.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/2.
//

#import "QIMCommonUIFramework.h"

@class QIMMsgBaloonBaseCell;
@interface QIMDefalutMessageCell : QIMMsgBaloonBaseCell

@property (nonatomic, strong) Message *message;

@property (nonatomic, strong) YLImageView *HeaderView;  //用户头像

@property (nonatomic, strong) UILabel *nameLabel; //用户昵称

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;   //加载菊花

@property (nonatomic, strong) UIButton *statusButton;   //消息发送状态按钮

@property (nonatomic, assign) ChatType chatType;

@property (nonatomic, assign) CGFloat frameWidth;

@property (nonatomic,weak)id<QIMMsgBaloonBaseCellDelegate> delegate;

- (void)refreshUI;

@end
