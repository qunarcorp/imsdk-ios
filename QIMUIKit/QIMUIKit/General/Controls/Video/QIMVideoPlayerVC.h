//
//  QIMVideoPlayerVC.h
//  qunarChatIphone
//
//  Created by admin on 15/7/14.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMVideoPlayerVC : QTalkViewController
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *videoUrl;
@property (nonatomic, assign) NSInteger videoWidth;
@property (nonatomic, assign) NSInteger videoHeight;

@end
