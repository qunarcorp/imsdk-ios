//
//  QIMFileIconTools.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    FileType_Unknow,
    FileType_Audio,
    FileType_Video,
    FileType_Zip,
    FileType_Html,
    FileType_Word,
    FileType_Excel,
    FileType_PPT,
    FileType_Pdf,
    FileType_Image,
    FileType_Txt,
}FileType;

@interface QIMFileIconTools : NSObject

+ (FileType)getFileTypeByFileExtension:(NSString *)fileExtension;

+ (UIImage *)getFileIconWihtExtension:(NSString *)pathExtension;

@end
