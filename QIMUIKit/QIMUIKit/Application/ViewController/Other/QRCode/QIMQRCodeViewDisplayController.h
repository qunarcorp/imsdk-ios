//
//  QIMQRCodeViewDisplayController.h
//  qunarChatIphone
//
//  Created by qitmac000301 on 15/4/17.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h" 

@interface QIMQRCodeViewDisplayController : QTalkViewController

@property (nonatomic, copy)NSString *jid;

@property (nonatomic, copy)NSString *name;

@property (nonatomic, assign)QRCodeType QRtype;

@end
