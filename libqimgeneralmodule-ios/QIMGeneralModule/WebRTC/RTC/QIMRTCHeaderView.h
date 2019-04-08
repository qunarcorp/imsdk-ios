//
//  QIMRTCHeaderView.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/3/23.
//
//

#import <UIKit/UIKit.h>

@protocol QIMRTCHeaderViewDidClickDelegate <NSObject>

- (void)didClickUserQIMRTCHeaderViewWithTag:(NSInteger)tag;

@end

@interface QIMRTCHeaderView : UIView

@property (nonatomic, weak) id <QIMRTCHeaderViewDidClickDelegate> rtcHeaderViewDidClickDelegate;

- (instancetype)initWithinitWithFrame:(CGRect)frame userId:(NSString *)userId;

@end
