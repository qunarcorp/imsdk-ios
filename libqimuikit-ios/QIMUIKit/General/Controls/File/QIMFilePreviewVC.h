//
//  QIMFilePreviewVC.h
//  qunarChatIphone
//
//  Created by xueping on 15/7/15.
//
//

#import "QIMCommonUIFramework.h"

#define kNotifyDownloadFileComplete @"kNotifyDownloadFileComplete"

@interface QIMFilePreviewVC : QTalkViewController
@property (nonatomic, strong) Message *message;
@end
