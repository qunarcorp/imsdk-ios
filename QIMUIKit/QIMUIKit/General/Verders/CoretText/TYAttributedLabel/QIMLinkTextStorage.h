//
//  QIMLinkTextStorage.h
//  QIMAttributedLabelDemo
//
//  Created by chenjie on 16/7/7.
//  Copyright (c) 2016年 chenjie. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMTextStorage.h"

@interface QIMLinkTextStorage : QIMTextStorage<QCLinkStorageProtocol>

// textColor        链接颜色 如未设置就是QIMAttributedLabel的linkColor
// QIMAttributedLabel的 highlightedLinkBackgroundColor  高亮背景颜色
// underLineStyle   下划线样式（无，单 双） 默认单
// modifier         下划线样式 （点 线）默认线

@property (nonatomic, strong) id        linkData;    // 链接携带的数据

@end
