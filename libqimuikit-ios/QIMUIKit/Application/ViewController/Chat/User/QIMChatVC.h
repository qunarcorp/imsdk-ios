
#import "QIMCommonUIFramework.h"

@interface QIMChatVC : QTalkViewController

@property (nonatomic, strong) NSString *chatId;
@property (nonatomic, strong) NSString *bindId; //代收绑定的账号，默认为nil
@property (nonatomic, strong) NSString *stype;
@property (nonatomic, strong) NSDictionary *chatInfoDict;
@property (nonatomic, assign) BOOL needShowNewMsgTagCell;
@property (nonatomic, assign) long long readedMsgTimeStamp;
@property (nonatomic, assign) long long fastMsgTimeStamp;   //搜索时候快速点击跳转的消息时间戳
@property (nonatomic, assign) int notReadCount;

@property (nonatomic, assign) ChatType chatType;
@property (nonatomic, strong) NSString *virtualJid;

- (void)refreshCellForMsg : (Message *)msg;

- (void)refreshTableViewCell:(UITableViewCell * )cell;

- (void)sendMessage:(NSString *)message WithInfo:(NSString *)info ForMsgType:(int)msgType;

- (void)willSendImageData:(NSData *)imageData;

- (void)sendText:(NSString *)text;
@end
