//
//  QTalkSearch.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/28.
//
//

#ifndef QTalkSearch_h
#define QTalkSearch_h

#import "QIMCommonUIFramework.h"
#import <React/RCTBridge.h>

#define kNotify_RN_QTALK_SEARCH_BUNDLE_UPDATE @"kNotify_RN_QTALK_SEARCH_BUNDLE_UPDATE"

@class MBProgressHUD;
@interface QTalkSearchRNView : UIView
{
    NSURL *_jsCodeLocation;
}
@property (nonatomic, weak) UIViewController *ownerVC;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

+(NSString *)getAssetZipBundleName;
+(NSString *)getAssetBundleName;
+(NSString *)getInnerBundleName;
+(NSString *)getCachePath;

@end

#endif /* QTalkSearch_h */
