
//
//  QIMMessageRefreshHeader.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/21.
//

#import "QIMMessageRefreshHeader.h"
#define TEXT_COLOR       [UIColor qim_colorWithHex:0x959595 alpha:1.0]

@implementation QIMMessageRefreshHeader

+ (MJRefreshNormalHeader *)messsageHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action {
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:action];
    header.arrowView.image = [UIImage new];
    // 设置文字
    [header setTitle:@"加载中..." forState:MJRefreshStateIdle];
    [header setTitle:@"加载中..." forState:MJRefreshStatePulling];
    [header setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    
    // 设置字体
    header.stateLabel.font = [UIFont systemFontOfSize:15];
    header.lastUpdatedTimeLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    header.stateLabel.textColor = TEXT_COLOR;
    header.lastUpdatedTimeLabel.textColor = [UIColor clearColor];
    return header;
}

@end
