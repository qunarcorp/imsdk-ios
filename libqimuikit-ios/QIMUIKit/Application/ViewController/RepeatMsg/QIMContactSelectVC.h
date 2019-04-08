//
//  QIMContactSelectVC.h
//  qunarChatIphone
//
//  Created by chenjie on 2016/09/20.
//
//

#import "QIMCommonUIFramework.h"
@class QIMContactSelectVC;

@protocol QIMContactSelectVCDelegate <NSObject>

- (void)QIMContactSelectVC:(QIMContactSelectVC *)vc completeWithUsersInfo:(NSArray *)usersInfo;

@end

@interface QIMContactSelectVC : UIViewController

@property (nonatomic, assign) id<QIMContactSelectVCDelegate> delegate;
@property (nonatomic, assign) BOOL      allowMulSelect;//是否支持多选
@property (nonatomic, strong) NSArray   * defaultSelectIds;//默认选中users（支持多选，才能默认选中）

@end
