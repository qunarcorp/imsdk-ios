//
//  QIMCollectionFaceManager.h
//  qunarChatIphone
//
//  Created by chenjie on 16/1/6.
//
//

#import "QIMCommonUIFramework.h"

#define kCollectionFaceListUpdateNotification @"kCollectionFaceListUpdateNotification"
#define kCollectionEmotionUpdateHandleFailedNotification @"kCollectionEmotionUpdateHandleFailedNotification"
#define kCollectionEmotionUpdateHandleSuccessNotification @"kCollectionEmotionUpdateHandleSuccessNotification"

#define CollectionFaceWidth 90
#define CollectionFaceHeight 90
typedef void (^ShowSmallBlock)(UIImage *showSmallImage);

@interface QIMCollectionFaceManager : NSObject

+ (id)sharedInstance;

@property (nonatomic, strong) NSMutableArray *collectionFaceList;

- (void) showSmallImage:(void(^)(UIImage *)) callback withIndex:(NSInteger)index;

- (void) showOriginImage:(void(^)(UIImage *)) callback withIndex:(NSInteger)index;

- (NSString *)getSmallEmojiLocalPathWithIndex: (NSInteger)index ;

- (NSString *)getCollectionFaceEmojiLocalPathWithIndex: (NSInteger)index;

- (NSString *)getCollectionFaceHttpUrlWithIndex: (NSInteger) index;

- (NSString *) getSmallEmojiImageNameAtPos:(NSInteger) index ;

- (NSString *) getOriginEmojiImageNameAtPos:(NSInteger) index;

- (NSInteger)countOfCollectionFaceListCount ;

- (NSArray *)getCollectionFaceList;

- (void)insertCollectionEmojiWithEmojiUrl:(NSString *)emojiUrl;

- (void)insertCollectionEmojiWithInfo:(NSDictionary *)info;

- (void) delCollectionFaceArr:(NSArray *)delAr;

- (void)delCollectionFaceImageWithFileName:(NSString *)fileName;

- (void)resetCollectionItems:(NSArray *)items WithUpdate:(BOOL)updateFlag;

- (void)updateConfig;

- (void)checkForUploadLocalCollectionFace;

- (void) replaceCollectionInfoWithIndex:(NSInteger )index NewInfo:(NSDictionary *)newInfo ;

@end
