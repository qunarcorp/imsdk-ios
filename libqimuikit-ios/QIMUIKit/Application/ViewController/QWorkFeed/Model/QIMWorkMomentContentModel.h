//
//  QIMWorkMomentContentModel.h
//  QIMUIKit
//
//  Created by lilu on 2019/1/9.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMWorkMomentPicture.h"

NS_ASSUME_NONNULL_BEGIN

@interface QIMWorkMomentContentModel : NSObject

@property (nonatomic, copy) NSString *content;  //Content

@property (nonatomic, strong) NSArray <QIMWorkMomentPicture *> *imgList;

@end

NS_ASSUME_NONNULL_END
