//
//  QIMChatBubbleView.h
//  qunarChatIphone
//
//  Created by chenjie on 16/2/16.
//
//

#import "QIMCommonUIFramework.h"

typedef enum {
    QIMChatBubbleViewDirectionRight,
    QIMChatBubbleViewDirectionLeft,
}QIMChatBubbleViewDirection;

@interface QIMChatBubbleView : UIView

@property (nonatomic,assign) QIMChatBubbleViewDirection direction;

- (void)removeMask;

-(void)setBgColor:(UIColor *)color;

@end
