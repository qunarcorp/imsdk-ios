//
//  QIMMyFavoitesManager.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 16/6/27.
//
//

#import "QIMMyFavoitesManager.h"

@interface QIMMyFavoitesManager ()

@end

static NSMutableArray *_myFavoritesArray = nil;
@implementation QIMMyFavoitesManager

+ (instancetype)sharedMyFavoritesManager {
    
    static QIMMyFavoitesManager *__myFavoriteManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __myFavoriteManager = [[QIMMyFavoitesManager alloc] init];
    });
    return __myFavoriteManager;
}

- (NSMutableArray *)myFavoritesArray {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _myFavoritesArray = [NSMutableArray arrayWithCapacity:10];
        NSString *path = [self getMyFavoritePath];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        [_myFavoritesArray addObjectsFromArray:array];
    });
    
    return _myFavoritesArray;
}

- (void)setMyFavoritesArrayWithMsg:(Message *)message {
    
    message.messageDirection = MessageDirection_Received;
    
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
    BOOL isContain = [self isContainWithMsg:messageData];
    if (isContain)
        return;
    else {
        
        NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:message];
        
        [self.myFavoritesArray addObject:messageData];
        [self saveMyFavoritesWithmyFavoritesArray];
    }

}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        _myFavoritesArray = [NSMutableArray arrayWithCapacity:10];
        
        NSString *path = [self getMyFavoritePath];
        NSArray *array = [NSArray arrayWithContentsOfFile:path];
        [_myFavoritesArray addObjectsFromArray:array];
        
    }
    return self;
}

- (BOOL)isContainWithMsg:(NSData *)messageData {
    
    //包含未读，不包含已读
    BOOL isContain = [self.myFavoritesArray containsObject:messageData];
    //YES 已读，NO未读
    return isContain;
}

- (NSString *)getMyFavoritePath {

    //判断Cache文件夹
    NSString *myFavoriteCachePath = [UserCachesPath stringByAppendingPathComponent:@"KMyFavorite"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:myFavoriteCachePath] == NO) {
        
        [[NSFileManager defaultManager] createDirectoryAtPath:myFavoriteCachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    //获取Voice文件路径
    NSString *myFavoriteSourcePath = [myFavoriteCachePath stringByAppendingPathComponent:@"myFavorite"];
    return myFavoriteSourcePath;
}

- (void)saveMyFavoritesWithmyFavoritesArray {
    
    
    [self.myFavoritesArray writeToFile:[self getMyFavoritePath] atomically:YES];
}

@end
