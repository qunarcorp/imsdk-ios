//
//  QIMNoteManager.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/13.
//
//

#import "QIMNoteManager.h"
#import "QIMNoteModel.h"
#import "QIMJSONSerializer.h"
#import "ASIHTTPRequest.h"
#import "QIMUUIDTools.h"
#import "NSMutableDictionary+QIMSafe.h"
#import "QIMKit+QIMDBDataManager.h"
#import "QIMKit+QIMUserCacheManager.h"
#import "QIMKit.h"
#import "QIMKit+QIMNavConfig.h"
#import "QIMKit+QIMMessage.h"
#import "QIMKit+QIMAppSetting.h"
#import "QIMKit+QIMEncryptChat.h"
#import "QIMNetwork.h"
#import "QIMPublicRedefineHeader.h"
#import "AESCrypt.h"
#import "QIMAES256.h"

@interface QIMNoteManager () {
    dispatch_queue_t _loadNoteModelQueue;
}

@property (nonatomic, assign) NSInteger passwordVersion;

@property (nonatomic, strong) NSMutableDictionary *passwordDict;

@property (nonatomic, strong) NSMutableDictionary *encryptPasswordDict;

@end

@interface QIMNoteManager (EverNoteAPI)

- (NSMutableDictionary *)requestHeaders;

#pragma mark - Main Remote API

- (void)saveToRemoteMainWithMainItem:(QIMNoteModel *)model;

- (void)updateToRemoteMainWithMainItem:(QIMNoteModel *)model;

- (void)deleteToRemoteMainWithQid:(NSInteger)qid;

- (void)collectToRemoteMainWithQid:(NSInteger)qid;

- (void)cancelCollectToRemoteMainWithQid:(NSInteger)qid;

- (void)moveToRemoteBasketMainWithQid:(NSInteger)qid;

- (void)moveOutRemoteBasketMainWithQid:(NSInteger)qid;

- (void)getCloudRemoteMainWithVersion:(NSInteger)version
                             WithType:(QIMNoteType)type;
- (void)getCloudRemoteMainHistoryWithQId:(NSInteger)qid;

- (void)batchSyncToRemoteMainItemsWithInserts:(NSArray *)inserts updates:(NSArray *)updates;

#pragma mark - Sub Remote API

- (void)saveToRemoteSubWithSubModel:(QIMNoteModel *)model;

- (void)updateToRemoteSubWithSubModel:(QIMNoteModel *)model;

- (void)deleteToRemoteSubWithQSid:(NSInteger)qsid;

- (void)collectionToRemoteSubWithQSid:(NSInteger)qsid;

- (void)cancelCollectionToRemoteSubWithQSid:(NSInteger)qsid;

- (void)moveToBasketRemoteSubWithQSid:(NSInteger)qsid;

- (void)moveOutRemoteBasketSubWithQSid:(NSInteger)qsid;

- (void)getCloudRemoteSubWithQid:(NSInteger)qid
                             Cid:(NSInteger)cid
                         version:(NSInteger)version
                            type:(QIMPasswordType)type;


- (NSArray *)getCloudRemoteSubHistoryWithQSid:(NSInteger)qsid;

- (void)batchSyncToRemoteSubItemsWithInserts:(NSArray *)inserts updates:(NSArray *)updates;

@end

@interface QIMNoteManager (EncryptMessageAPI)

- (void)receiveEncryptMessage:(NSDictionary *)infoDic;

@end

@implementation QIMNoteManager

+ (void)load {
    [QIMNoteManager sharedInstance];
}

static QIMNoteManager *__QIMNoteManager = nil;
+ (QIMNoteManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __QIMNoteManager = [[QIMNoteManager alloc] init];
    });
    return __QIMNoteManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.baseUrl = [[QIMKit sharedInstance] qimNav_QCloudHost];
        if (self.baseUrl.length <= 0) {
            self.baseUrl = @"https://qt.qunar.com/package/qtapi/qcloud/";
        }
        self.passwordVersion = [[[QIMKit sharedInstance] userObjectForKey:@"passwordVerison"] integerValue];
        self.passwordDict = [NSMutableDictionary dictionary];
        _loadNoteModelQueue = dispatch_queue_create("Load NoteModel Queue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveEncryptMessage:) name:@"kNotifyReceiveEncryptMessage" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCloudRemoteEncrypt) name:@"kNotifyNotificationGetRemoteEncrypt" object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString *)description {
    return @"QIMNoteManager";
}

- (NSString *)getPasswordWithCid:(NSInteger)cid {
    return [_passwordDict objectForKey:@(cid)];
}

- (void)setPassword:(NSString *)password ForCid:(NSInteger)cid{
    if (_passwordDict == nil) {
        _passwordDict = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    if (password && cid) {
        [_passwordDict setObject:password forKey:@(cid)];
    }
    if (password == nil) {
        [_passwordDict removeObjectForKey:@(cid)];
    }
}

- (void)setEncryptChatPasswordWithPassword:(NSString *)password ForUserId:(NSString *)userId {
    if (_encryptPasswordDict == nil) {
        _encryptPasswordDict = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    if (_encryptPasswordDict && userId && password) {
        [_encryptPasswordDict setObject:password forKey:userId];
    }
    if (password == nil && userId) {
        [_encryptPasswordDict removeObjectForKey:userId];
    }
}

- (NSString *)getEncryptChatPasswordWithUserId:(NSString *)userId {
    return [_encryptPasswordDict objectForKey:userId];
}

/***************************Main Local****************************/

/**
 保存新MainItem
 */
- (void)saveNewQTNoteMainItem:(QIMNoteModel *)model {
    
    [[QIMKit sharedInstance] insertQTNotesMainItemWithQId:model.q_id WithCid:model.c_id WithQType:model.q_type WithQTitle:model.q_title WithQIntroduce:model.q_introduce WithQContent:model.q_content WithQTime:model.q_time WithQState:model.q_state WithQExtendedFlag:QIMNoteExtendedFlagStateLocalCreated];
    [self saveToRemoteMainWithMainItem:model];
}

/**
 更新mainItem
 */
- (void)updateQTNoteMainItemWithModel:(QIMNoteModel *)model {
    QIMNoteExtendedFlagState exFlagState = QIMNoteExtendedFlagStateLocalModify;
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
        exFlagState = QIMNoteExtendedFlagStateLocalCreated;
    }
    [[QIMKit sharedInstance] updateToMainWithQId:model.q_id WithCid:model.c_id WithQType:model.q_type WithQTitle:model.q_title WithQDescInfo:model.q_introduce WithQContent:model.q_content WithQTime:model.q_time WithQState:model.q_state WithQExtendedFlag:exFlagState];
    [self updateToRemoteMainWithMainItem:model];
}

/**
 删除MainItem
 */
- (void)deleteQTNoteMainItemWithModel:(QIMNoteModel *)model {
    [self deleteToRemoteMainWithQid:model.q_id];
}

/**
 更新MainItem状态值
 */
- (void)updateQTNoteMainItemStateWithModel:(QIMNoteModel *)model {
    QIMNoteExtendedFlagState exFlagState = QIMNoteExtendedFlagStateLocalModify;
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
        exFlagState = QIMNoteExtendedFlagStateLocalCreated;
    }
    [[QIMKit sharedInstance] updateMainStateWithQid:model.q_id WithCid:model.c_id WithQState:model.q_state WithQExtendedFlag:exFlagState];
    if (model.q_state == QIMNoteStateFavorite) {
        [self collectToRemoteMainWithQid:model.q_id];
    } else if (model.q_state == QIMNoteStateBasket) {
        [self moveToRemoteBasketMainWithQid:model.q_id];
    } else if (model.q_state == QIMNoteStateDelete) {
        [self deleteToRemoteMainWithQid:model.q_id];
    } else if (model.q_state == QIMNoteStateNormal) {
        [self cancelCollectToRemoteMainWithQid:model.q_id];
        [self moveOutRemoteBasketMainWithQid:model.q_id];
    }
}

/**
 根据关键词搜索MainItem
 */
- (NSArray *)getMainItemWithType:(QIMNoteType)type Keywords:(NSString *)keyWords {
    NSArray *array = [[QIMKit sharedInstance] getQTNotesMainItemWithQType:type QString:keyWords];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getMainItemWithType:(QIMNoteType)type WithExceptState:(QIMNoteState)state {
    
    NSArray *array = [[QIMKit sharedInstance] getQTNotesMainItemWithQType:type WithExceptQState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getMainItemWithType:(QIMNoteType)type State:(QIMNoteState)state {
    
    NSArray *array = [[QIMKit sharedInstance] getQTNotesMainItemWithQType:type WithQState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}


- (NSArray *)getMainItemWithQExtendedFlag:(QIMNoteExtendedFlagState)qExtendedFlag {
    NSArray *array = [[QIMKit sharedInstance] getQTNotesMainItemWithQExtendFlag:qExtendedFlag];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}


- (NSInteger)getMaxQTNoteMainItemCid {
    return [[QIMKit sharedInstance] getMaxQTNoteMainItemCid];
}

- (NSInteger)getQTNoteMainItemMaxTimeWithType:(QIMNoteType)type {
    return [[QIMKit sharedInstance] getQTNoteMainItemMaxTimeWithQType:type];
}

- (NSInteger)getQTNoteSubItemMaxTimeWitModel:(QIMNoteModel *)model {
    return [[QIMKit sharedInstance] getQTNoteSubItemMaxTimeWithCid:model.c_id WithQSType:model.q_type];
}

- (NSArray *)getTodoListItemWithCompleteState:(NSString *)completeState {
    NSArray *array = [[QIMKit sharedInstance] getQTNoteMainItemWithQType:QIMNoteTypeTodoList WithQDescInfo:completeState];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (void)batchSyncToRemoteMainItems {
    NSArray *needInserts = [[QIMKit sharedInstance] getQTNotesMainItemWithQExtendedFlag:1 needConvertToString:YES];
    NSArray *needUpdates = [[QIMKit sharedInstance] getQTNotesMainItemWithQExtendedFlag:2 needConvertToString:YES];
    if (needInserts.count || needUpdates.count) {
        [self batchSyncToRemoteMainItemsWithInserts:needInserts updates:needUpdates];
    }
}

#pragma mark - Sub Local

- (void)saveNewQTNoteSubItem:(QIMNoteModel *)model {
    if (model.cs_id < 1) {
        model.cs_id = [[QIMKit sharedInstance] getMaxQTNoteSubItemCSid] + 1;
    }
    if (model.qs_time <= 0) {
        model.qs_time = [NSDate timeIntervalSinceReferenceDate];
    }
    [[QIMKit sharedInstance] insertQTNotesSubItemWithCId:model.c_id WithQSId:0 WithCSId:model.cs_id WithQSType:model.qs_type WithQSTitle:model.qs_title WithQSIntroduce:model.qs_introduce WithQSContent:model.qs_content WithQSTime:model.qs_time WithQState:model.qs_state WithQS_ExtendedFlag:QIMNoteExtendedFlagStateLocalCreated];
    QIMVerboseLog(@"saveNewQTNoteSubItem == %@", model);
    
    [self saveToRemoteSubWithSubModel:model];
}

- (void)updateQTNoteSubItemWithQSModel:(QIMNoteModel *)model {
    QIMNoteExtendedFlagState exFlagState = QIMNoteExtendedFlagStateLocalModify;
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
        exFlagState = QIMNoteExtendedFlagStateLocalCreated;
    }
    QIMVerboseLog(@"updateQTNoteSubItemWithQSModel == %@", model);
    [[QIMKit sharedInstance] updateToSubWithCid:model.c_id WithQSid:model.qs_id WithCSid:model.cs_id WithQSTitle:model.qs_title WithQSDescInfo:model.qs_introduce WithQSContent:model.qs_content WithQSTime:model.qs_time WithQSState:model.qs_state WithQS_ExtendedFlag:exFlagState];
    [self updateToRemoteSubWithSubModel:model];
}

- (void)deleteQTNoteSubItemWithQSModel:(QIMNoteModel *)model {
    
    [[QIMKit sharedInstance] deleteToSubWithCSId:model.cs_id];
    //[[QIMKit sharedInstance] deleteToSubWithCId:model.c_id];
    [self deleteToRemoteSubWithQSid:model.qs_id];
}

- (void)updateQTNoteSubItemStateWithQSModel:(QIMNoteModel *)model {
    QIMNoteExtendedFlagState exFlagState = QIMNoteExtendedFlagStateLocalModify;
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
        exFlagState = QIMNoteExtendedFlagStateLocalCreated;
    }
    [[QIMKit sharedInstance] updateSubStateWithCSId:model.cs_id WithQSState:model.qs_state WithQsExtendedFlag:exFlagState] ;
    if (model.qs_state == QIMNoteStateFavorite) {
        [self collectionToRemoteSubWithQSid:model.qs_id];
    } else if (model.qs_state == QIMNoteStateBasket) {
        [self moveToBasketRemoteSubWithQSid:model.qs_id];
    } else if (model.qs_state == QIMNoteStateDelete) {
        [self deleteToRemoteSubWithQSid:model.qs_id];
    } else if (model.qs_state == QIMNoteStateNormal) {
        [self cancelCollectionToRemoteSubWithQSid:model.qs_id];
        [self moveOutRemoteBasketSubWithQSid:model.qs_id];
    }
}

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithQSExtendedFlag:(QIMNoteExtendedFlagState)qsExtendedFlag {
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid QSExtendedFlag:qsExtendedFlag];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithQSExtendedFlag:(QIMNoteExtendedFlagState)qsExtendedFlag {
//    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithQSExtendedFlag:qsExtendedFlag needConvertToString:YES];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
//    for (NSDictionary *dict in array) {
//        QIMNoteModel *model = [[QIMNoteModel alloc] init];
//        [model setValuesForKeysWithDictionary:dict];
//    }
    return models;
}

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithType:(QIMNoteType)type WithQState:(QIMNoteState)state {
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid WithQSType:type WithQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithType:(QIMNoteType)type WithExpectState:(QIMNoteState)state {
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid WithQSType:type WithExpectQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithState:(QIMNoteState)state{
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid WithQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithCid:(NSInteger)cid WithExpectState:(QIMNoteState)state{
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid WithExpectQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithState:(QIMNoteState)state {
    
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}

- (NSArray *)getSubItemWithExpectState:(QIMNoteState)state {
    
    NSArray *array = [[QIMKit sharedInstance] getQTNotesSubItemWithExpectQSState:state];
    NSMutableArray *models = [NSMutableArray arrayWithCapacity:5];
    for (NSDictionary *dict in array) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}


/**
 取子项Model

 @param paramDict 查询的参数列表 ，务必对应数据库表结构 AND 条件语句
 @return 查询出来的Model
 */
- (QIMNoteModel *)getQTNoteSubItemWithParmDict:(NSDictionary *)paramDict {
    NSDictionary *subModelDict = [[QIMKit sharedInstance] getQTNoteSubItemWithParmDict:paramDict];
    if (subModelDict.count > 0) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        [model setValuesForKeysWithDictionary:subModelDict];
        return model;
    }
    return [[QIMNoteModel alloc] init];
}

- (NSInteger)getMaxQTNoteSubItemCSid {
    return [[QIMKit sharedInstance] getMaxQTNoteSubItemCSid];
}

- (void)batchSyncToRemoteSubItemsWithMainQid:(NSString *)qid {
    NSArray *needInserts = [[QIMKit sharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:QIMNoteExtendedFlagStateLocalCreated needConvertToString:YES];
    NSArray *needUpdates = [[QIMKit sharedInstance] getQTNotesSubItemWithMainQid:qid WithQSExtendedFlag:QIMNoteExtendedFlagStateLocalModify needConvertToString:YES];
    [self batchSyncToRemoteSubItemsWithInserts:needInserts updates:needUpdates];
}

@end

@implementation QIMNoteManager (EverNoteAPI)

- (NSMutableDictionary *)requestHeaders {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    BOOL debug = [[[QIMKit sharedInstance] userObjectForKey:@"QC_Debug"] boolValue];
    NSString *requesTHeaders = [NSString stringWithFormat:@"p_user=%@;q_ckey=%@", [QIMKit getLastUserName], [[QIMKit sharedInstance] thirdpartKeywithValue]];
    if (debug) {
        [cookieProperties setObject:requesTHeaders forKey:@"Cookie"];
    } else {
        [cookieProperties setObject:requesTHeaders forKey:@"Cookie"];
    }
    return cookieProperties;
}

#pragma mark - Main Remote API

- (void)saveToRemoteMainWithMainItem:(QIMNoteModel *)model {
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateNoNeedUpdatedd) {
        return ;
    }
    QIMNoteType type = model.q_type;
    NSString *title = model.q_title ? model.q_title : @"";
    NSString *desc = model.q_introduce ? model.q_introduce : @"";
    NSString *content = model.q_content ? model.q_content : @"";
    NSString *urlStr = [NSString stringWithFormat:@"%@saveToMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"type": @(type), @"title":title?title:@"", @"desc":desc?desc:@"", @"content":content?content:@""};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([infoDic objectForKey:@"ret"] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *data = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger qid = [[data objectForKey:@"qid"] integerValue];
                NSInteger version = [[data objectForKey:@"version"] integerValue];
                
                [[QIMKit sharedInstance] updateToMainWithQId:qid WithCid:model.c_id WithQType:type WithQTitle:title WithQDescInfo:desc WithQContent:content WithQTime:version WithQState:model.q_state WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)updateToRemoteMainWithMainItem:(QIMNoteModel *)model {
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateNoNeedUpdatedd) {
        return ;
    }
    NSInteger qid = model.q_id;
    NSString *title = model.q_title ? model.q_title : @"";
    NSString *desc = model.q_introduce ? model.q_introduce : @"";
    NSString *content = model.q_content ? model.q_content : @"";
    NSString *urlStr = [NSString stringWithFormat:@"%@updateMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid), @"title": title?title:@"", @"desc":desc?desc:@"", @"content":content?content:@""};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToMainItemTimeWithQId:resultQid WithQTime:version WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

/*
 {
 data =     {
 qid = 39;
 version = 1500478329217;
 };
 errcode = 0;
 errmsg = "<null>";
 ret = 1;
 }
 */
- (void)deleteToRemoteMainWithQid:(NSInteger)qid {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@deleteMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] deleteToMainWithQid:resultQid];
            }
        }
    }
}

- (void)collectToRemoteMainWithQid:(NSInteger)qid {

    NSString *urlStr = [NSString stringWithFormat:@"%@collectionMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToMainItemTimeWithQId:resultQid WithQTime:version WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)cancelCollectToRemoteMainWithQid:(NSInteger)qid {
    NSString *urlStr = [NSString stringWithFormat:@"%@cancelCollectionMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToMainItemTimeWithQId:resultQid WithQTime:version WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)moveToRemoteBasketMainWithQid:(NSInteger)qid {

    NSString *urlStr = [NSString stringWithFormat:@"%@moveToBasketMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToMainItemTimeWithQId:resultQid WithQTime:version WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)moveOutRemoteBasketMainWithQid:(NSInteger)qid {

    NSString *urlStr = [NSString stringWithFormat:@"%@moveOutBasketMain.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToMainItemTimeWithQId:resultQid WithQTime:version WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)getCloudRemoteMainWithVersion:(NSInteger)version
                             WithType:(QIMNoteType)type{
    NSString *urlStr = [NSString stringWithFormat:@"%@getCloudMain.qunar",self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];
    
    NSDictionary *paramDict = @{@"version": @(version), @"type":@(type)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:url];
    [request setHTTPMethod:QIMHTTPMethodPOST];
    [request setHTTPRequestHeaders:[self requestHeaders]];
    [request setHTTPBody:data];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:nil];
                if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
                    NSArray *resultArray = [infoDic objectForKey:@"data"];
                    if (data && ![data isKindOfClass:[NSNull class]]) {
                        for (NSDictionary *dict in resultArray) {
                            NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                            NSInteger resultType = [[dict objectForKey:@"type"] integerValue];
                            NSString *resultTitle = [dict objectForKey:@"title"];
                            NSString *resultDesc = [dict objectForKey:@"desc"];
                            NSString *resultContent = [dict objectForKey:@"content"];
                            NSInteger resultVersion = [[dict objectForKey:@"version"] integerValue];
                            NSInteger resultState = [[dict objectForKey:@"state"] integerValue];
                            if ([[QIMKit sharedInstance] checkExitsMainItemWithQid:resultQid WithCId:0]) {
                                [[QIMKit sharedInstance] updateToMainWithQId:resultQid WithCid:0 WithQType:resultType WithQTitle:resultTitle WithQDescInfo:resultDesc WithQContent:resultContent WithQTime:resultVersion WithQState:resultState WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
                            } else {
                                [[QIMKit sharedInstance] insertQTNotesMainItemWithQId:resultQid WithCid:0 WithQType:resultType WithQTitle:resultTitle WithQIntroduce:resultDesc WithQContent:resultContent WithQTime:resultVersion WithQState:resultState WithQExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
                            }
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[NSNotificationCenter defaultCenter] postNotificationName:QTNoteManagerGetCloudMainSuccessNotification object:nil];
                            });
                        }
                    }
                }
            });
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)getCloudRemoteMainHistoryWithQId:(NSInteger)qid{
    __block NSMutableArray *result = nil;
    NSString *urlStr = [NSString stringWithFormat:@"%@getCloudMainHistory.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];
    dispatch_async(_loadNoteModelQueue, ^{

        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:[self requestHeaders]];
        NSDictionary *paramDict = @{@"qid": @(qid)};
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
        [request appendPostData:data];
        [request startSynchronous];
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error ) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
                NSArray *resultArray = [infoDic objectForKey:@"data"];
                if (data && ![data isKindOfClass:[NSNull class]]) {
                    if (!result) {
                        result = [NSMutableArray arrayWithCapacity:3];
                    }
                    for (NSDictionary *dict in resultArray) {
                        QIMNoteModel *model = [[QIMNoteModel alloc] init];
                        [model setValuesForKeysWithDictionary:dict];
                        [result addObject:model];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:QTNoteManagerGetCloudMainHistorySuccessNotification object:nil];
                    });
                }
            }
        }
    });
}

- (void)batchSyncToRemoteMainItemsWithInserts:(NSArray *)inserts updates:(NSArray *)updates {
    NSString *urlStr = [NSString stringWithFormat:@"%@syncCloudMainList.qunar", self.baseUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"insert": inserts.count ? inserts : @[], @"update":updates.count ? updates : @[]};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSArray *resultArray = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                [[QIMKit sharedInstance] updateToMainItemWithDicts:resultArray];
            }
        }
    }
}


#pragma mark - Sub Remote API

- (void)saveToRemoteSubWithSubModel:(QIMNoteModel *)model{
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateNoNeedUpdatedd) {
        return ;
    }
    QIMNoteModel *mainModel = [[QIMNoteModel alloc] init];
    NSDictionary *mainModelDict = [[QIMKit sharedInstance] getQTNotesMainItemWithCid:model.c_id];
    [mainModel setValuesForKeysWithDictionary:mainModelDict];
    QIMVerboseLog(@"mainModel == %@", mainModel);
    
    NSInteger qid = mainModel.q_id;
    QIMPasswordType type = model.qs_type;
    NSString *title = model.qs_title;
    NSString *descInfo = model.qs_introduce;
    NSString *content = model.qs_content;
    NSString *urlStr = [NSString stringWithFormat:@"%@saveToSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qid": @(qid), @"type": @(type), @"title": title ? title : @"", @"desc": descInfo ? descInfo : @"", @"content" : content ? content : @""};
    QIMVerboseLog(@"paramDict == %@", paramDict);
    QIMVerboseLog(@"%@", url);
    QIMVerboseLog(@"%@", [self requestHeaders]);
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        QIMVerboseLog(@"infoDic == %@", infoDic);
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger qsid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger versioin = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubWithCid:model.c_id WithQSid:qsid WithCSid:model.cs_id WithQSTitle:model.qs_title WithQSDescInfo:model.qs_introduce WithQSContent:model.qs_content WithQSTime:versioin WithQSState:model.qs_state WithQS_ExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:QTNoteManagerSaveCloudMainSuccessNotification object:nil];
                });
            }
        }
    }
}

- (void)updateToRemoteSubWithSubModel:(QIMNoteModel *)model {
    if (model.q_ExtendedFlag == QIMNoteExtendedFlagStateNoNeedUpdatedd) {
        return ;
    }
    NSInteger qsid = model.qs_id;
    QIMPasswordType type = model.qs_type;
    NSString *title = model.qs_title;
    NSString *descInfo = model.qs_introduce;
    NSString *content = model.qs_content;
    NSString *urlStr = [NSString stringWithFormat:@"%@updateSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid), @"type": @(type), @"title": title ? title : @"", @"desc": descInfo ? descInfo : @"", @"content" : content ? content : @""};
    QIMVerboseLog(@"paramDict == %@", paramDict);
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQSid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubItemTimeWithCSId:version WithQSTime:resultQSid WithQsExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)deleteToRemoteSubWithQSid:(NSInteger)qsid {
//    deleteSub.qunar
    NSString *urlStr = [NSString stringWithFormat:@"%@deleteSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
//            NSDictionary *dict = [infoDic objectForKey:@"data"];
        }
    }
}

- (void)collectionToRemoteSubWithQSid:(NSInteger)qsid {

    NSString *urlStr = [NSString stringWithFormat:@"%@collectionSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQSid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubItemTimeWithCSId:version WithQSTime:resultQSid WithQsExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)cancelCollectionToRemoteSubWithQSid:(NSInteger)qsid {

    NSString *urlStr = [NSString stringWithFormat:@"%@cancelCollectionSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQsid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubItemTimeWithCSId:resultQsid WithQSTime:version WithQsExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)moveToBasketRemoteSubWithQSid:(NSInteger)qsid {

    NSString *urlStr = [NSString stringWithFormat:@"%@moveToBasketSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQSid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubItemTimeWithCSId:resultQSid WithQSTime:version WithQsExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)moveOutRemoteBasketSubWithQSid:(NSInteger)qsid {

    NSString *urlStr = [NSString stringWithFormat:@"%@moveOutBasketSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];

    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"qsid": @(qsid)};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSDictionary *dict = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                NSInteger resultQSid = [[dict objectForKey:@"qsid"] integerValue];
                NSInteger version = [[dict objectForKey:@"version"] integerValue];
                [[QIMKit sharedInstance] updateToSubItemTimeWithCSId:resultQSid WithQSTime:version WithQsExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];
            }
        }
    }
}

- (void)getCloudRemoteSubWithQid:(NSInteger)qid
                             Cid:(NSInteger)cid
                         version:(NSInteger)version
                            type:(QIMPasswordType)type {
    NSString *urlStr = [NSString stringWithFormat:@"%@getCloudSub.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];
    dispatch_async(_loadNoteModelQueue, ^{

        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:[self requestHeaders]];
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
        [paramDic setQIMSafeObject:@(version) forKey:@"version"];
        [paramDic setQIMSafeObject:@(qid) forKey:@"qid"];
        if (type != -1) {
            [paramDic setQIMSafeObject:@(type) forKey:@"type"];
        }
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDic error:nil];
        [request appendPostData:data];
        [request startSynchronous];
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error ) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
                NSArray *resultArray = [infoDic objectForKey:@"data"];
                if (data && ![data isKindOfClass:[NSNull class]]) {
                    for (NSDictionary *dict in resultArray) {
                        NSInteger resultQid = [[dict objectForKey:@"qid"] integerValue];
                        NSInteger resultQsid = [[dict objectForKey:@"qsid"] integerValue];
                        NSString *resultTitle = [dict objectForKey:@"title"];
                        NSInteger resultType = [[dict objectForKey:@"type"] integerValue];
                        NSString *resultContent = [dict objectForKey:@"content"];
                        NSString *resultDesc = [dict objectForKey:@"desc"];
                        NSInteger resultState = [[dict objectForKey:@"state"] integerValue];
                        NSInteger resultVersion = [[dict objectForKey:@"version"] integerValue];
                        
                        QIMNoteModel *model = [self getQTNoteSubItemWithParmDict:@{@"qs_id" : @(resultQsid)}];
                        [[QIMKit sharedInstance] insertQTNotesSubItemWithCId:cid WithQSId:resultQsid WithCSId:model.cs_id WithQSType:resultType WithQSTitle:resultTitle WithQSIntroduce:resultDesc WithQSContent:resultContent WithQSTime:resultVersion WithQState:resultState WithQS_ExtendedFlag:QIMNoteExtendedFlagStateRemoteUpdated];

                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:QTNoteManagerGetCloudSubSuccessNotification object:nil];
                        });
                    }
                }
            }
        }
    });
}


- (NSArray *)getCloudRemoteSubHistoryWithQSid:(NSInteger)qsid {

    __block NSMutableArray *result = nil;
    NSString *urlStr = [NSString stringWithFormat:@"%@getCloudSubHistory.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];
    dispatch_async(_loadNoteModelQueue, ^{

        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setUseCookiePersistence:NO];
        [request setRequestHeaders:[self requestHeaders]];
        NSDictionary *paramDict = @{@"qsid": @(qsid)};
        NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
        [request appendPostData:data];
        [request startSynchronous];
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error ) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
                NSArray *resultArray = [infoDic objectForKey:@"data"];
                if (data && ![data isKindOfClass:[NSNull class]]) {
                    if (!result) {
                        result = [NSMutableArray arrayWithCapacity:3];
                    }
                    for (NSDictionary *dict in resultArray) {
                        QIMNoteModel *model = [[QIMNoteModel alloc] init];
                        [model setValuesForKeysWithDictionary:dict];
                        [result addObject:model];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:QTNoteManagerGetCloudSubHistorySuccessNotification object:nil];
                    });
                }
            }
        }
    });
    return result;
}

- (void)batchSyncToRemoteSubItemsWithInserts:(NSArray *)inserts updates:(NSArray *)updates {
    NSString *urlStr = [NSString stringWithFormat:@"%@syncCloudSubList.qunar", self.baseUrl];
    __block NSURL *url = [NSURL URLWithString:urlStr];
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setUseCookiePersistence:NO];
    [request setRequestHeaders:[self requestHeaders]];
    NSDictionary *paramDict = @{@"insert": inserts.count ? inserts : @[], @"update":updates.count ? updates : @[]};
    NSData *data = [[QIMJSONSerializer sharedInstance] serializeObject:paramDict error:nil];
    [request appendPostData:data];
    [request startSynchronous];
    NSError *error = [request error];
    if (([request responseStatusCode] == 200) && !error ) {
        NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
        if ([[infoDic objectForKey:@"ret"] integerValue] && [[infoDic objectForKey:@"errcode"] integerValue] == 0) {
            NSArray *resultArray = [infoDic objectForKey:@"data"];
            if (data && ![data isKindOfClass:[NSNull class]]) {
                [[QIMKit sharedInstance] updateToSubItemWithDicts:resultArray];
            }
        }
    }
}

@end

@implementation QIMNoteManager (EncryptMessage)

- (void)receiveEncryptMessage:(NSNotification *)notify {
    NSDictionary *infoDic = notify.object;
    int type = [[infoDic objectForKey:@"type"] intValue];
    NSString *from = [infoDic objectForKey:@"from"];
    BOOL carbon = [[infoDic objectForKey:@"carbon"] boolValue];
    QIMVerboseLog(@"receiveEncryptMessage : %@", infoDic);
    switch (type) {
        case QIMEncryptMessageType_Begin:
        {
            if (carbon != YES) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyBeginEncryptChat object:from userInfo:infoDic];
                });
            }
        }
        break;
        case QIMEncryptMessageType_Agree:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyAgreeEncryptChat object:from userInfo:infoDic];
            });
        }
        break;
        case QIMEncryptMessageType_Refuse:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyRefuseEncryptChat object:from userInfo:infoDic];
            });
        }
        break;
        case QIMEncryptMessageType_Cancel:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCancelEncryptChat object:from userInfo:infoDic];
            });
        }
        break;
        case QIMEncryptMessageType_Close:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyCloseEncryptChat object:from userInfo:infoDic];
            });
        }
        break;
        default:
        break;
    }
}
    
/**
 开始加密会话请求

 @param userId 用户Id
 @param password 加密会话的密码
 */
- (void)beginEncryptionSessionWithUserId:(NSString *)userId
                            WithPassword:(NSString *)password {
    NSDictionary *dict =  @{@"type":@(1),@"pwd":password};
    NSString *passwordBody = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
    [[QIMKit sharedInstance] sendEncryptionChatWithType:QIMEncryptMessageType_Begin WithBody:passwordBody ToJid:userId];
}
    
/**
 同意加密会话请求
 
 @param userId 用户Id
 */
- (void)agreeEncryptSessionWithUserId:(NSString *)userId {
    [[QIMKit sharedInstance] sendEncryptionChatWithType:QIMEncryptMessageType_Agree WithBody:@"同意" ToJid:userId];
}
    
/**
 拒绝加密会话请求
 
 @param userId 用户Id
 */
- (void)refuseEncryptSessionWithUserId:(NSString *)userId {
    [[QIMKit sharedInstance] sendEncryptionChatWithType:QIMEncryptMessageType_Refuse WithBody:@"拒绝" ToJid:userId];
}
    
/**
 取消加密会话请求
 
 @param userId 用户Id
 */
- (void)cancelEncryptSessionWithUserId:(NSString *)userId {
    [[QIMKit sharedInstance] sendEncryptionChatWithType:QIMEncryptMessageType_Cancel WithBody:@"取消" ToJid:userId];
}
    
/**
 关闭加密会话
 
 @param userId 用户Id
 */
- (void)closeEncryptSessionWithUserId:(NSString *)userId {
    [[QIMKit sharedInstance] sendEncryptionChatWithType:QIMEncryptMessageType_Close WithBody:@"关闭" ToJid:userId];
}

- (void)getCloudRemoteEncrypt {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [[QIMNoteManager sharedInstance] getCloudRemoteMainWithVersion:0 WithType:QIMNoteTypeChatPwdBox];
        QIMNoteModel *pwdBox = [[QIMNoteManager sharedInstance] getEncrptPwdBox];
        [[QIMNoteManager sharedInstance] getCloudRemoteSubWithQid:pwdBox.q_id Cid:pwdBox.c_id version:0 type:QIMPasswordTypeText];
    });
}

- (QIMNoteModel *)getEncrptPwdBox {
    NSArray *pwdBoxs = [[QIMKit sharedInstance] getQTNotesMainItemWithQType:QIMNoteTypeChatPwdBox];
    if (pwdBoxs.count >= 1) {
        QIMNoteModel *model = [[QIMNoteModel alloc] init];
        NSDictionary *dict = [pwdBoxs objectAtIndex:0];
        [model setValuesForKeysWithDictionary:dict];
        return model;
    }
    return nil;
}

//根据UserId及本地Cid获取 加密会话的密码
-  (NSString *)getChatPasswordWithUserId:(NSString *)userId
                                 WithCid:(NSInteger)cid {
    
    //第一步：内存中获取UserId的加密会话密码
    NSString *memoryPwd = [self getEncryptChatPasswordWithUserId:userId];
    if (memoryPwd) {
        return memoryPwd;
    }
    //第二步：本地获取UserId的加密会话密码
    NSString *password = [self getLocalEncryptChatPasswordWithUserId:userId WithCid:cid];
    //第三步：网络获取UserId的加密会话密码
    if (!password) {
        [[QIMNoteManager sharedInstance] getCloudRemoteMainWithVersion:0 WithType:QIMNoteTypeChatPwdBox];
        QIMNoteModel *pwdBox = [[QIMNoteManager sharedInstance] getEncrptPwdBox];
        [[QIMNoteManager sharedInstance] getCloudRemoteSubWithQid:pwdBox.q_id Cid:pwdBox.c_id version:0 type:QIMPasswordTypeText];
        password =  [self getLocalEncryptChatPasswordWithUserId:userId WithCid:cid];
    }
    //第四步：本地新创建UserId的加密会话密码
    if (!password) {
        //获取内存中密码
        NSString *encrptChatPwd = [[QIMNoteManager sharedInstance] getEncryptChatPasswordWithUserId:userId];
        [self saveEncryptionPasswordWithUserId:userId WithPassword:(encrptChatPwd.length > 0) ? encrptChatPwd : [QIMUUIDTools UUID] WithCid:cid];
        password = [self getLocalEncryptChatPasswordWithUserId:userId WithCid:cid];
    }
    if (![self getEncryptChatPasswordWithUserId:userId]) {
        [self setEncryptChatPasswordWithPassword:password ForUserId:userId];
    }
    return password;
}

//获取本地数据库中的加密会话密码
- (NSString *)getLocalEncryptChatPasswordWithUserId:(NSString *)userId
                                            WithCid:(NSInteger)cid {
    NSString *password = nil;
    QIMNoteModel *model = [[QIMNoteModel alloc] init];
    NSDictionary *pwdDict = [[QIMKit sharedInstance] getQTNotesSubItemWithCid:cid WithUserId:userId];
    if (pwdDict) {
        [model setValuesForKeysWithDictionary:pwdDict];
        NSString *content = model.qs_content;
        if ([[QIMNoteManager sharedInstance] getPasswordWithCid:cid]) {
            NSString *contentJson = [AESCrypt decrypt:content password:[[QIMNoteManager sharedInstance] getPasswordWithCid:cid]];
            if (!contentJson) {
                contentJson = [QIMAES256 decryptForBase64:content password:[[QIMNoteManager sharedInstance] getPasswordWithCid:cid]];
            }
            NSDictionary *contentDic = [[QIMJSONSerializer sharedInstance] deserializeObject:contentJson error:nil];
            password = [contentDic objectForKey:@"P"];
        }
    }
    return password;
}

- (QIMNoteModel *)saveEncryptionPasswordWithUserId:(NSString *)userId
                                     WithPassword:(NSString *)password
                                          WithCid:(NSInteger)cid {
    NSMutableDictionary *contentDic = [NSMutableDictionary dictionary];
    if (userId) {
        [contentDic setObject:userId forKey:@"U"];
    }
    if (password) {
        [contentDic setObject:[NSString stringWithFormat:@"%@", password] forKey:@"P"];
    }
    NSString *contentJson =  [[QIMJSONSerializer sharedInstance] serializeObject:contentDic];
    NSString *content = [QIMAES256 encryptForBase64:contentJson password:[[QIMNoteManager sharedInstance] getPasswordWithCid:cid]];
    QIMNoteModel *model = [[QIMNoteModel alloc] init];
    model.qs_content = content;
    model.c_id = cid;
    model.qs_title = userId;
    model.qs_type = QIMPasswordTypeText;
    model.qs_introduce = @"加密会话密码";
    model.qs_state = QIMNoteStateNormal;
    [self saveNewQTNoteSubItem:model];
    return model;
}

@end
