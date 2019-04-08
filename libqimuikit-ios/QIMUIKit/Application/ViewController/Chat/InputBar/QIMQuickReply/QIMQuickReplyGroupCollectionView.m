//
//  QIMQuickReplyGroupCollectionView.m
//  QIMUIKit
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMQuickReplyGroupCollectionView.h"
#import "QIMQuickReplyGroupTagCell.h"

@interface QIMQuickReplyGroupCollectionView () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *groupCollectionView;

@property (nonatomic, assign) NSInteger currentSelectIndex;

@end

@implementation QIMQuickReplyGroupCollectionView

#pragma mark - setter and getter

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(100, CGRectGetHeight(self.frame));
        layout.minimumLineSpacing = 0.05;
        layout.minimumInteritemSpacing = 0;
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) collectionViewLayout:layout];
        [_groupCollectionView registerClass:[QIMQuickReplyGroupTagCell class] forCellWithReuseIdentifier:@"xxx"];
        _groupCollectionView.delegate = self;
        _groupCollectionView.dataSource = self;
        _groupCollectionView.backgroundColor = [UIColor colorWithRed:233 green:233 blue:233 alpha:1.0];
        _groupCollectionView.bounces = NO;
        _groupCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _groupCollectionView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.groupCollectionView];
    }
    return self;
}

- (void)updateSelectItemAtIndexPath:(NSInteger)index {
    self.currentSelectIndex = index;
    [self.groupCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
    [self.groupCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.quickReplyGroup.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *groupInfo = [self.quickReplyGroup objectAtIndex:indexPath.row];
    QIMQuickReplyGroupTagCell *cell = (QIMQuickReplyGroupTagCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"xxx" forIndexPath:indexPath];
    NSString *groupName = [groupInfo objectForKey:@"groupname"];
    [cell.tagLabel setText:groupName];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.quickReplyGroupDelegate && [self.quickReplyGroupDelegate respondsToSelector:@selector(didSelectQuickReplyGroupItemAtIndex:)]) {
        [self.quickReplyGroupDelegate didSelectQuickReplyGroupItemAtIndex:indexPath.row];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.currentSelectIndex) {
        cell.contentView.backgroundColor = [UIColor qim_colorWithHex:0x15b0f9 alpha:1.0];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
}

@end
