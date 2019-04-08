//
//  QIMImageDoodleView.h
//  qunarChatIphone
//
//  Created by chenjie on 15/7/8.
//
//

#import "QIMCommonUIFramework.h"

typedef NS_ENUM(NSInteger, DrawingMode) {
    DrawingModeNone = 0,
    DrawingModePaint,
    DrawingModeErase,
};

@interface QIMImageDoodleView : UIView

@property (nonatomic, readwrite) DrawingMode drawingMode;
@property (nonatomic, strong) UIColor *selectedColor;

-(instancetype)initWithFrame:(CGRect)frame;

-(UIImage *)getDoodleImage;

-(void)clean;

@end
