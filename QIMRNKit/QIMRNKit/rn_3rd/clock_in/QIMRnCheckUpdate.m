//
//  QIMRnCheckUpdate.m
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/1.
//

#import "QIMRnCheckUpdate.h"
#import "QimRNBModule.h"
#import "QTalkPatchDownloadHelper.h"

@implementation QIMRnCheckUpdate

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(update:(NSDictionary *)param :(RCTResponseSenderBlock)callback) {
    QIMVerboseLog(@"更新QIM RN Param : %@", param);
    BOOL updateResult = NO;
    /*
    {
        bundleMd5 = fd8dc8ea170a6ad548f9c2b91cd2d821;
        bundleName = "qtalk-search-002001023-full-iOS.jsbundle";
        bundleUrl = "http://oimg.qunarzz.com/qtalk/opsapp/bundle/2.1.23/ios/qtalk-search-002001023-full-iOS.jsbundle.z2";
        full = 0;
        new = 1;
        patchMd5 = 0a8dd13b60e1407964c929f4d641cb6d;
        patchUrl = "http://oimg.qunarzz.com/qtalk/opsapp/bundle/2.1.23/ios/qtalk-search-002001015-002001023-patch-iOS.jsbundle";
        "update_type" = auto;
        zipMd5 = 6dc45eef339ba04c19edad3c9cc553cb;
    }
     */
    NSString *bundleMd5 = [param objectForKey:@"bundleMd5"];
    NSString *bundleName = [param objectForKey:@"bundleName"];
    NSString *bundleUrl = [param objectForKey:@"bundleUrl"];
    BOOL fullUpdate = [[param objectForKey:@"full"] boolValue];
    BOOL newUpdate = [[param objectForKey:@"new"] boolValue];
    NSString *patchMd5 = [param objectForKey:@"patchMd5"];
    NSString *patchUrl = [param objectForKey:@"patchUrl"];
    NSString *zipMd5 = [param objectForKey:@"zipMd5"];
    NSString *updateType = [param objectForKey:@"update_type"];
    if (newUpdate) {
        if ([updateType isEqualToString:@"full"]) {
            
            updateResult = [QTalkPatchDownloadHelper downloadFullPackageAndCheck:bundleUrl md5:bundleMd5 bundleName:bundleName zipName:[QimRNBModule getAssetZipBundleName] cachePath:[QimRNBModule getCachePath] destAssetName:[QimRNBModule getAssetBundleName]];
        } else if ([updateType isEqualToString:@"auto"]) {
            
            updateResult = [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:bundleMd5 cachePath:[QimRNBModule getCachePath] destAssetName:[QimRNBModule getAssetBundleName] innerBundleName: [QimRNBModule getInnerBundleName]];
            if(!updateResult){
                
                updateResult = [QTalkPatchDownloadHelper downloadFullPackageAndCheck:bundleUrl md5:bundleMd5 bundleName:bundleName zipName:[QimRNBModule getAssetZipBundleName] cachePath:[QimRNBModule getCachePath] destAssetName: [QimRNBModule getAssetBundleName]];
            }
            
        } else if ([updateType isEqualToString:@"patch"]) {
            
            updateResult = [QTalkPatchDownloadHelper downloadPatchAndCheck:patchUrl patchMd5:patchMd5 fullMd5:bundleMd5 cachePath:[QimRNBModule getCachePath] destAssetName:[QimRNBModule getAssetBundleName] innerBundleName: [QimRNBModule getInnerBundleName]];
        }
    }
    
    if(updateResult) {
        NSDictionary *resp1 = @{@"is_ok": @YES, @"errorMsg": @""};
        QIMVerboseLog(@"更新QIM RN 成功 结果 : %@", resp1);
        // TODO reload jsbundle
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotify_QIMRN_BUNDLE_UPDATE object:nil];
        });
        
        callback(@[resp1]);
    } else {
        NSDictionary *resp2 = @{@"is_ok": @NO, @"errorMsg": @""};
        QIMVerboseLog(@"更新QIM RN 失败 结果 : %@", resp2);
        callback(@[resp2]);
    }
}

@end
