//
//  QIMCommonTableViewCellData.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/12/21.
//

#import "QIMCommonTableViewCellData.h"
#import "QIMIconInfo.h"
#import "QIMIconFont.h"

@implementation QIMCommonTableViewCellData

- (instancetype)initWithTitle:(NSString *)title iconName:(NSString *)iconName cellDataType:(QIMCommonTableViewCellDataType)cellDataType {
    return [self initWithTitle:title subTitle:nil iconName:iconName cellDataType:cellDataType];
}

- (instancetype)initWithTitle:(NSString *)title subTitle:(NSString *)subTitle iconName:(NSString *)iconName cellDataType:(QIMCommonTableViewCellDataType)cellDataType {
    self = [super init];
    if (self) {
        self.title = title;
        if (iconName) {
            self.icon = [UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:iconName size:24 color:[UIColor qim_colorWithHex:0x9e9e9e alpha:1.0]]];
        }
        self.subTitle = subTitle;
        self.cellDataType = cellDataType;
    }
    
    return self;
}

@end
