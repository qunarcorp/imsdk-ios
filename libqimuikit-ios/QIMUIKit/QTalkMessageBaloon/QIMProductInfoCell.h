//
//  QIMProductInfoCell.h
//  Vacation
//
//  Created by admin on 16/1/19.
//  Copyright © 2016年 Qunar.com. All rights reserved.
//

#import "QIMCommonUIFramework.h"
@class QIMMsgBaloonBaseCell;

@interface QIMProductInfoCell : QIMMsgBaloonBaseCell

@property (nonatomic, strong) NSString *headerUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSString *priceStr;
@property (nonatomic, strong) NSString *typeStr;
@property (nonatomic, strong) NSString *appUrl;
@property (nonatomic, strong) NSString *touchUrl;
@property (nonatomic, strong) UIViewController *owner;
@property (nonatomic, strong) NSString *messageDate;
+ (CGFloat)getCellHeight;
- (void)refreshUI;

@end
