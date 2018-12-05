//
//  QIMEmotionManager.h
//  qunarChatMac
//
//  Created by 平 薛 on 14-12-24.
//  Copyright (c) 2014年 May. All rights reserved.
//



#define kEmotionCollectionPKId                 @"kEmotionCollectionPKId"

#define KEmotionShortcutForNameKey             @"KEmotionShortcutForNameKey"
#define KEmotionImagePathForShortcutKey        @"KEmotionImagePathForShortcutKey"   //根据ShortCut找到表情半路径
#define KEmotionShortcutForImagePathKey        @"KEmotionShortcutForImagePathKey"
#define KEmotionTipNameForShortCutKey          @"KEmotionTipNameForShortCutKey"
#define KEmotionImagePathListKey               @"KEmotionImagePathListKey"          //表情半路径list

#define KEmotionPackageIdKey                   @"KEmotionPackageIdKey"
#define KEmotionPackageNameKey                 @"KEmotionPackageNameKey"
#define KEmotionPackageShowAllKey              @"KEmotionPackageShowAllKey"
#define KEmotionPackageSupportGraphicMixedKey  @"KEmotionPackageSupportGraphicMixedKey"
#define KEmotionPackageCoverImageKey           @"KEmotionPackageCoverImageKey"
#define KEmotionPackageVersionKey              @"KEmotionPackageVersionKey"

#define kEmotionListUpdateNotification         @"kEmotionListUpdateNotification"

#define kEmotionRemoveNotification             @"kEmotionRemoveNotification"

#import "QIMCommonUIFramework.h"

typedef enum {
    EmotionTypeDefault = 0,//qq
    EmotionTypeYahoo,
    EmotionTypeNiutuo,
    EmotionTypeEmojiOne,
    EmotionTypeEnd,
    EmotionTypeCollection,
} EmotionType;

typedef enum {
    EmotionListUpdate = 0,
    EmotionListDownload ,
    EmotionListRemove,
} EmotionListUpdateType;

#define FaceSize  43

@interface Emotion : NSObject

@property (nonatomic, strong) NSString *faceId;
@property (nonatomic, strong) NSString *shortcut;
@property (nonatomic, strong) NSString *tip;
@property (nonatomic, assign) int multiframe;
@property (nonatomic, strong) NSString *file_org;
@property (nonatomic, strong) NSString *orgpath;
@property (nonatomic, strong) NSString *file_fixed;

@end

@interface QIMEmotionManager : NSObject<NSXMLParserDelegate>

@property(nonatomic,assign)EmotionType      currentEmotionType;

@property(nonatomic,copy) NSString      * currentPackageId;

+ (instancetype)sharedInstance;

- (void)updateEmotions:(NSArray *)items;

- (UIImage *)getEmotionThumbIconWithImageStr:(NSString *)imageStr BySize:(CGSize)size;
- (NSData *)getEmotionThumbIconDataWithImageStr:(NSString *)imageStr;

//------------------------ new ---------------------

//获取所有的表情表列表（只有表情包id）
- (NSArray *)getEmotionPackageIdList;

//获取某表情包的name
- (NSString *)getEmotionPackageNameForPackageId:(NSString *)emotionPackageId;

//判断某表情包是否支持图文混排
- (BOOL)isEmotionPackageSupportGraphicMixedForPackageId:(NSString *)emotionPackageId;

//获取emotion image 绝对路径
- (NSString *)getImageAbsolutePathForRelativePath:(NSString *)path;

//获取某表情包的版本
- (NSString *)getEmotionPackageVersionForPackageId:(NSString *)emotionPackageId;

//获取某表情包的封面图path
- (NSString *)getEmotionPackageCoverImagePathForPackageId:(NSString *)emotionPackageId;

//获取某个表情包的详细信息（该套表情的所有相关信息都在这里）
- (NSDictionary *)getEmotionsInfoDicForPackageId:(NSString *)emotionPackageId;

//获取某个包中 shortcut 对应的 tip
- (NSString *)getEmotionTipNameForShortCut:(NSString *)shortCut withPackageId:(NSString *)emotionPackageId;

//获取某个包中 tip 对应的 shortcut
- (NSString *)getEmotionShortCutForTipName:(NSString *)tipName withPackageId:(NSString *)emotionPackageId;

//获取某个包中 表情图片path list
- (NSArray *)getEmotionImagePathListForPackageId:(NSString *)emotionPackageId;

//获取某个包中 shortcut 对应的 表情图片path
- (NSString *)getEmotionImagePathForShortCut:(NSString *)shortCut withPackageId:(NSString *)emotionPackageId;

//获取某个包中 表情图片path 对应的 shortcut
- (NSString *)getEmotionShortCutForImagePath:(NSString *)imagePath withPackageId:(NSString *)emotionPackageId;

//获取用户可下载的所有表情包信息
- (NSArray *)getHttpEmotions;

//下载表情包（新博接口）
- (void)downloadEmotionForPkId:(NSString *)pkId loadUrl:(NSString *)loadUrl;

//下载表情包（邵明星接口）
- (void)downloadEmotionForPkId:(NSString *)pkId fileName:(NSString *)fileName;

//删除表情包
- (void)removeEmotionPkgForPkId:(NSString *)pkId;

//http获取单个表情
- (void)getEmotionImageFromHttpForPkId:(NSString *)pkId shortcut:(NSString *)shortcut signKey:(NSString *)signKey;

@end

@interface QIMEmotionManager (DecodeHTMLURL)

- (NSString *)decodeHtmlUrlForText:(NSString *)text;
- (NSString *)decodeHtmlUrlForText:(NSString *)text WithFilterAppendArray:(NSArray *)paramDict;


@end
