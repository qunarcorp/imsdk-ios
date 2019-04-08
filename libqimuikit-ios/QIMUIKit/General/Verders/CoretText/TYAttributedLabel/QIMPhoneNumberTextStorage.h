//
//  QIMPhoneNumberTextStorage.h
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2016/11/4.
//
//

#import "QIMCommonUIFramework.h"
#import "QIMTextStorage.h"

@interface QIMPhoneNumberTextStorage : QIMTextStorage <QCAppendTextStorageProtocol>

// textColor        链接颜色 如未设置就是QIMAttributedLabel的linkColor
// QIMAttributedLabel的 highlightedLinkBackgroundColor  高亮背景颜色
// underLineStyle   下划线样式（无，单 双） 默认单
// modifier         下划线样式 （点 线）默认线
@property (nonatomic, strong) id        phoneNumData;    // 链接携带的数据
@end
