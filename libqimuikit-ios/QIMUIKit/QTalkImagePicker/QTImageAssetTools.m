//
//  QTImageAssetTools.m
//  qunarChatIphone
//
//  Created by admin on 15/8/19.
//
//

#import "QTImageAssetTools.h"

@implementation QTImageAssetTools

+ (NSData *)getCompressImageFromALAsset:(ALAsset *)asset{
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    UIImage *image = [UIImage imageWithCGImage:representation.fullResolutionImage scale:representation.scale orientation:(UIImageOrientation)representation.orientation];
    return UIImageJPEGRepresentation(image, 0.5);
}

@end
