//
//  QIMQuickReplySubTableView.m
//  QIMUIKit
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMQuickReplySubTableView.h"

@interface QIMQuickReplySubTableView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *quickContentArray;

@end

@implementation QIMQuickReplySubTableView

#pragma mark - setter and getter

- (NSMutableArray *)quickContentArray {
    if (!_quickContentArray) {
        _quickContentArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _quickContentArray;
}

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
        self.backgroundColor = [UIColor qtalkChatBgColor];
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        self.tableHeaderView = [[UIView alloc] initWithFrame:tableHeaderViewFrame];
        self.tableHeaderView.backgroundColor = [UIColor qtalkChatBgColor];
        self.tableFooterView = [UIView new];
        self.tableFooterView.backgroundColor = [UIColor qtalkChatBgColor];
        self.separatorInset = UIEdgeInsetsMake(0,20, 0, 0);           //top left bottom right 左右边距相同
        self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return self;
}

- (void)refreshWithData:(id)quickReplyContents atIndex:(NSInteger)index {
    
    if ([quickReplyContents isKindOfClass:[NSArray class]]) {
        _quickContentArray = [NSMutableArray arrayWithArray:quickReplyContents];
        [self reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.quickContentArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *contentInfo = [self.quickContentArray objectAtIndex:indexPath.row];
    NSString *quickReplyContent = [contentInfo objectForKey:@"content"];
    NSString *cellIdentifier = [NSString stringWithFormat:@"%ld-%ld-%ld", indexPath.section, indexPath.row, indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.backgroundColor = [UIColor qtalkChatBgColor];
    cell.textLabel.text = quickReplyContent;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 36;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *contentInfo = [self.quickContentArray objectAtIndex:indexPath.row];
    NSString *quickReplyContent = [contentInfo objectForKey:@"content"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendQuickReplyContent object:quickReplyContent];
    });
}

@end
