//
//  QTalkMessageManager.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/9.
//
//

#import "QTalkMessageManager.h"
#import "QIMMsgBaloonBaseCell.h"
#import "QIMMsgBaseVC.h"
static QTalkMessageManager *__global_msg_manager = nil;

@implementation QTalkMessageManager{
    NSMutableDictionary *_msgCellClassDic;
    NSMutableDictionary *_msgVCClassDic;
    NSMutableArray *_textBarButtonList;
    NSMutableDictionary *_showTextDic;
}

+ (QTalkMessageManager *)sharedInstance{
    @synchronized(self) {
        if (__global_msg_manager == nil) {
            __global_msg_manager = [[QTalkMessageManager alloc] init];
        }
    }
    return __global_msg_manager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _msgCellClassDic = [[NSMutableDictionary alloc] initWithCapacity:5];
        _msgVCClassDic = [[NSMutableDictionary alloc] init];
        _textBarButtonList = [[NSMutableArray alloc] init];
        _showTextDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSArray *)getSupportMsgTypeList{
    return _msgCellClassDic.allKeys;
}

- (void)setMsgShowText:(NSString *)showText ForMessageType:(QIMMessageType)messageType{
    [_showTextDic setQIMSafeObject:showText forKey:@(messageType)];
}

- (NSString *)getMsgShowTextForMessageType:(QIMMessageType)messageType{
    return [_showTextDic objectForKey:@(messageType)];
}

- (void)registerMsgCellClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType{
    @try {
        if ([cellClass isSubclassOfClass:[QIMMsgBaloonBaseCell class]]) {
            [_msgCellClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (void)registerMsgCellClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType{
    @try {
        Class cellClass = NSClassFromString(cellClassName);
        if ([cellClass isSubclassOfClass:[QIMMsgBaloonBaseCell class]] && ![cellClassName isEqualToString:@"QIMDefalutMessageCell"]) {
            [_msgCellClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {
        
    }
}

- (Class)getRegisterMsgCellClassForMessageType:(QIMMessageType)messageType{
    return [_msgCellClassDic objectForKey:@(messageType)];
}

- (QIMMsgBaloonBaseCell *)getRegisterMsgCellForMessageType:(QIMMessageType)messageType{
    Class someClass = [_msgCellClassDic objectForKey:@(messageType)];
    return [[someClass alloc] init];
}

- (void)registerMsgVCClass:(Class)cellClass ForMessageType:(QIMMessageType)messageType{

    @try {
        if ([cellClass isSubclassOfClass:[QIMMsgBaseVC class]]) {
            [_msgVCClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (void)registerMsgVCClassName:(NSString *)cellClassName ForMessageType:(QIMMessageType)messageType{
    @try {
        Class cellClass = NSClassFromString(cellClassName);
        if ([cellClass isSubclassOfClass:[QIMMsgBaseVC class]]) {
            [_msgVCClassDic setObject:cellClass forKey:@(messageType)];
        }
    } @catch (NSException *exception) {

    }
}

- (Class)getRegisterMsgVCClassForMessageType:(QIMMessageType)messageType{
    return [_msgVCClassDic objectForKey:@(messageType)];
}

- (QIMMsgBaseVC *)getRegisterMsgVCForMessageType:(QIMMessageType)messageType{
    Class someClass = [_msgVCClassDic objectForKey:@(messageType)];
    return [[someClass alloc] init];
}

- (void)addMsgTextBarWithImage:(NSString *)imageName WithTitle:(NSString *)title ForItemType:(QIMTextBarExpandViewItemType)itemType pushVC:(QIMMsgBaseVC *)pushVC{
    if (imageName.length > 0) {
        if (!_textBarButtonList) {
            _textBarButtonList = [NSMutableArray arrayWithCapacity:1];
        }
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:1];
        [dic setObject:imageName?imageName:@"" forKey:@"ImageName"];
        [dic setObject:title?title:@"" forKey:@"Title"];
        [dic setObject:@(itemType) forKey:@"ItemType"];
        if (pushVC) {
            [dic setObject:pushVC forKey:@"pushVC"];
        }
        [_textBarButtonList addObject:dic];
    }
}

- (NSArray *)getMsgTextBarButtonInfoList{
    return _textBarButtonList;
}

- (void)removeExpandItemsForType:(QIMTextBarExpandViewItemType)itemType
{
    [_textBarButtonList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj objectForKey:@"ItemType"] integerValue] == itemType) {
            *stop = YES;
            [_textBarButtonList removeObject:obj];
        }
    }];
}

- (void)removeAllExpandItems
{
    [_textBarButtonList removeAllObjects];
}

- (NSDictionary *)getExpandItemsForType:(QIMTextBarExpandViewItemType)itemType
{
    for (NSDictionary * infoDic in _textBarButtonList) {
        if ([[infoDic objectForKey:@"ItemType"] integerValue] == itemType) {
            return infoDic;
        }
    }
        return nil;
}

- (BOOL)hasExpandItemForType:(QIMTextBarExpandViewItemType)itemType
{
    for (NSDictionary * infoDic in _textBarButtonList) {
        if ([[infoDic objectForKey:@"ItemType"] integerValue] == itemType) {
            return YES;
        }
    }
    return NO;
}

@end
