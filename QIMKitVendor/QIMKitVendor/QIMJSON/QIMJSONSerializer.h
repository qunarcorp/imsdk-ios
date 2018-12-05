//
//  QIMJSONSerializer.h
//  ObjcJSON
//
//  Created by QIM on 2017/10/30.
//  Copyright © 2017年 QIM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QIMJSONSerializer : NSObject

+ (instancetype)sharedInstance;

//字典/数组 -> JSON
- (NSData *)serializeObject:(id)inObject error:(NSError **)outError;

- (NSString *)serializeObject:(id)inObject;

//JSON -> 字典/数组
- (id)deserializeObject:(id)inObject error:(NSError **)outError;

@end
