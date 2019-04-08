//
//  SkinManager.m
//  QunarUGC
//
//  Created by ping.xue on 13-11-27.
//
//

#import "SkinManager.h"

#define kUserDefault_SkinInfo           @"kUserDefault_SkinInfo"
#define kUserDefault_DocumentFontName   @"kUserDefault_DocumentFontName"
#define kUserDefault_DocumentColor      @"kUserDefault_DocumentColor"
#define kUserDefault_ViewBgColor        @"kUserDefault_ViewBgColor"
#define kUserDefault_ViewBgImage        @"kUserDefault_ViewBgImage"
#define kColor_Hex                      @"kColor_Hex"
#define kColor_Alpha                    @"kColor_Alpha"

#define kFilePathPrefix_Resounce        @"Resounce://"
#define kFilePathPrefix_Document        @"Document://"

/**
 *
 *  文案 字体名字 Key
 *
 **/
NSString *DocumentFont_Normal = @"DocumentFont_Normal";
NSString *DocumentFont_NavBarButton = @"DocumentFont_NavBarButton";
NSString *DocumentFont_Button = @"DocumentFont_Button";
NSString *DocumentFont_Label = @"DocumentFont_Label";

/**
 *
 *  文案 颜色 Key
 *
 **/
NSString *DocumentColor_Normal = @"DocumentColor_Normal";
NSString *DocumentColor_NavBarButton = @"DocumentColor_NavBarButton";
NSString *DocumentColor_Button = @"DocumentColor_Button";

/**
 *
 *  View 背景颜色 Key
 *
 **/
NSString *BgColor_Normal = @"BgColor_Normal";
NSString *BgColor_NavBar = @"BgColor_NavBar";
NSString *BgColor_Button = @"BgColor_Button";

/**
 *
 *  View 背景图 Key
 *
 **/
NSString *BgImage_Normal = @"BgImage_Normal";
NSString *BgImage_NavBar = @"BgImage_NavBar";
NSString *BgImage_TabBar = @"BgImage_TabBar";

static SkinManager *__global_SkinManager = nil;
@implementation SkinManager{
    NSMutableDictionary     *_skinDic;
    NSMutableDictionary     *_documentFontNameDic;
    NSMutableDictionary     *_documentColorDic;
    NSMutableDictionary     *_viewBgColorDic;
    NSMutableDictionary     *_viewBgImageDic;
}

+ (id)instance{
    if (__global_SkinManager == nil) {
        __global_SkinManager = [[SkinManager alloc] init];
    }
    return __global_SkinManager;
}

- (id)init{
    self = [super init];
    if (self) {
        
        NSString *skinFilePath = [[NSBundle mainBundle] pathForResource:@"SkinList" ofType:@"plist"]; 
        _skinDic = [[NSMutableDictionary alloc] initWithContentsOfFile:skinFilePath];
        
        _documentFontNameDic = [[NSMutableDictionary alloc] initWithDictionary:[_skinDic objectForKey:kUserDefault_DocumentFontName]];
        _documentColorDic = [[NSMutableDictionary alloc] initWithDictionary:[_skinDic objectForKey:kUserDefault_DocumentColor]];
        _viewBgColorDic = [[NSMutableDictionary alloc] initWithDictionary:[_skinDic objectForKey:kUserDefault_ViewBgColor]];
        _viewBgImageDic = [[NSMutableDictionary alloc] initWithDictionary:[_skinDic objectForKey:kUserDefault_ViewBgImage]];
        
//        [self changeViewBgColor:BgColor_NavBar WithColorHex:0xff0000 WithAlpha:1];
        
    }
    return self;
}

+ (void)setMainBgType:(SkinMainBgType)bgType{
    
    [[QIMKit sharedInstance] setUserObject:[NSNumber numberWithInt:bgType] forKey:@"SkinMainBgType"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSkinChangeNotifation object:nil];
    
}

+ (SkinMainBgType)getMainBgType{
    return [[[QIMKit sharedInstance] userObjectForKey:@"SkinMainBgType"] intValue];
}

+ (UIColor *)getMainBg:(SkinMainBgType)bgType{
    UIColor *color = nil;
    switch (bgType) {
        case SkinMainBg_Default:
        {
            color = [UIColor whiteColor];
        }
            break;
        case SkinMainBg_clover:
        {
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"clover"]];
        }
            break;
        case SkinMainBg_colorful_mood:
        {
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"colorful_mood"]];
        }
            break;
        case SkinMainBg_winter_feeling:
        {
            color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"winter_feeling"]];
        }
            break;
        default:
            break;
    }
    return color;
}

- (UIFont *)getDocumentFont:(id)fontType WithSize:(CGFloat)size{
    UIFont *font = nil;
    NSString *fontName = [_documentFontNameDic objectForKey:fontType];
    if ([fontName isEqualToString:@"System Font"]) {
        font = [UIFont systemFontOfSize:size];
    } else if ([fontName isEqualToString:@"System Bold Font"]){
        font = [UIFont boldSystemFontOfSize:size];
    } else {
        font = [UIFont fontWithName:fontName size:size];
    }
    return font;
}

- (UIColor *)getDocumentColor:(id)colorType{
    NSDictionary *colorArray = [_documentColorDic objectForKey:colorType];
    UIColor *color = [UIColor qim_colorWithHex:[[colorArray objectForKey:kColor_Hex] integerValue] alpha:[[colorArray objectForKey:kColor_Alpha] floatValue]];
    return color;
}

- (UIColor *)getViewBgColor:(id)bgColorType{
    NSDictionary *colorArray = [_viewBgColorDic objectForKey:bgColorType];
    UIColor *color = [UIColor qim_colorWithHex:[[colorArray objectForKey:kColor_Hex] integerValue] alpha:[[colorArray objectForKey:kColor_Alpha] floatValue]];
    return color;
}

- (UIImage *)getViewBgImage:(id)bgImageType{
    NSString *filePath = [_viewBgImageDic objectForKey:bgImageType];
    UIImage *bgImage = nil;
    if ([filePath hasPrefix:kFilePathPrefix_Resounce]) {
        if (filePath.length > 11) {
            filePath = [filePath substringFromIndex:11];
            bgImage = [UIImage imageWithContentsOfFile:filePath];
        }
    } else if ([filePath hasPrefix:kFilePathPrefix_Document]) {
        if (filePath.length > 11) {
            filePath = [filePath substringFromIndex:11];
            bgImage = [UIImage imageWithContentsOfFile:filePath];
        }
    } else {
        
    }
    return bgImage;
}

#pragma mark - Skin Edit

- (void)changeViewBgColor:(id)bgColorType WithColorHex:(NSInteger)hex WithAlpha:(CGFloat)alpha{
    
    NSDictionary *colorDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:hex],kColor_Hex,[NSNumber numberWithFloat:alpha],kColor_Alpha, nil];
    [_viewBgColorDic setObject:colorDic forKey:bgColorType];
    [_skinDic setObject:_viewBgColorDic forKey:kUserDefault_ViewBgColor];
    NSString *skinFilePath = [[NSBundle mainBundle] pathForResource:@"SkinList" ofType:@"plist"];
    [_skinDic writeToFile:skinFilePath atomically:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kSkinChangeNotifation object:nil];
    
}

- (void)dealloc{
    _skinDic = nil;
    _documentFontNameDic = nil;
    _documentColorDic = nil;
    _viewBgColorDic = nil;
    _viewBgImageDic = nil;
}

@end
