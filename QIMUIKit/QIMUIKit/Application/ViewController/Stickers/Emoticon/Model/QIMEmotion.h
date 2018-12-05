//
//  QIMEmotion.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    EmotionStateDownload = 0, //下载
    EmotionStateUpdate,       //更新
    EmotionStateDone,         //已下载
} EmotionState;

@interface QIMEmotion : NSObject

/**
 表情包描述
 */
@property (nonatomic, copy) NSString *desc;

/**
 表情包fileUrl
 */
@property (nonatomic, copy) NSString *file;

/**
 表情包文件大小
 */
@property (nonatomic, assign) NSNumber *file_size;

/**
 表情包md5
 */
@property (nonatomic, copy) NSString *md5;

/**
 表情包name
 */
@property (nonatomic, copy) NSString *name;

/**
 表情包pkgid
 */
@property (nonatomic, copy) NSString *pkgid;

/**
 表情包展示图thumbUrl
 */
@property (nonatomic, copy) NSString *thumb;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
