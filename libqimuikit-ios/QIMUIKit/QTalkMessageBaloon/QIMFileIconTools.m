//
//  QIMFileIconTools.m
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMFileIconTools.h" 
@implementation QIMFileIconTools

+ (FileType)getFileTypeByFileExtension:(NSString *)fileExtension{
    NSString *pathExtension = [fileExtension lowercaseString];
    if ([pathExtension isEqualToString:@"doc"] || [pathExtension isEqualToString:@"docx"]) {
        return FileType_Word;
    } else if ([pathExtension isEqualToString:@"xlsx"] ||[pathExtension isEqualToString:@"xlsx"]||[pathExtension isEqualToString:@"cvs"] ) {
        return FileType_Excel;
    } else if ([pathExtension isEqualToString:@"html"]||[pathExtension isEqualToString:@"htm"]) {
        return FileType_Html;
    } else if ([pathExtension isEqualToString:@"png"]||[pathExtension isEqualToString:@"jpg"]||[pathExtension isEqualToString:@"jpeg"]||[pathExtension isEqualToString:@"gif"]) {
        return FileType_Image;
    } else if ([pathExtension isEqualToString:@"mp3"]||
               [pathExtension isEqualToString:@"wav"]||
               [pathExtension isEqualToString:@"caf"]||
               [pathExtension isEqualToString:@"aif"]) {
        return FileType_Audio;
    } else if ([pathExtension isEqualToString:@"ppt"]) {
        return FileType_PPT;
    } else if ([pathExtension isEqualToString:@"pdf"]) {
        return FileType_Pdf;
    } else if ([pathExtension isEqualToString:@"txt"]) {
        return FileType_Txt;
    } else if ([pathExtension isEqualToString:@"mp4"]||
               [pathExtension isEqualToString:@"m4v"]||
               [pathExtension isEqualToString:@"mov"]||
               [pathExtension isEqualToString:@"m2v"]||
               [pathExtension isEqualToString:@"3gp"]||
               [pathExtension isEqualToString:@"3g2"]) {
        return FileType_Video;
    } else if ([pathExtension isEqualToString:@"zip"]||[pathExtension isEqualToString:@"rar"]||[pathExtension isEqualToString:@"arj"]||[pathExtension isEqualToString:@"z"]) {
        return FileType_Zip;
    }
    return FileType_Unknow;

}
+ (UIImage *)getFileIconWihtExtension:(NSString *)pathExtension{
    switch ([self getFileTypeByFileExtension:pathExtension]) {
        case FileType_Audio:
        {
            UIImage *image = [UIImage imageNamed:@"chat_files_music"];
            UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
            [image drawAtPoint:CGPointMake(0, 0)];
            [[UIImage imageNamed:@"aio_sm_music_icon_start"] drawInRect:CGRectMake((image.size.width - 35)/2.0, (image.size.height-35)/2.0, 35, 35)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return image;
        }
            break;
        case FileType_Video:
        {
            UIImage *image = [UIImage imageNamed:@"chat_files_video"];
            return image;
        }
            break;
        case FileType_Image:
        {
            return [UIImage imageNamed:@"chat_files_image"];
        }
            break;
        case FileType_Html:
        {
            return [UIImage imageNamed:@"chat_files_html"];
        }
            break;
        case FileType_Txt:
        {
            return [UIImage imageNamed:@"chat_files_txt"];
        }
            break;
        case FileType_Word:
        {
            return [UIImage imageNamed:@"chat_files_word"];
        }
            break;
        case FileType_Excel:
        {
            return [UIImage imageNamed:@"chat_files_excel"];
        }
            break;
        case FileType_PPT:
        {
            return [UIImage imageNamed:@"chat_files_ppt"];
        }
            break;
        case FileType_Pdf:
        {
            return [UIImage imageNamed:@"chat_files_pdf"];
        }
            break;
        case FileType_Zip:
        {
            return [UIImage imageNamed:@"chat_files_zip"];
        }
            break;
        default:
        {
            return [UIImage imageNamed:@"chat_files_unknow"];
        }
            break;
    }
}

@end
