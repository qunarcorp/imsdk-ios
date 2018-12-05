//
//  QIMEmotionManagerView.h
//  qunarChatIphone
//
//  Created by QIM on 2018/2/7.
//

#import "QIMCommonUIFramework.h"

@protocol QTalkQIMEmotionManagerDelegate <NSObject>

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId isDelete:(BOOL)dele;

- (void)SendTheFaceStr:(NSString *)faceStr withPackageId:(NSString *)packageId;

- (void)segmentBtnDidClickedAtIndex : (NSInteger)index;

@end

@interface QIMEmotionManagerView : UIView

@property (nonatomic, weak) id <QTalkQIMEmotionManagerDelegate> delegate;

@property (nonatomic, copy) NSString *packageId;

- (instancetype)initWithFrame:(CGRect)frame WithPkId:(NSString *)packageId;

@end
