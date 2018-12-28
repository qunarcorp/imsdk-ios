//
//  QIMDaysmatterModel.h
//  qunarChatIphone
//
//  Created by 李露 on 2018/3/19.
//

#import "QIMCommonUIFramework.h"

typedef NS_ENUM(NSUInteger, QTDaysmatterType) {
    QTDaysmatterTypeFestival = 0,
    QTDaysmatterTypeBirth,
    QTDaysmatterTypeYear,
};

@interface QIMDaysmatterModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;

@end
