//
//  QIMWorkMomentImageListView.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/8.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentContentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentImageListView : UIView

@property (nonatomic, strong) QIMWorkMomentContentModel *momentContentModel;

@property (nonatomic, copy) void (^tapSmallImageView)(QIMWorkMomentContentModel *momentContentModel, NSInteger currentTag);

@end

//### 单个小图显示视图
@interface QIMWorkMomentImageView : UIImageView

// 点击小图
@property (nonatomic, copy) void (^tapSmallView)(QIMWorkMomentImageView *imageView);

@end

NS_ASSUME_NONNULL_END
