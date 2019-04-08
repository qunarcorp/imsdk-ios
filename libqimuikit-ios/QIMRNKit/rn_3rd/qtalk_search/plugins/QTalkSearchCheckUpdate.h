//
//  QTalkSearchCheckUpdate.h
//  qunarChatIphone
//
//  Created by wangyu.wang on 2016/11/29.
//
//

#ifndef QTalkSearchCheckUpdate_h
#define QTalkSearchCheckUpdate_h

#import <React/RCTBridgeModule.h>
#import "QIMCommonUIFramework.h"

@interface  QTalkSearchCheckUpdate: NSObject <RCTBridgeModule>

+(NSString*) checkAndGetRNBundlePath;
+(void) saveBundleToCache:(NSData *)bundleInfo;
+(void) unzipBundle;
+(NSString *)getAssetBundleName;
+(NSString *)getOriginBundlePath;
+(NSString *)getDestBundlePath;

@end

#endif /* QTalkSearchCheckUpdate_h */
