//
//  QIMWorkCommentTableView.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkCommentTableView.h"
#import "QIMWorkCommentCell.h"
#import "QIMWorkCommentModel.h"
#import "QIMMessageRefreshHeader.h"
#import <MJRefresh/MJRefresh.h>

@interface QIMWorkCommentTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *commentTableView;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, assign) UIEdgeInsets originContentInset;

@property (nonatomic, assign) UIEdgeInsets originScrollIndicatorInsets;

@end

static CGPoint tableOffsetPoint;

@implementation QIMWorkCommentTableView

- (NSMutableArray *)commentModels {
    if (!_commentModels) {
        _commentModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _commentModels;
}

- (NSMutableArray *)hotCommentModels {
    if (!_hotCommentModels) {
        _hotCommentModels = [NSMutableArray arrayWithCapacity:3];
    }
    return _hotCommentModels;
}

- (UITableView *)commentTableView {
    if (!_commentTableView) {
        _commentTableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        _commentTableView.delegate = self;
        _commentTableView.dataSource = self;
        _commentTableView.estimatedRowHeight = 0;
        _commentTableView.estimatedSectionHeaderHeight = 0;
        _commentTableView.estimatedSectionFooterHeight = 0;
        _commentTableView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8 alpha:1.0];
        _commentTableView.tableFooterView = [UIView new];
        _commentTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _commentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _commentTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComments)];
        _commentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComments)];
        _commentTableView.mj_footer.automaticallyHidden = YES;
    }
    return _commentTableView;
}

- (void)scrollTheTableViewForCommentWithKeyboardHeight:(CGFloat)keyboardHeight {
    
    if (keyboardHeight == 0) {
        self.commentTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.commentTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [UIView animateWithDuration:0.2 animations:^{
            [self.commentTableView setContentOffset:tableOffsetPoint animated:YES];
        } completion:nil];
    } else {
        tableOffsetPoint = self.commentTableView.contentOffset;
        self.commentTableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        self.commentTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, keyboardHeight, 0);
        [UIView animateWithDuration:0.2 animations:^{
            if (self.selectedIndexPath) {
                [self.commentTableView scrollToRowAtIndexPath:self.selectedIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        } completion:nil];
    }
}

- (void)loadNewComments {
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(loadNewComments)]) {
        [self.commentDelegate loadNewComments];
    }
}

- (void)loadMoreComments {
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(loadMoreComments)]) {
        [self.commentDelegate loadMoreComments];
    }
}

- (void)setCommentHeaderView:(UIView *)commentHeaderView {
    _commentHeaderView = commentHeaderView;
    [self.commentTableView setTableHeaderView:_commentHeaderView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F8];
        [self addSubview:self.commentTableView];
    }
    return self;
}

- (void)setCommentNum:(NSInteger)commentNum {
    _commentNum = commentNum;
}

- (void)reloadCommentsData {
    [self.commentTableView reloadData];
}

- (void)endRefreshingHeader {
    [self.commentTableView.mj_header endRefreshing];
}

- (void)endRefreshingFooter {
    [self.commentTableView.mj_footer endRefreshing];
}

- (void)endRefreshingFooterWithNoMoreData {
    [self.commentTableView.mj_footer endRefreshingWithNoMoreData];
}

- (void)scrollCommentModelToTopIndex {
    NSIndexPath *indexpath = nil;
    if (self.hotCommentModels.count > 0) {
        indexpath = [NSIndexPath indexPathForRow:0 inSection:1];
    } else {
        indexpath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self.commentTableView scrollToRowAtIndexPath:indexpath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)removeCommentWithIndexPath:(NSIndexPath *)indexPath {
    
    [self.commentModels removeObjectAtIndex:indexPath.row];
    [self.commentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    _commentHeaderView.hidden = NO;
    [self.commentTableView setTableHeaderView:_commentHeaderView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hotCommentModels.count > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.hotCommentModels.count > 0) {
        if (section == 0) {
            return self.hotCommentModels.count;
        } else {
            return self.commentModels.count;
        }
    } else {
        return self.commentModels.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
        }
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
    }

    NSString *cellId = [NSString stringWithFormat:@"%@-", commentModel.commentUUID];
    QIMWorkCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QIMWorkCommentCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellId];
    }
    cell.commentModel = commentModel;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
        }
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
    }
    if (self.commentDelegate && [self.commentDelegate respondsToSelector:@selector(beginControlCommentWithComment:withIndexPath:)]) {
        [self.commentDelegate beginControlCommentWithComment:commentModel withIndexPath:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkCommentModel *commentModel = nil;
    if (self.hotCommentModels.count > 0) {
        if (indexPath.section == 0) {
            commentModel = [self.hotCommentModels objectAtIndex:indexPath.row];
        } else {
            commentModel = [self.commentModels objectAtIndex:indexPath.row];
        }
        return commentModel.rowHeight;
    } else {
        commentModel = [self.commentModels objectAtIndex:indexPath.row];
        return commentModel.rowHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.commentModels.count <= 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 0.25f)];
    lineView.backgroundColor = [UIColor qim_colorWithHex:0xDDDDDD];
    [view addSubview:lineView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 21, SCREEN_WIDTH - 30, 19)];
    titleLabel.textColor = [UIColor qim_colorWithHex:0x333333];
    titleLabel.font = [UIFont boldSystemFontOfSize:19];
    
    if (self.hotCommentModels.count > 0) {
        if (section == 0) {
            [titleLabel setText:@"热门评论"];
        } else {
            if (self.commentNum > 0) {
                NSString *commentNumStr = [NSString stringWithFormat:@"（%ld）", self.commentNum];
                NSString *titleText = [NSString stringWithFormat:@"全部评论%@", commentNumStr];
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText];
                [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999], NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                        range:[titleText rangeOfString:commentNumStr]];
                [titleLabel setAttributedText:attributedText];
            } else {
                [titleLabel setText:@"全部评论"];
            }
        }
    } else {
        if (self.commentNum > 0) {
            NSString *commentNumStr = [NSString stringWithFormat:@"（%ld）", self.commentNum];
            NSString *titleText = [NSString stringWithFormat:@"全部评论%@", commentNumStr];
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:titleText];
            [attributedText setAttributes:@{NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x999999], NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                    range:[titleText rangeOfString:commentNumStr]];
            [titleLabel setAttributedText:attributedText];
        } else {
            [titleLabel setText:@"全部评论"];
        }
    }

    [view addSubview:titleLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.commentModels.count <= 0) {
        return 0.00001f;
    }
    return 60;
}

@end
