//
//  NSObject+QIMRuntime.h
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/13.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (QIMRuntime)

/**
 获取所有的属性及属性值
 
 @return 所有的属性及属性值
 */
- (NSString *)qim_properties_aps;


/**
 清空所有属性值
 */
- (void)qim_clearPropertyValue;

/**
 重置所有成员变量
 */
- (void)qim_resetIvarList;

@end
