//
//  QIMFaceViewCell.h
//  qunarChatIphone
//
//  Created by qitmac000495 on 16/5/9.
//
//

#import "QIMCommonUIFramework.h"
#import "YLImageView.h"
#import "QIMEmotionView.h"
#import "QIMEmotionTipDelegate.h"

@interface QIMFaceViewCell : UICollectionViewCell <QIMEmotionTipDelegate>

@property (nonatomic, strong) YLImageView *emojiView;

@property (nonatomic, assign) QTalkEmotionType emotionType;

@property (nonatomic, copy) NSString *emojiPath;

- (CGPoint)tipFloatPoint;

@end
