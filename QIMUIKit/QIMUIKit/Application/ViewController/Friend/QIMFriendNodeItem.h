//
//  QIMFriendNodeItem.h
//  qunarChatIphone
//
//  Created by admin on 15/11/17.
//
//
#import "QIMCommonUIFramework.h"

@interface QIMFriendNodeItem : NSObject

@property (nonatomic, assign) BOOL isParentNode;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *descInfo;

@property (nonatomic, strong) id contentValue;
@property (nonatomic, assign) BOOL isLast;

@property (nonatomic, assign) BOOL isFriend;

@end
