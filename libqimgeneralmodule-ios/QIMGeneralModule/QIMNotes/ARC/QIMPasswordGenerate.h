//
//  QIMPasswordGenerate.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/11.
//
//

#import <Foundation/Foundation.h>

@interface QIMPasswordGenerate : NSObject

+ (QIMPasswordGenerate *)sharedInstance;

- (NSString *)createPasswordWithBit:(int)bit //密码位数
                         WithNumber:(int)numberCount //数字个数
                      WithUpperCase:(int)ucCount //大写字母个数
                      WithLowerCase:(int)lcCount //小写字母个数
              WithSpecialCharacters:(int)scCount //特殊字符
                    WithAllowRepeat:(BOOL)allowRepeat; //是否允许重复字符

@end
