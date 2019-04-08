//
//  QIMMessageRefreshHeader.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/21.
//

#import "QIMCommonUIFramework.h"
#import "MJRefreshNormalHeader.h"

@interface QIMMessageRefreshHeader : NSObject

+ (MJRefreshNormalHeader *)messsageHeaderWithRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end
