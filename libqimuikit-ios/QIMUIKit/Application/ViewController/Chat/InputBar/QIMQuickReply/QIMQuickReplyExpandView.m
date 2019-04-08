//
//  QIMQuickReplyExpandView.m
//  QIMUIKit
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMQuickReplyExpandView.h"
#import "QIMQuickReplySubTableView.h"
#import "QIMQuickReplyGroupCollectionView.h"
#import "SwipeTableView.h"
#import <objc/message.h>

@interface QIMQuickReplyExpandView () <SwipeTableViewDataSource,SwipeTableViewDelegate, QIMQuickReplyGroupCollectionViewDelegate>

@property (nonatomic, strong) QIMQuickReplySubTableView *subQuickReplyView;
@property (nonatomic, strong) QIMQuickReplyGroupCollectionView *groupCollectionView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) SwipeTableView *swipeTableView;

@property (nonatomic, strong) NSMutableArray *quickReplyGroups;

@property (nonatomic, strong) NSMutableDictionary *quickReplyGroupContents;

@end

@implementation QIMQuickReplyExpandView

#pragma mark - setter and getter

- (SwipeTableView *)swipeTableView {
    if (!_swipeTableView) {
        _swipeTableView = [[SwipeTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 50)];
        _swipeTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _swipeTableView.delegate = self;
        _swipeTableView.dataSource = self;
        _swipeTableView.shouldAdjustContentSize = YES;
        _swipeTableView.swipeHeaderView = nil;
        _swipeTableView.swipeHeaderBar = nil;
        _swipeTableView.swipeHeaderTopInset = 0;
        _swipeTableView.swipeHeaderBarScrollDisabled = NO;
        _swipeTableView.backgroundColor = [UIColor qtalkChatBgColor];
        _swipeTableView.contentView.backgroundColor = [UIColor qtalkChatBgColor];
    }
    return _swipeTableView;
}

- (QIMQuickReplySubTableView *)subQuickReplyView {
    if (!_subQuickReplyView) {
        _subQuickReplyView = [[QIMQuickReplySubTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 50)];
        _subQuickReplyView.backgroundColor = [UIColor qtalkChatBgColor];
    }
    return _subQuickReplyView;
}

- (QIMQuickReplyGroupCollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        _groupCollectionView = [[QIMQuickReplyGroupCollectionView alloc] initWithFrame:CGRectMake(0, self.swipeTableView.bottom + 15, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.swipeTableView.bottom - 15)];
        _groupCollectionView.quickReplyGroupDelegate = self;
        _groupCollectionView.quickReplyGroup = self.quickReplyGroups;
    }
    return _groupCollectionView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.centerX = self.centerX;
        _pageControl.centerY = self.swipeTableView.bottom + 15/2.0f;
        _pageControl.currentPage  = 0;
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        _pageControl.currentPageIndicatorTintColor = [UIColor redColor];
        [_pageControl addTarget:self action:@selector(pageControlHandle:) forControlEvents:UIControlEventValueChanged];
    }
    _pageControl.numberOfPages = self.quickReplyGroups.count;
    return _pageControl;
}

- (NSMutableArray *)quickReplyGroups {
    if (!_quickReplyGroups) {
        _quickReplyGroups = [NSMutableArray arrayWithArray:[[QIMKit sharedInstance] getQuickReplyGroup]];
    }
    return _quickReplyGroups;
}

- (NSMutableDictionary *)quickReplyGroupContents {
    if (!_quickReplyGroupContents) {
        _quickReplyGroupContents = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _quickReplyGroupContents;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor qtalkChatBgColor];
        if (self.quickReplyGroups.count <= 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:self.frame];
            [label setText:@"请在PC客户端设置快捷回复"];
            [label setContentMode:UIViewContentModeCenter];
            [label setTextAlignment:NSTextAlignmentCenter];
            [self addSubview:label];
        } else {
            [self addSubview:self.swipeTableView];
            [self addSubview:self.groupCollectionView];
            [self addSubview:self.pageControl];
            [self updateGroupIndex:0];
        }
    }
    return self;
}

#pragma mark - SwipeTableView M

- (NSInteger)numberOfItemsInSwipeTableView:(SwipeTableView *)swipeView {
    return self.quickReplyGroups.count;
}

- (UIScrollView *)swipeTableView:(SwipeTableView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIScrollView *)view {
    QIMQuickReplySubTableView *tableView = (QIMQuickReplySubTableView *)view;
    // 重用
    if (nil == tableView) {
        tableView = [[QIMQuickReplySubTableView alloc]initWithFrame:swipeView.bounds];
        tableView.backgroundColor = [UIColor qtalkChatBgColor];
    }
    // 获取当前index下item的数据，进行数据刷新
    NSDictionary *groupInfo = [self.quickReplyGroups objectAtIndex:index];
    long groupId = [[groupInfo objectForKey:@"sid"] longValue];
    id data = [self.quickReplyGroupContents objectForKey:@(groupId)];
    if (data == nil) {
        if (groupInfo.count > 0) {
            data = (NSArray *)[[QIMKit sharedInstance] getQuickReplyContentWithGroupId:groupId];
            if (data) {
                [self.quickReplyGroupContents setObject:data forKey:@(groupId)];
            }
        }
    }
    [tableView refreshWithData:data atIndex:index];
    view = tableView;
    return view;
}

// swipetableView index变化，改变seg的index
- (void)swipeTableViewCurrentItemIndexDidChange:(SwipeTableView *)swipeView {
    
    [self updateGroupIndex:swipeView.currentItemIndex];
}

// 滚动结束请求数据
- (void)swipeTableViewDidEndDecelerating:(SwipeTableView *)swipeView {

}

- (BOOL)swipeTableView:(SwipeTableView *)swipeTableView shouldPullToRefreshAtIndex:(NSInteger)index {
    return NO;
}

- (CGFloat)swipeTableView:(SwipeTableView *)swipeTableView heightForRefreshHeaderAtIndex:(NSInteger)index {
    return 0;
}

- (void)didSelectQuickReplyGroupItemAtIndex:(NSInteger)index {
    [self updateGroupIndex:index];
    [self.swipeTableView scrollToItemAtIndex:index animated:NO];
}

- (void)updateGroupIndex:(NSInteger)index {
    self.pageControl.currentPage = index;
    [self.groupCollectionView updateSelectItemAtIndexPath:index];
}

@end
