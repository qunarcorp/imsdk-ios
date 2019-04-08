//
//  QIMEmotionsDownloadCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/17.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMEmotion.h"

@class QIMMyEmotionsManagerViewController;
@interface QIMEmotionsDownloadCell : UITableViewCell

@property (nonatomic, strong) QIMEmotion *emotion;
//@property (nonatomic, strong) QIMMyEmotionsManagerViewController *superVC;

//cell状态
- (void)setEmotionState:(EmotionState )state;

@end
