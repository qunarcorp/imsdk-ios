//
//  QIMGroupChatCell.h
//  qunarChatIphone
//
//  Created by wangshihai on 14/12/17.
//  Copyright (c) 2014年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMMsgBaloonBaseCell.h"
#define kTextLabelTag       9999

@class Message;

@protocol QIMGroupChatCellDelegate <NSObject>
@required

- (void)processEvent:(int) event withMessage:(id) message;

- (void)browserMessage:(Message *)message;

- (NSUInteger)getColorHex:(NSString *)text;

@end

@interface QIMGroupChatCell : QIMMsgBaloonBaseCell

@property (nonatomic, weak) id <QIMGroupChatCellDelegate, QIMMsgBaloonBaseCellDelegate> delegate;

- (NSInteger)indexForCellImagesAtLocation:(CGPoint)location;

@end
