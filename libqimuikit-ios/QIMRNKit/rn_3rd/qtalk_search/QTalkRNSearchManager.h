//
//  QTalkRNSearchManager.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/12/2.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    QRNSearchGroupPriorityUserList = 0,                 //联系人列表
    QRNSearchGroupPriorityGroupList = 1,                //群组列表
    QRNSearchGroupPriorityCommonGroupList = 2,          //共同群组
    QRNSearchGroupPrioritySingleChat,                   //二人聊天
    QRNSearchGroupPriorityGroupChat,                    //群组聊天
    QRNSearchGroupPriorityLocalUserList,                //本地联系人
    QRNSearchGroupPriorityLocalGroupList,               //本地群组
    QRNSearchGroupPriorityGroupOutDomainGroupList,      //外域群组
    QRNSearchGroupPriorityGroupLocalPublicNumberList,   //本地公众号
} QRNSearchGroupPriority;

@interface QTalkRNSearchManager : NSObject
+ (NSMutableArray *)localSearch:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset groupId:(NSString *)groupId;
+ (NSDictionary *)rnSearchPublicNumberResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset;
+ (NSDictionary *)rnSearchEjabhost2GroupChatResultWithSearchKey:(NSString *)key limit:(NSInteger)limit offset:(NSInteger)offset;
+ (NSString *)searchUrl;
@end
