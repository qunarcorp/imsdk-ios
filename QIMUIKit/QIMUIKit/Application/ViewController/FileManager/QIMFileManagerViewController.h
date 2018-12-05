//
//  QIMFileManagerViewController.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/24.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMFileManagerViewController : QTalkViewController

@property (nonatomic,assign) BOOL       isSelect;//是否是选择界面
@property (nonatomic,copy) NSString         * userId;
@property (nonatomic,assign) ChatType    messageSaveType;

@end
