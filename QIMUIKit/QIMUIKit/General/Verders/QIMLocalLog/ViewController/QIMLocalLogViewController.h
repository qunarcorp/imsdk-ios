//
//  QIMLocalLogViewController.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/10.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMLocalLogViewController : QTalkViewController

@property (nonatomic,assign) BOOL       isSelect;//是否是选择界面
@property (nonatomic,copy) NSString     *userId;
@property (nonatomic,assign) ChatType    messageSaveType;
- (void)setLogFileAttributeArray:(NSArray *)logFileAttributeArray;

@end
