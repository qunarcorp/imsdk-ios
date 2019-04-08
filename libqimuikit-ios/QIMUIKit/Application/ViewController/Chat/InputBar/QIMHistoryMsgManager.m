//
//  QIMHistoryMsgManager.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/7.
//
//

#define kMsgHistoryKey      @"kMsgHistoryKey"
#define kMsgHistoryMaxNum       30

#import "QIMHistoryMsgManager.h"

static QIMHistoryMsgManager *__global_history_manger = nil;

@interface QIMHistoryMsgManager (){
    NSMutableDictionary     * _copyOrCutTextInfo;
}
@end

@implementation QIMHistoryMsgManager

+ (id)sharedInstance {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_history_manger = [[QIMHistoryMsgManager alloc] init];
    });
    return __global_history_manger;
}

- (void)saveCopyOrCutTextInfoWithText:(NSString *)text inputItems:(NSArray *)inputItems{
    if (text.length == 0 || inputItems.count == 0) {
        return;
    }
    if (_copyOrCutTextInfo == nil) {
        _copyOrCutTextInfo = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    [_copyOrCutTextInfo setQIMSafeObject:text forKey:@"text"];
    [_copyOrCutTextInfo setQIMSafeObject:inputItems forKey:@"inputItems"];
    
}

- (NSDictionary *)getCopyOrCutTextInfo{
    return _copyOrCutTextInfo;
}

- (void)saveMsgText:(NSString *)msgText
{
    NSMutableArray * msgHsitoryList = [NSMutableArray arrayWithCapacity:1];
    [msgHsitoryList addObjectsFromArray:[[QIMKit sharedInstance] userObjectForKey:kMsgHistoryKey]];
    if (msgHsitoryList.count >= kMsgHistoryMaxNum) {
        [msgHsitoryList removeLastObject];
    }
    [msgHsitoryList insertObject:msgText atIndex:0];
    [[QIMKit sharedInstance] setUserObject:msgHsitoryList forKey:kMsgHistoryKey];
}

- (NSArray *)getMsgHistoryList
{
    NSMutableArray * msgHsitoryList = [NSMutableArray arrayWithCapacity:1];
    [msgHsitoryList addObjectsFromArray:[[QIMKit sharedInstance] userObjectForKey:kMsgHistoryKey]];
    return msgHsitoryList;
}

@end
