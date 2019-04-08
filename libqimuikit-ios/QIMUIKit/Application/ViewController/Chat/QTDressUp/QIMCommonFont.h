//
//  QIMCommonFont.h
//  qunarChatIphone
//
//  Created by chenjie on 16/3/7.
//
//

#import "QIMCommonUIFramework.h"

@interface QIMCommonFont : NSObject

+ (instancetype)sharedInstance;

- (float)currentFontSize;

- (void)setCurrentFontSize:(float)fontSize;

- (NSString *)currentFontName;

- (void)setCurrentFontName:(NSString *)fontName;

@end
