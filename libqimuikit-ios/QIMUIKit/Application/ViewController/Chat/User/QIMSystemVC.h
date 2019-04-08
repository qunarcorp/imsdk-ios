//
//  QIMSystemVC.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/6/5.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMSystemVC : QTalkViewController
{
    UITableView *_tableView;
}

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, strong) NSDictionary *chatInfoDict;
@property (nonatomic, assign) long long fastMsgTimeStamp;   //搜索时候快速点击跳转的消息时间戳
@property (nonatomic, strong) NSString *stype;

@end
