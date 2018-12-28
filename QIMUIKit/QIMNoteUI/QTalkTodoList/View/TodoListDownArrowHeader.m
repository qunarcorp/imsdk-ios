//
//  TodoListDownArrowHeader.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/31.
//
//

#import "TodoListDownArrowHeader.h"
#import "QIMNoteUICommonFramework.h"

@interface TodoListDownArrowHeader ()

@property (nonatomic, strong) UIImageView *downArrowIconView;

@end

@implementation TodoListDownArrowHeader

- (void)prepare
{
    [super prepare];
    self.mj_h = 60;
    // 初始化间距
    UIImageView *iconView = [[UIImageView alloc] init];
    [self addSubview:iconView];
    self.downArrowIconView = iconView;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.downArrowIconView.frame = CGRectMake(0, 5, 35, 35);
    self.downArrowIconView.centerX = self.centerX;
    self.downArrowIconView.image = [UIImage imageNamed:@"chat_bottom_arrowdown_nor@2x"];
}

- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState
    
    switch (state) {
        case MJRefreshStateIdle:
            break;
        case MJRefreshStatePulling:
            break;
        case MJRefreshStateRefreshing:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MJRefreshDownArrowStateRefreshing" object:nil];
            break;
        default:
            break;
    }
}

@end
