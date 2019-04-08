//
//  QIMCommonCategories.h
//  QIMCommonCategories
//
//  Created by 李露 on 2018/4/28.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<QIMCommonCategories/QIMCommonCategories.h>)
//! Project version number for QIMCommonCategories.
FOUNDATION_EXPORT double QIMCommonCategoriesVersionNumber;

//! Project version string for QIMCommonCategories.
FOUNDATION_EXPORT const unsigned char QIMCommonCategoriesVersionString[];

#import <QIMCommonCategories/NSBundle+QIMLibrary.h>
#import <QIMCommonCategories/NSData+QIMBase64.h>
#import <QIMCommonCategories/NSData+QIMCommonCrypto.h>
#import <QIMCommonCategories/NSData+QIMHookContentsOfFile.h>
#import <QIMCommonCategories/NSDate+QIMCategory.h>
#import <QIMCommonCategories/NSDateFormatter+QIMCategory.h>
#import <QIMCommonCategories/NSMutableDictionary+QIMSafe.h>

#import <QIMCommonCategories/NSObject+QIMRuntime.h>
#import <QIMCommonCategories/NSString+QIMBase64.h>
#import <QIMCommonCategories/NSString+QIMUtility.h>
#import <QIMCommonCategories/UIColor-Expanded.h>
#import <QIMCommonCategories/UIColor+QIMUtility.h>
#import <QIMCommonCategories/UIImage+QIMImageEffects.h>
#import <QIMCommonCategories/UIImage+QIMAnimatedGIF.h>
#import <QIMCommonCategories/UIImage+QIMUtility.h>
#import <QIMCommonCategories/UIImage+QIMRotate.h>
#import <QIMCommonCategories/UIImage+QIMTint.h>
#import <QIMCommonCategories/UIScreen+QIMIpad.h>
#import <QIMCommonCategories/UIView+QIMExtension.h>
#import <QIMCommonCategories/UIView+TTCategory.h>

#else
#import "NSBundle+QIMLibrary.h"
#import "NSData+QIMBase64.h"
#import "NSData+QIMCommonCrypto.h"
#import "NSData+QIMHookContentsOfFile.h"
#import "NSDate+QIMCategory.h"
#import "NSDateFormatter+QIMCategory.h"
#import "NSMutableDictionary+QIMSafe.h"

#import "NSObject+QIMRuntime.h"
#import "NSString+QIMBase64.h"
#import "NSString+QIMUtility.h"
#import "UIColor-Expanded.h"
#import "UIColor+QIMUtility.h"
#import "UIImage+QIMImageEffects.h"
#import "UIImage+QIMAnimatedGIF.h"
#import "UIImage+QIMUtility.h"
#import "UIImage+QIMRotate.h"
#import "UIImage+QIMTint.h"
#import "UIScreen+QIMIpad.h"
#import "UIView+QIMExtension.h"
#import "UIView+TTCategory.h"
#endif
