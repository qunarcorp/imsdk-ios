//
//  QIMEmotionTip.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/2/8.
//

#import "QIMCommonUIFramework.h"
#import "QIMFaceViewCell.h"
#import "QIMCollectionViewCell.h"

@interface QTalkShowAllEmojiTip : UIView

@property (nonatomic) QIMFaceViewCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(QIMFaceViewCell *)cell;

@end

@interface QTalkGifEmojiTip : UIView

@property (nonatomic) UICollectionViewCell *cell;

+ (instancetype)sharedTip;

- (void)showTipOnCell:(UICollectionViewCell *)cell;

@end
