//
//  SkinManager.h
//  QunarUGC
//
//  Created by ping.xue on 13-11-27.
//
//

#import "QIMCommonUIFramework.h"

#define kSkinChangeNotifation   @"kSkinChangeNotifation"

/**
 *
 *  文案 字体名字 Key
 *
 **/
extern NSString *DocumentFont_Normal;
extern NSString *DocumentFont_NavBarButton;
extern NSString *DocumentFont_Button;
extern NSString *DocumentFont_Label;

/**
 *
 *  文案 颜色 Key
 *
 **/
extern NSString *DocumentColor_Normal;
extern NSString *DocumentColor_NavBarButton;
extern NSString *DocumentColor_Button;

/**
 *
 *  View 背景颜色 Key
 *
 **/
extern NSString *BgColor_Normal;
extern NSString *BgColor_NavBar;
extern NSString *BgColor_Button;

/**
 *
 *  View 背景图 Key
 *
 **/
extern NSString *BgImage_Normal;
extern NSString *BgImage_NavBar;
extern NSString *BgImage_TabBar;

typedef enum {
    SkinElementType_Button = 1,
    SkinElementType_View = 2,
}SkinElementType;

typedef enum {
    SkinMaterialType_Color = 1,
    SkinMaterialType_Image = 2,
}SkinMaterialType;

typedef enum {
    SkinType_Standard,
    SkinType_Girl,
}SkinType;

typedef enum {
    SkinMainBg_Default = 0,
    SkinMainBg_winter_feeling = 1,
    SkinMainBg_colorful_mood = 2,
    SkinMainBg_clover = 3,
}SkinMainBgType;

@interface SkinManager : NSObject

+ (void)setMainBgType:(SkinMainBgType)bgType;
+ (SkinMainBgType)getMainBgType;
+ (UIColor *)getMainBg:(SkinMainBgType)bgType;

+ (id)instance; 

- (UIFont *)getDocumentFont:(id)fontType WithSize:(CGFloat)size;
- (UIColor *)getDocumentColor:(id)colorType;

- (UIColor *)getViewBgColor:(id)bgColorType;
- (UIImage *)getViewBgImage:(id)bgImageType;

#pragma mark - Edit Skin
- (void)changeViewBgColor:(id)bgColorType WithColorHex:(NSInteger)hex WithAlpha:(CGFloat)alpha;


@end
