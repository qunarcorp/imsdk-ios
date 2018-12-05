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
@property (nonatomic, strong) NSString *stype;
@property (nonatomic, strong) NSString *name;

@end
