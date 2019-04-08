//
//  QIMWorkMomentNotifyView.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"

NS_ASSUME_NONNULL_BEGIN

@protocol QIMWorkMomentNotifyViewDelegtae <NSObject>

- (void)didClickNotifyView;

@end

@interface QIMWorkMomentNotifyView : UIView

@property (nonatomic, weak) id <QIMWorkMomentNotifyViewDelegtae> delegate;

@property (nonatomic, assign) NSInteger msgCount;

- (instancetype)initWithNewMsgCount:(NSInteger)msgCount;

@end

NS_ASSUME_NONNULL_END
