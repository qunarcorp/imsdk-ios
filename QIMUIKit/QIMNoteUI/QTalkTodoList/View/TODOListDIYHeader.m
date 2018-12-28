//
//  TODOListDIYHeader.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/29.
//
//

#import "TODOListDIYHeader.h"
#import "QIMNoteUICommonFramework.h"

@interface TODOListDIYHeader ()

@property (strong, nonatomic) UIView *headerView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UIButton *clockBtn;
@property (strong, nonatomic) UIView *lineView;

@end

@implementation TODOListDIYHeader

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 37.5 + 20;
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = [NSBundle qim_localizedStringForKey:@"todolist_pull_add"];
    titleLabel.textColor = [UIColor orangeColor];
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;

    UIButton *clockBtn = [[UIButton alloc] init];
    [clockBtn setImage:[UIImage imageNamed:@"随机_13x12_"] forState:UIControlStateNormal];
    clockBtn.centerY = titleLabel.centerY;
    [self addSubview:clockBtn];
    self.clockBtn = clockBtn;

    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
    self.lineView = lineView;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.titleLabel.frame = CGRectMake(20, 0, self.bounds.size.width - 80, 30);
    self.clockBtn.frame = CGRectMake(self.titleLabel.right + 2, 20, 40, 40);
    self.clockBtn.centerY = self.titleLabel.centerY;
    self.lineView.frame = CGRectMake(self.titleLabel.left, self.clockBtn.bottom + 2, self.clockBtn.right - self.titleLabel.left, 0.5);
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    switch (state) {
        case MJRefreshStateIdle:
            break;
        case MJRefreshStatePulling:
            break;
        case MJRefreshStateRefreshing:
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MJRefreshStateRefreshing" object:nil];
            break;
        default:
            break;
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}

@end
