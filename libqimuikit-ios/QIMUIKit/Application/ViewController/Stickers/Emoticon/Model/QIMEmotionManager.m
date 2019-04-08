//
//  QIMEmotionManager.m
//  qunarChatMac
//
//  Created by 平 薛 on 14-12-24.
//  Copyright (c) 2014年 May. All rights reserved.
//

#define kEmotionUpdateKey               @"emotionUpdateKey220"
#define kEmotionPathResource            @"emotionResource"
#define kEmotionsInfoFileName           @"kEmotionsInfoFileName"
#define kEmotionDispPkIdListFileName    @"kEmotionDispPkIdListFileName"
#define kEmotionAllPkIdListFileName     @"kEmotionAllPkIdListFileName"

#import "QIMEmotionManager.h"
#import "ZipArchive.h"
#import "QIMHTTPClient.h"
#import "QIMHTTPRequest.h"
#import "QIMJSONSerializer.h"

@interface Emotion () {
    BOOL _file_org_is_set;
    BOOL _file_fixed_is_set;
}

@end

@implementation Emotion

- (NSString *)shortcut {
    return [NSString stringWithFormat:@"[%@]",_shortcut];
}

+ (NSString *)highResImageWithBaseFileName:(NSString *) filePath withBasePath:(NSString *) basePath factor:(int) factor {
    //
    // 模拟苹果尝试搞更高分辨率的表情
    // 查看代码发现需要注意个问题：
    // 输入的有可能是半路径有可能是全路径，so 如果是全路径需要把basepath置空。
    // 后人优化吧。
    
    NSString *header = [filePath stringByDeletingPathExtension];
    NSString *ext = [filePath pathExtension];
    
    NSString *file2x = [NSString stringWithFormat:@"%@@%dx.%@", header, factor, ext];
    NSString *fullPath = basePath ? [basePath stringByAppendingPathComponent:file2x] : file2x;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        return file2x;
    } else {
        factor -= 1;
        if (factor > 1) {
            return [Emotion highResImageWithBaseFileName:filePath withBasePath:basePath factor:factor];
        } else {
            return filePath;
        }
    }
}

- (NSString *)file_org {
    
    if (!_file_org_is_set) {
        int scale = [[UIScreen mainScreen] scale];
        NSString *newpath = [Emotion highResImageWithBaseFileName:_file_org withBasePath:_orgpath factor:scale];
        if (![_file_org isEqualToString:newpath])
            _file_org = newpath;
        _file_org_is_set = YES;
    }
    return _file_org;
}

- (NSString *) file_fixed {
    if (!_file_fixed_is_set) {
        int scale = [[UIScreen mainScreen] scale];
        NSString *newpath = [Emotion highResImageWithBaseFileName:_file_fixed withBasePath:nil factor:scale];
        if (![_file_fixed isEqualToString:newpath])
            _file_fixed = newpath;
        _file_fixed_is_set = YES;
    }
    return _file_fixed;
    
}

- (void)dealloc{
    [self setFaceId:nil];
    [self setShortcut:nil];
    [self setTip:nil];
    [self setFile_org:nil];
    [self setFile_fixed:nil];
}

@end

@interface QIMEmotionManager ()

@property (nonatomic, strong) NSMutableArray *defaultEmotionList;               //表情包所有的半路径合集
@property (nonatomic, strong) NSMutableDictionary *defaultEmotionDic;           //表情包的ShortCut对应半路径，set Path -> ShortCut
@property (nonatomic, strong) NSMutableDictionary *shortcutForImagePathDic;     //表情包的ShortCut对应半路径，set Path -> ShortCut
@property (nonatomic, strong) NSMutableDictionary *defaultEmotionKeys;
@property (nonatomic, strong) NSMutableDictionary *defaultEmotionNameDic;       //表情包的Tip，set Tip -> ShortCut
@property (nonatomic, strong) NSMutableDictionary *defaultEmotionShorCutDic;    //表情包的shortCut，set ShortCut -> Tip

@property (nonatomic, strong) NSMutableArray *tempArray;

@property (nonatomic, copy) NSString *currentEmotionName;       //当前表情包Emotion名 （取自XML <DEFAULTFACE emotionName="EmojiOne"）

@property (nonatomic, assign) BOOL currentEmotionShowAll;      //当前表情包Emotion是否支持图文混皮 （取自XML <DEFAULTFACE showall="0"）
@property (nonatomic, assign) BOOL bNeedStore;

@property (nonatomic, strong) NSMutableDictionary *emotionThumbIconDic;
@property (nonatomic, strong) NSMutableArray *emotionDispPkIdList;          //表情包PkId列表
@property (nonatomic, strong) NSMutableDictionary *emotionsInfoDic;         //表情包的详细配置信息
@property (nonatomic, strong) NSMutableArray *emotionsInfoDicPathArray;

@property (nonatomic, strong) NSMutableArray *emotionAllPkIdList;
@property (nonatomic, strong) NSMutableArray *httpEmotions;

@property (nonatomic, copy) NSString *currentPrefixPath;

@end

@implementation QIMEmotionManager {
    dispatch_queue_t _emotionManagerQueue;
}

+ (instancetype)sharedInstance{
    
    static QIMEmotionManager *__global_emotion_manger = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __global_emotion_manger = [[QIMEmotionManager alloc] init];
    });
    if (!__global_emotion_manger) {
        __global_emotion_manger = [[QIMEmotionManager alloc] init];
    }
    return __global_emotion_manger;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        
        _emotionManagerQueue = dispatch_queue_create("Emotion Manager Queue", 0);
        
        dispatch_async(_emotionManagerQueue, ^{
            NSNumber * emotionUpdateKey = [[QIMKit sharedInstance] userObjectForKey:kEmotionUpdateKey];
            if (emotionUpdateKey == nil) {
                [[QIMKit sharedInstance] setUserObject:@(YES) forKey:kEmotionUpdateKey];
            }
            
            emotionUpdateKey = [[QIMKit sharedInstance] userObjectForKey:kEmotionUpdateKey];
            if ([emotionUpdateKey boolValue] == YES) {
                [[QIMKit sharedInstance] removeUserObjectForKey:@"EmojiOne"];
                // 判断cache文件夹
                NSString *outputPath = [UserCachesPath stringByAppendingPathComponent:@"ZIPArchive"];
                if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath] == YES){
                    [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
                }
            }
            _currentEmotionType = EmotionTypeEmojiOne;//默认
            
            BOOL reloadfromUrl = [[[QIMKit sharedInstance] userObjectForKey:@"emotion_check"] boolValue];
            if (reloadfromUrl) {
                [self getAndCheckEmotionsInfoFromHttp];
            }
        
            if (emotionUpdateKey.boolValue) {
                [[QIMKit sharedInstance] setUserObject:@(NO) forKey:kEmotionUpdateKey];
            }
            
            [self saveEmotionsToFileForFileName:kEmotionDispPkIdListFileName];
            
            [self getEmotionsFromFile];
            if (_emotionDispPkIdList.count > 1) {
                self.currentPackageId = _emotionDispPkIdList[1];
            }
        });
    }
    return self;
}

#pragma mark - setter and getter

- (NSMutableArray *)defaultEmotionList {
    if (!_defaultEmotionList) {
        _defaultEmotionList = [NSMutableArray arrayWithCapacity:3];
    }
    return _defaultEmotionList;
}

- (NSMutableDictionary *)defaultEmotionDic {
    if (!_defaultEmotionDic) {
        _defaultEmotionDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _defaultEmotionDic;
}

- (NSMutableDictionary *)shortcutForImagePathDic {
    if (!_shortcutForImagePathDic) {
        _shortcutForImagePathDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _shortcutForImagePathDic;
}

- (NSMutableDictionary *)defaultEmotionKeys {
    if (!_defaultEmotionKeys) {
        _defaultEmotionKeys = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _defaultEmotionKeys;
}

- (NSMutableDictionary *)defaultEmotionNameDic {
    if (!_defaultEmotionNameDic) {
        _defaultEmotionNameDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _defaultEmotionNameDic;
}

- (NSMutableDictionary *)defaultEmotionShorCutDic {
    if (!_defaultEmotionShorCutDic) {
        _defaultEmotionShorCutDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _defaultEmotionShorCutDic;
}

- (NSMutableArray *)tempArray {
    if (!_tempArray) {
        _tempArray = [NSMutableArray arrayWithCapacity:3];
    }
    return _tempArray;
}

- (NSMutableDictionary *)emotionThumbIconDic {
    if (!_emotionThumbIconDic) {
        _emotionThumbIconDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return _emotionThumbIconDic;
}

- (NSMutableArray *)emotionAllPkIdList {
    if (!_emotionAllPkIdList) {
        _emotionAllPkIdList = [NSMutableArray arrayWithCapacity:3];
    }
    return _emotionAllPkIdList;
}

- (NSMutableArray *)httpEmotions {
    if (!_httpEmotions) {
        _httpEmotions = [NSMutableArray arrayWithCapacity:3];
        [self getAndCheckEmotionsInfoFromHttp];
    }
    return _httpEmotions;
}

- (NSMutableDictionary *)emotionsInfoDic {
    if (!_emotionsInfoDic) {
        _emotionsInfoDic = [NSMutableDictionary dictionaryWithCapacity:5];
        [self loadEmotionInfoDic];
    }
    return _emotionsInfoDic;
}

- (NSMutableArray *)emotionDispPkIdList {
    if (!_emotionDispPkIdList) {
        _emotionDispPkIdList = [NSMutableArray arrayWithCapacity:5];
        [self getEmotionsFromFile];
    }
    return _emotionDispPkIdList;
}

- (NSMutableArray *)emotionsInfoDicPathArray {
    if (!_emotionsInfoDicPathArray) {
        _emotionsInfoDicPathArray = [NSMutableArray arrayWithCapacity:5];
    }
    return _emotionsInfoDicPathArray;
}

- (UIImage *)getEmotionThumbIconWithImageStr:(NSString *)imageStr BySize:(CGSize)size {
    if (imageStr == nil) {
        return nil;
    }
    UIImage *image = [_emotionThumbIconDic objectForKey:imageStr];
    if (image == nil) {
        UIImage *temp = [UIImage imageWithData:[self getEmotionThumbIconDataWithImageStr:imageStr]];
        UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
        [temp drawInRect:CGRectMake(0, 0, size.width, size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [_emotionThumbIconDic setQIMSafeObject:image forKey:imageStr];
    }
    return image;
}

- (NSData *)getEmotionThumbIconDataWithImageStr:(NSString *)imageStr {
    NSData *imageData = [NSData dataWithContentsOfFile:imageStr];
    return imageData;
}

- (void)parseXMLData:(NSData *)data {
    
//    QIMVerboseLog(@"解析XML数据");
     [self.defaultEmotionDic removeAllObjects];
     [self.defaultEmotionShorCutDic removeAllObjects];
     [self.defaultEmotionNameDic removeAllObjects];
     [self.defaultEmotionList removeAllObjects];
     
     //1.创建解析器
     NSXMLParser *parser=[[NSXMLParser alloc] initWithData:data];
     //2.设置代理
     parser.delegate=self;

     //3.开始解析
     [parser parse];
 
     self.bNeedStore = FALSE;
}


- (void)expandNormalZipFileNamed:(NSString *)fileName {
    if (fileName.length <= 0) {
        return;
    }
    // 判断cache文件夹
    NSString *outputPath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:fileName];
 
    if (![[QIMKit sharedInstance] userObjectForKey:fileName] || ![[NSFileManager defaultManager] fileExistsAtPath:[outputPath stringByAppendingString:[[[QIMKit sharedInstance] userObjectForKey:fileName] objectForKey:@"xmlFilePath"]] isDirectory:nil]) {
        NSString *inputPath=[[NSBundle mainBundle] pathForResource:fileName ofType:@"zip"];
        NSLog(@"EmotionInputPath : %@", inputPath);
        // 获取document文件夹位置
        
        ZipArchive* zip = [[ZipArchive alloc] init];
        [zip UnzipOpenFile:inputPath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath] == NO) {
            [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
        
        [zip UnzipFileTo:outputPath overWrite:YES];
        
        outputPath = [outputPath stringByAppendingString:@"/"];
        self.currentPrefixPath = [fileName stringByAppendingPathComponent:[[zip getZipFileContents] firstObject]];
        NSString * xmlPath = @"/";
        for (NSString * xmlFileName in [zip getZipFileContents]) {
            if ([xmlFileName hasSuffix:@".xml"]) {
                xmlPath = [xmlPath stringByAppendingString:xmlFileName];
                NSData * fileData = [NSData dataWithContentsOfFile:[outputPath stringByAppendingString:xmlFileName]];
                [self parseXMLData:fileData];
                break;
            }
        }
        [[QIMKit sharedInstance] setUserObject:[NSDictionary dictionaryWithObjectsAndKeys:xmlPath,@"xmlFilePath",[NSString stringWithFormat:@"/%@",[[zip getZipFileContents] firstObject]],@"imagePreFix", nil] forKey:fileName];
    } else{
        NSString * xmlPath = [outputPath stringByAppendingString:[[[QIMKit sharedInstance] userObjectForKey:fileName] objectForKey:@"xmlFilePath"]];
        NSData * fileData = [NSData dataWithContentsOfFile:xmlPath];
        if (fileData) {
//            QIMVerboseLog(@"expandNormalZipFileNamed : %@", self.currentPrefixPath);
//            QIMVerboseLog(@"expandNormalZipFileNamed FileName : %@ ===  %@", fileName, [[QIMKit sharedInstance] userObjectForKey:fileName]);
            self.currentPrefixPath = [[NSString stringWithFormat:@"%@",fileName] stringByAppendingPathComponent:[[[QIMKit sharedInstance] userObjectForKey:fileName] objectForKey:@"imagePreFix"]];
//            QIMVerboseLog(@"expandNormalZipFileNamed currentPrefixPath : %@", self.currentPrefixPath);
            [self parseXMLData:fileData];
        }
    }
}


#pragma mark - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
//     QIMVerboseLog(@"开始解析文档");
    [self.tempArray removeAllObjects];
//    QIMVerboseLog(@"开始解析文档 : %@", self.tempArray);
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
//    QIMVerboseLog(@"结束解析文档");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
     self.bNeedStore = FALSE;
     if ([elementName isEqualToString:@"DEFAULTFACE"] && [attributeDict count] > 0 ) {
         
        self.currentEmotionName = [attributeDict objectForKey:@"emotionName"];
        self.currentEmotionShowAll = [[attributeDict objectForKey:@"showall"] boolValue];
     }
     
    if ([elementName isEqualToString:@"FACE"] && [attributeDict count] > 0 ) {
         
        NSString * shortCut  =  [attributeDict objectForKey:@"shortcut"];
        NSString * tip = [attributeDict objectForKey:@"tip"];
        [self.tempArray removeAllObjects];
   
        if ([shortCut length] > 0) {
            
            [self.tempArray addObject:shortCut];
            
            [self.defaultEmotionNameDic setValue:tip forKey:shortCut];
            [self.defaultEmotionShorCutDic setQIMSafeObject:shortCut forKey:tip];
        }
    }
     
     if ([elementName isEqualToString:@"FILE_ORG"]) {
         self.bNeedStore = TRUE;
     } else {
         self.bNeedStore = FALSE;
     }
 }


- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (self.bNeedStore == TRUE) {

        if ([self.tempArray count] > 0) {
         
            NSString *value = [self.tempArray objectAtIndex:0];

            NSString *key = [self.tempArray objectAtIndex:1];

            int factor = [[UIScreen mainScreen] scale];
            NSString *newpath = [Emotion highResImageWithBaseFileName:key withBasePath:nil factor:factor];

            if (![key isEqualToString:newpath]) {
                 key = newpath;
                 self.tempArray[1] = key;
            }

            [self.defaultEmotionDic setQIMSafeObject:key forKey:value];
            [self.shortcutForImagePathDic setQIMSafeObject:value forKey:key];

            if ([self.defaultEmotionList containsObject:key] == NO) {

                [self.defaultEmotionList addObject:newpath];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.bNeedStore == TRUE) {
        NSMutableCharacterSet *doNotWant = [NSMutableCharacterSet controlCharacterSet];
        [doNotWant addCharactersInString:@" "];
        string = [string stringByTrimmingCharactersInSet:doNotWant];
        if (string.length > 0) {
            if (![[NSFileManager defaultManager] fileExistsAtPath:[_currentPrefixPath stringByAppendingString:string]]) {
//                QIMVerboseLog(@"Emotion Name Error {%@}",string);
            }
            [_tempArray addObject:[_currentPrefixPath stringByAppendingPathComponent:string]];
        }
    }
}

//------------------------ new ---------------------

- (void)loadEmotionInfoDic {
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // 获取emotionDispPackageIdList文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",kEmotionDispPkIdListFileName]];
    //获取所有emotionAllPackageIdList文件路径
    resourcePath = [cachePath stringByAppendingPathComponent:kEmotionAllPkIdListFileName];
    // 获取emotionsInfoFileName文件路径
    for (NSString * packageId in self.emotionDispPkIdList) {
        resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",packageId]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
        {
            [_emotionsInfoDic setQIMSafeObject:[NSMutableDictionary dictionaryWithContentsOfFile:resourcePath] forKey:packageId];
        }
    }
}

- (void)getEmotionsFromFile {
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    // 获取emotionDispPackageIdList文件路径
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",kEmotionDispPkIdListFileName]];
    {
        _emotionDispPkIdList = [NSMutableArray arrayWithContentsOfFile:resourcePath];
        if (_emotionDispPkIdList == nil) {
            _emotionDispPkIdList = [NSMutableArray arrayWithCapacity:1];
        }
        
        if (_emotionDispPkIdList.count == 0) {
            //传入需要内置的表情包PKID（需要将ZIP包倒入工程中）
            NSArray *initializePkIdList = @[@"qunar_camel", @"EmojiOne"];
            [self initializeDisplayPkIdList:initializePkIdList];
        }
    }
    //获取所有emotionAllPackageIdList文件路径
    resourcePath = [cachePath stringByAppendingPathComponent:kEmotionAllPkIdListFileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        _emotionAllPkIdList = [NSMutableArray arrayWithContentsOfFile:resourcePath];
        if (![_emotionAllPkIdList.firstObject isEqualToString:kEmotionCollectionPKId]) {
            [_emotionAllPkIdList insertObject:kEmotionCollectionPKId atIndex:0];
        }
    }
}

- (void)initializeDisplayPkIdList:(NSArray *)pkidList {
    
    for (NSString *pkId in pkidList) {
        if (pkId.length > 0) {
            [self expandNormalZipFileNamed:pkId];
            NSDictionary *emotionInfoDic = @{KEmotionImagePathForShortcutKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionDic],
                                             KEmotionShortcutForImagePathKey:[NSDictionary dictionaryWithDictionary:self.shortcutForImagePathDic],
                                             KEmotionShortcutForNameKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionShorCutDic],
                                             KEmotionTipNameForShortCutKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionNameDic],
                                             KEmotionImagePathListKey:[NSArray arrayWithArray:self.defaultEmotionList],
                                             KEmotionPackageNameKey:self.currentEmotionName,
                                             KEmotionPackageShowAllKey:@(self.currentEmotionShowAll)
                                             };
            [self.emotionsInfoDic setQIMSafeObject:emotionInfoDic forKey:pkId];
            [self saveEmotionsToFileForFileName:[NSString stringWithFormat:@"%@",pkId]];
            
            [self.emotionDispPkIdList addObject:pkId];
            
            [self.emotionAllPkIdList addObject:pkId];
        }
    }
    
    if (![self.emotionDispPkIdList.firstObject isEqualToString:kEmotionCollectionPKId]) {
        [self.emotionDispPkIdList insertObject:kEmotionCollectionPKId atIndex:0];
    }
}


- (void)saveEmotionsToFileForFileName:(NSString *)fileName {
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",fileName]];
    if ([fileName isEqualToString:kEmotionDispPkIdListFileName]) {
        // 获取emotionPackageIdList文件路径
        [self.emotionDispPkIdList writeToFile:resourcePath atomically:YES];
    } else{
        [self.emotionsInfoDic[fileName] writeToFile:resourcePath atomically:YES];
    }
}

- (void)saveEmotionDownloadData:(NSData *)data forPkId:(NSString *)pkId fileName:(NSString *)fileName {
    // 判断cache文件夹
    NSString *cachePath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:pkId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:fileName];
    [data writeToFile:resourcePath atomically:YES];
}

- (void)removeEmotionPkgFileForPkId:(NSString *)pkId {
    // 判断cache文件夹
    NSString *cachePath = [UserCachesPath stringByAppendingPathComponent:kEmotionPathResource];
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.info",pkId]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:resourcePath error:nil];
    }
    
   cachePath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:pkId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:cachePath error:nil];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionListUpdateNotification object:@{@"EmotionListUpdateType":@(EmotionListRemove), @"pkId":pkId}];
    });
}

//获取所有的表情表列表（只有表情包id）
- (NSArray *)getEmotionPackageIdList {
    return self.emotionDispPkIdList;
}

//获取某表情包的name
- (NSString *)getEmotionPackageNameForPackageId:(NSString *)emotionPackageId {
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        return emotionDic[KEmotionPackageNameKey];
    }
    return nil;
}

//判断某表情包是否支持图文混排
- (BOOL)isEmotionPackageSupportGraphicMixedForPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        return [emotionDic[KEmotionPackageShowAllKey] boolValue];
    }
    return NO;
}

//获取某表情包的版本
- (NSString *)getEmotionPackageVersionForPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        return emotionDic[KEmotionPackageVersionKey];
    }
    return nil;
}

//获取某表情包的封面图path
- (NSString *)getEmotionPackageCoverImagePathForPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSString *thumb = [NSString stringWithFormat:@"%@/%@/thumb.png", emotionPackageId, emotionPackageId];
        NSString *thumbPath = [self getImageAbsolutePathForRelativePath:thumb];
        if (thumbPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:thumbPath]) {
            return thumbPath;
        } else {
            NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
            return [self getImageAbsolutePathForRelativePath:[emotionDic[KEmotionImagePathListKey] firstObject]];
        }
    }
    return nil;
}

//获取某个表情包的详细信息（该套表情的所有相关信息都在这里）
- (NSDictionary *)getEmotionsInfoDicForPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        return self.emotionsInfoDic[emotionPackageId];
    }
    return nil;
}

//获取某个包中 shortcut 对应的 tip
- (NSString *)getEmotionTipNameForShortCut:(NSString *)shortCut withPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        NSDictionary * tipNameForShortCutDic = emotionDic[KEmotionTipNameForShortCutKey];
        return tipNameForShortCutDic[shortCut];
    }
    return nil;
}

//获取某个包中 tip 对应的 shortcut
- (NSString *)getEmotionShortCutForTipName:(NSString *)tipName withPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        NSDictionary * shortCutForTipNameDic = emotionDic[KEmotionShortcutForNameKey];
        return shortCutForTipNameDic[tipName];
    }
    return nil;
}

//获取某个包中 表情图片path list
- (NSArray *)getEmotionImagePathListForPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        _emotionsInfoDicPathArray = [NSMutableArray array];
        [_emotionsInfoDicPathArray addObjectsFromArray:emotionDic[KEmotionImagePathListKey]];
        return _emotionsInfoDicPathArray;
    }
    return nil;
}

- (NSString *)getImageAbsolutePathForRelativePath:(NSString *)path{
    // 判断cache文件夹
    NSString *cachePath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:path];
//    QIMVerboseLog(@"表情AbsolutePat : %@", cachePath);
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath]) {
        return cachePath;
    }
    return nil;
}

//获取某个包中 shortcut 对应的 表情图片path
- (NSString *)getEmotionImagePathForShortCut:(NSString *)shortCut withPackageId:(NSString *)emotionPackageId{
    if (self.emotionsInfoDic) {
        if (emotionPackageId == nil || emotionPackageId.length == 0) {
            for (NSString * pkId in self.emotionDispPkIdList) {
                NSDictionary * emotionDic = self.emotionsInfoDic[pkId];
                NSDictionary * imagePathForShortCutDic = emotionDic[KEmotionImagePathForShortcutKey];
                NSString * imagePath = imagePathForShortCutDic[shortCut];
                if (imagePath) {
                    return [self getImageAbsolutePathForRelativePath:imagePath];
                }
            }
            //兼容以前老版本 没有pkId的情况
            for (NSDictionary * emotionInfo in [self getHttpEmotions]) {
                //查询有没有缓存过改表情
                // 判断cache文件夹
                NSString *filePath = [[[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:emotionInfo[@"pkgid"]] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",shortCut]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    return filePath;
                }
            }
            //noPkId 文件夹
            NSString *filePath = [[[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:@"noPkId"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",shortCut]];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                return filePath;
            }
            
        } else{
            NSDictionary * emotionDic = _emotionsInfoDic[emotionPackageId];
            NSDictionary * imagePathForShortCutDic = emotionDic[KEmotionImagePathForShortcutKey];
            NSString * filePath = nil;
            if (imagePathForShortCutDic && imagePathForShortCutDic[shortCut]) {
                filePath = [self getImageAbsolutePathForRelativePath:imagePathForShortCutDic[shortCut]];
            }
            if (filePath == nil) {
                //查询有没有缓存过改表情
                // 判断cache文件夹
                filePath = [[[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:emotionPackageId] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",shortCut]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    return filePath;
                }
            }else{
                return filePath;
            }
        }
    }
    return nil;
}

- (NSString *)getEmotionShortCutForImagePath:(NSString *)imagePath withPackageId:(NSString *)emotionPackageId {
    if (self.emotionsInfoDic) {
        NSDictionary * emotionDic = self.emotionsInfoDic[emotionPackageId];
        NSDictionary * shortCutForImagePathDic = emotionDic[KEmotionShortcutForImagePathKey];
        return shortCutForImagePathDic[imagePath];
    }
    return nil;
}

- (NSArray *)getHttpEmotions {

    return self.httpEmotions;
}

- (void)getAndCheckEmotionsInfoFromHttp{
    
    NSString *destUrl = [NSString stringWithFormat:@"%@/s/qtalk/get_emotions.php?p=%@", [[QIMKit sharedInstance] qimNav_InnerFileHttpHost], [QIMKit getQIMProjectType] == QIMProjectTypeQChat ? @"qchat" : @"qtalk"];
    NSURL *requestUrl = [[NSURL alloc] initWithString:destUrl];
    QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:requestUrl];
    [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
        if (response.code == 200) {
            NSError *errol = nil;
            NSArray *result = [[QIMJSONSerializer sharedInstance] deserializeObject:response.data error:&errol];
//            "name": "牛驼表情",
//            "file": "https://qt.qunar.com/resources/niutuoEmotions.emt",
//            "desc": "扩展表情包,下载后可显示牛驼表情",
//            "thumb": "https://qt.qunar.com/resources/niutuoThumb.gif",
//            "file_size": 881251,
//            "md5": "1a3e842bb7aa04dba56249c889758bc5"
//
            if (_httpEmotions == nil) {
                _httpEmotions = [NSMutableArray arrayWithCapacity:1];
            } else{
                [_httpEmotions removeAllObjects];
            }
            if ([result isKindOfClass:[NSArray class]]) {
                [_httpEmotions addObjectsFromArray:result];
            }
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)updateEmotions:(NSArray *)items {
    
    [self.emotionDispPkIdList removeAllObjects];
    [_emotionDispPkIdList addObjectsFromArray:items];
        
    [self saveEmotionsToFileForFileName:kEmotionDispPkIdListFileName];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionListUpdateNotification object:@{@"EmotionListUpdateType":@(EmotionListUpdate)}];
    });
}


- (void)downloadEmotionForPkId:(NSString *)pkId loadUrl:(NSString *)loadUrl{
    if (pkId && ![_emotionDispPkIdList containsObject:pkId]) {
        dispatch_async(_emotionManagerQueue, ^{
            NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:loadUrl] options:NSDataReadingUncached error:nil];
            [self saveEmotionDownloadData:data forPkId:pkId fileName:[NSString stringWithFormat:@"%@.zip",pkId]];
            [self unpackEmotionPackageForPkId:pkId];
            if (_emotionDispPkIdList == nil) {
                _emotionDispPkIdList = [NSMutableArray arrayWithCapacity:1];
            }
            [_emotionDispPkIdList addObject:pkId];
            
            if (_emotionAllPkIdList == nil) {
                _emotionAllPkIdList = [NSMutableArray arrayWithCapacity:1];
            }
            [_emotionAllPkIdList addObject:pkId];
            [self saveEmotionsToFileForFileName:kEmotionDispPkIdListFileName];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionListUpdateNotification object:@{@"EmotionListUpdateType":@(EmotionListUpdate), @"pkId": pkId}];
            });
        });
    }
}

- (void)downloadEmotionForPkId:(NSString *)pkId fileName:(NSString *)fileName {
    if (pkId && ![_emotionDispPkIdList containsObject:pkId]) {
        dispatch_queue_t concurrentQueue = dispatch_queue_create("emotionDownload.queue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_async(concurrentQueue, ^{
            __block NSString *url = [NSString stringWithFormat:@"%@/file/v2/emo/d/z/%@?name=%@&u=%@&k=%@",
                                     [[QIMKit sharedInstance] qimNav_InnerFileHttpHost],
                                     pkId,
                                     fileName,
                                     [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                     [[QIMKit sharedInstance] myRemotelogginKey]];
            
            QIMHTTPRequest *request = [[QIMHTTPRequest alloc] initWithURL:[NSURL URLWithString:url]];
            [QIMHTTPClient sendRequest:request complete:^(QIMHTTPResponse *response) {
                if (response.code == 200) {
                    NSData *data = response.data;
                    if (data) {
                        [self saveEmotionDownloadData:data forPkId:pkId fileName:[NSString stringWithFormat:@"%@.zip",pkId]];
                        [self unpackEmotionPackageForPkId:pkId];
                        if (_emotionDispPkIdList == nil) {
                            _emotionDispPkIdList = [NSMutableArray arrayWithCapacity:1];
                        }
                        [_emotionDispPkIdList addObject:pkId];
                        
                        if (_emotionAllPkIdList == nil) {
                            _emotionAllPkIdList = [NSMutableArray arrayWithCapacity:1];
                        }
                        [_emotionAllPkIdList addObject:pkId];
                        [self saveEmotionsToFileForFileName:kEmotionDispPkIdListFileName];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter] postNotificationName:kEmotionListUpdateNotification object:@{@"EmotionListUpdateType":@(EmotionListUpdate), @"pkId": pkId}];
                        });
                    }
                }
            } failure:^(NSError *error) {
                
            }];
        });
    }
}

- (void)getEmotionImageFromHttpForPkId:(NSString *)pkId shortcut:(NSString *)shortcut signKey:(NSString *)signKey{
    if (shortcut.length == 0) {
        return;
    }
    if ([shortcut hasPrefix:@"/"]) {
        shortcut = [shortcut substringFromIndex:1];
    }
    dispatch_async(_emotionManagerQueue, ^{
        NSMutableDictionary *paramDic = [NSMutableDictionary dictionaryWithCapacity:1];
        [paramDic setQIMSafeObject:[QIMKit getLastUserName] forKey:@"u"];
        [paramDic setQIMSafeObject:[[QIMKit sharedInstance] myRemotelogginKey] forKey:@"k"];
        NSURL *url = nil;
        if (pkId.length) {
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/file/v2/emo/d/e/%@/%@/%@?u=%@&k=%@",
                                        [[QIMKit sharedInstance] qimNav_InnerFileHttpHost],
                                        pkId,
                                        [shortcut stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet nonBaseCharacterSet]],
                                        @"org",
                                        [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        [[QIMKit sharedInstance] myRemotelogginKey]]];//org或者fixed
        }else{
            //兼容老版本
            url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/file/v2/emo/d/oe/%@/%@?u=%@&k=%@",
                                        [[QIMKit sharedInstance] qimNav_InnerFileHttpHost],
                                        [shortcut stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet nonBaseCharacterSet]],
                                        @"org",
                                        [[QIMKit getLastUserName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                                        [[QIMKit sharedInstance] myRemotelogginKey]]];//org或者fixed
        }
        NSData * emotionImage = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:nil];
        if (emotionImage) {
            NSString * savPkId = pkId.length ? pkId : @"noPkId";
            [self saveEmotionImageForPkId:savPkId shortcut:shortcut imageData:emotionImage];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationEmotionImageDidLoad object:signKey];
            });
        } else{

        }
    });
}


- (void)saveEmotionImageForPkId:(NSString *)pkId shortcut:(NSString *)shortcut imageData:(NSData *)imageData{
    // 判断cache文件夹
    NSString *cachePath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:pkId];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath] == NO)
    {
        [[NSFileManager defaultManager] createDirectoryAtPath:cachePath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *resourcePath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",shortcut]];
    [imageData writeToFile:resourcePath atomically:YES];
}

- (void)unpackEmotionPackageForPkId:(NSString *)pkId{
    
    if (pkId.length > 0) {
        // 判断cache文件夹
        NSString *cachePath = [[UserCachesPath stringByAppendingPathComponent:kEmotionPathResource] stringByAppendingPathComponent:pkId];
        if ([[NSFileManager defaultManager] fileExistsAtPath:cachePath])
        {
            NSString *inputPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip",pkId]];
            if (inputPath.length <= 0) {
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"VacationBundle" ofType:@"bundle"];
                inputPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:pkId ofType:@"zip"];
            }
            NSString *outputPath = cachePath;
            ZipArchive *zip = [[ZipArchive alloc] init];
            [zip UnzipOpenFile:inputPath];
            if ([[NSFileManager defaultManager] fileExistsAtPath:outputPath] == NO)
            {
                [[NSFileManager defaultManager] createDirectoryAtPath:outputPath withIntermediateDirectories:NO attributes:nil error:nil];
            }
            [zip UnzipFileTo:outputPath overWrite:YES];
            
            _currentPrefixPath = [pkId stringByAppendingPathComponent:pkId];
            NSString * xmlPath = @"/";
            for (NSString * xmlFileName in [zip getZipFileContents]) {
                if ([xmlFileName hasSuffix:@".xml"]) {
                    xmlPath = [xmlPath stringByAppendingPathComponent:xmlFileName];
                    NSData * fileData = [NSData dataWithContentsOfFile:[outputPath stringByAppendingPathComponent:xmlFileName]];
                    [self parseXMLData:fileData];
                    if (_emotionsInfoDic == nil) {
                        _emotionsInfoDic = [NSMutableDictionary dictionaryWithCapacity:1];
                    }
                    NSDictionary *emotionInfoDic = @{KEmotionImagePathForShortcutKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionDic],
                                                     KEmotionShortcutForImagePathKey:[NSDictionary dictionaryWithDictionary:self.shortcutForImagePathDic],
                                                     KEmotionShortcutForNameKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionShorCutDic],
                                                     KEmotionTipNameForShortCutKey:[NSDictionary dictionaryWithDictionary:self.defaultEmotionNameDic],
                                                     KEmotionImagePathListKey:[NSArray arrayWithArray:self.defaultEmotionList],
                                                     KEmotionPackageNameKey:self.currentEmotionName,
                                                     KEmotionPackageShowAllKey:@(self.currentEmotionShowAll)
                                                     };
                    
                    [_emotionsInfoDic setQIMSafeObject:emotionInfoDic forKey:pkId];
                    [self saveEmotionsToFileForFileName:pkId];
                    break;
                }
            }
        }
    }
}

- (void)removeEmotionPkgForPkId:(NSString *)pkId{
    
    if ([_emotionAllPkIdList containsObject:pkId]) {
        [_emotionAllPkIdList removeObject:pkId];
    }
    
    if ([_emotionDispPkIdList containsObject:pkId]) {
        [_emotionDispPkIdList removeObject:pkId];
        [self saveEmotionsToFileForFileName:kEmotionDispPkIdListFileName];
    }
    
    if ([_emotionsInfoDic.allKeys containsObject:pkId]) {
        [_emotionsInfoDic removeObjectForKey:pkId];
        [self saveEmotionsToFileForFileName:[NSString stringWithFormat:@"%@",pkId]];
    }
    
    [self removeEmotionPkgFileForPkId:pkId];
}
@end

@implementation QIMEmotionManager (DecodeHTMLURL)


- (NSString *)decodeHtmlUrlForText:(NSString *)text{
    if (text.length > 0) {
        NSString *str = [self decodeHtmlUrlForText:text WithFilterAppendArray:nil];
        return str;
    }
    return @"";
}

- (NSString *)decodeHtmlUrlForText:(NSString *)text WithFilterAppendArray:(NSArray *)paramDict {
    NSString *str = text;
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *arrayOfAllMatches = [detect matchesInString:text options:0 range:NSMakeRange(0, [text length])];
    NSMutableDictionary *tiHuan = [NSMutableDictionary dictionary];
    int i = 0;
    NSMutableSet *matchSet = [NSMutableSet set];
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [text substringWithRange:match.range];
        [matchSet addObject:substringForMatch];
    }
    NSArray *matchList = [matchSet.allObjects sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 length] > [obj2 length]) {
            return NSOrderedAscending;
        } else if ([obj1 length] < [obj2 length]) {
            return NSOrderedDescending;
        } else {
            return NSOrderedSame;
        }
    }];
    for (NSString *match in matchList) {
        NSArray *paramArray = nil;
        NSString *matchStr = [match copy];
        for (NSDictionary *filterDict in paramDict) {
            NSString *filter = [filterDict objectForKey:@"filter"];
            if ([text containsString:filter]) {
                paramArray = [filterDict objectForKey:@"param"];
            }
        }
        if (paramArray.count > 0) {
            for (NSDictionary *paramDict in paramArray) {
                for (NSString *paramString in [paramDict allValues]) {
                    if ([matchStr containsString:@"?"]) {
                        matchStr = [matchStr stringByAppendingString:paramString];
                    } else {
                        matchStr = [matchStr stringByAppendingFormat:@"?%@", paramString];
                    }
                }
            }
        }
        NSString *tiStr = [NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]",matchStr];
        NSString *temp = [NSString stringWithFormat:@"&%d;",i];
        str = [str stringByReplacingOccurrencesOfString:match withString:temp];
        [tiHuan setQIMSafeObject:tiStr forKey:temp];
        i++;
    }
    for (NSString *key in tiHuan.allKeys) {
        NSString *imageHtml = [tiHuan objectForKey:key];
        str = [str stringByReplacingOccurrencesOfString:key withString:imageHtml];
    }
    return str;
}

@end
