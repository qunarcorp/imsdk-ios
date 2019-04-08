
#import <UIKit/UIKit.h>

@interface QIMRTCButton : UIButton

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isVideo;

+ (instancetype)rtcButtonWithTitle:(NSString *)title imageName:(NSString *)imageName isVideo:(BOOL)isVideo;

- (instancetype)initWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

+ (instancetype)rtcButtonWithTitle:(NSString *)title noHandleImageName:(NSString *)noHandleImageName;

@end
