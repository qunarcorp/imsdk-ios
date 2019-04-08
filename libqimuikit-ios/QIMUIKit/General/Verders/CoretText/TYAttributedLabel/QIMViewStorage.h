//
//  QCDrawViewStorage.h
//  QIMAttributedLabelDemo
//
//  Created by tanyang on 15/4/9.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMDrawStorage.h"

@interface QIMViewStorage : QIMDrawStorage<QIMViewStorageProtocol>

@property (nonatomic, strong)   UIView *view;       // 添加view

@end
