//
//  QIMWorkMomentView.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/29.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MomentViewDelegate <NSObject>

@optional

- (void)didClickSmallImage:(QIMWorkMomentModel *)model WithCurrentTag:(NSInteger)tag;

@end



@interface QIMWorkMomentView : UIView

@property (nonatomic, weak) id <MomentViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withMomentModel:(QIMWorkMomentModel *)model;

@end

NS_ASSUME_NONNULL_END
