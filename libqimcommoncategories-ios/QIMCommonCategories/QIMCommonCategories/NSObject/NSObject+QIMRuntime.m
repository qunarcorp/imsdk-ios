//
//  NSObject+QIMRuntime.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/9/13.
//
//

#import "NSObject+QIMRuntime.h"
#import <objc/runtime.h>

@implementation NSObject (QIMRuntime)

/**
 获取所有的属性及属性值
 
 @return 所有的属性及属性值
 */
- (NSString *)qim_properties_aps
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++)
    {
        objc_property_t property = properties[i];
        const char* char_f = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:char_f];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    NSMutableString *str = [NSMutableString string];
    for (id key in props) {
        id obj = [props objectForKey:key];
        [str appendFormat:@"%@ : %@\r", key, obj ? obj : @"NULL"];
    }
    free(properties);
    return str;
}

/**
 清空属性值
 */
/**
 清空属性值
 */
- (void)qim_clearPropertyValue {
    // 置空自身的属性值
    unsigned int pro_count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &pro_count);
    for (int i = 0; i < pro_count; i ++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        [self setValue:nil forKey:propertyName];
    }
    free(properties);
    
    // 置空父类(PowerStationForHouseholdModel)的属性值
    pro_count = 0;
    objc_property_t *properties_super = class_copyPropertyList([self superclass], &pro_count);
    for (int i = 0; i < pro_count; i ++) {
        objc_property_t property = properties_super[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        [self setValue:nil forKey:propertyName];
    }
    free(properties_super);
}

- (void)qim_setNilValueForKey:(NSString *)key {
    return;
}

- (void)qim_resetIvarList {
    
    unsigned int count, i;
    Ivar *ivarList = class_copyIvarList([self class], &count);
    for (i = 0; i < count; i++)
    {
        Ivar thisIvar = ivarList[i];
        const char *type = ivar_getTypeEncoding(thisIvar);
        NSString *stringType =  [NSString stringWithCString:type encoding:NSUTF8StringEncoding];
        NSString *key = [NSString stringWithUTF8String:ivar_getName(thisIvar)];
        if ([stringType containsString:@"dispatch_queue"]) {
            continue;
        } else {
            object_setIvar(self, ivarList[i], nil);
        }
    }
    free(ivarList);
}

- (void)qim_setValue:(id)value forUndefinedKey:(NSString *)key {
    
}

@end
