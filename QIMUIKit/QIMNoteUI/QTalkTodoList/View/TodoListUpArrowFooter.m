//
//  TodoListDownArrowFooter.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/31.
//
//

#import "TodoListUpArrowFooter.h"
#import "QIMNoteUICommonFramework.h"

@interface TodoListUpArrowFooter ()

@property (nonatomic, strong) UIImageView *upArrowIconView;

@end

@implementation TodoListUpArrowFooter

#pragma mark - 重写父类的方法
- (void)prepare
{
    [super prepare];
    self.mj_h = 40;
    // 初始化间距
    UIImageView *iconView = [[UIImageView alloc] init];
    [self addSubview:iconView];
    self.upArrowIconView = iconView;
}

- (void)placeSubviews
{
    [super placeSubviews];
    
    self.upArrowIconView.frame = CGRectMake(0, 5, 35, 35);
    self.upArrowIconView.centerX = self.centerX;
    self.upArrowIconView.image = [UIImage imageNamed:@"chat_bottom_arrowup_nor@2x"];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MJRefreshUpArrowStateRefreshing" object:nil];
            break;
        default:
            break;
    }
}

@end
