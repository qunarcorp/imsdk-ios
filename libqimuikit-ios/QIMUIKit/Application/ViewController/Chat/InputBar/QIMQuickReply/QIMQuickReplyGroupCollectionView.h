//
//  QIMQuickReplyGroupCollectionView.h
//  QIMUIKit
//
//  Created by 李露 on 2018/8/8.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@protocol QIMQuickReplyGroupCollectionViewDelegate <NSObject>

@required
- (void)didSelectQuickReplyGroupItemAtIndex:(NSInteger)index;

@end

@interface QIMQuickReplyGroupCollectionView : UIView 

@property (nonatomic, weak) id <QIMQuickReplyGroupCollectionViewDelegate> quickReplyGroupDelegate;

@property (nonatomic, strong) NSArray *quickReplyGroup;

- (void)updateSelectItemAtIndexPath:(NSInteger)index;

@end
