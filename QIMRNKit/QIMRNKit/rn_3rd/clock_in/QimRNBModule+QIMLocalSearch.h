//
//  QimRNBModule+QIMLocalSearch.h
//  QIMUIKit
//
//  Created by lilu on 2018/12/4.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QimRNBModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface QimRNBModule (QIMLocalSearch)

+ (NSDictionary *)qimrn_searchLocalMsgWithUserParam:(NSDictionary *)param;

+ (NSDictionary *)qimrn_searchLocalFileWithUserParam:(NSDictionary *)param;

+ (NSDictionary *)qimrn_searchLocalLinkWithUserParam:(NSDictionary *)param;

@end

NS_ASSUME_NONNULL_END
