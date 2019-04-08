//
//  QIMWorkMomentPushCell.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/6.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@class QIMWorkMomentPushCell;

@protocol QIMWorkMomentPushCellDeleteDelegate <NSObject>

- (void)removeSelectPhoto:(QIMWorkMomentPushCell *)cell;

@end

@interface QIMWorkMomentPushCell : UICollectionViewCell

@property (nonatomic, weak) id <QIMWorkMomentPushCellDeleteDelegate> dDelegate;

@property (nonatomic, assign) BOOL canDelete;

@end

NS_ASSUME_NONNULL_END
