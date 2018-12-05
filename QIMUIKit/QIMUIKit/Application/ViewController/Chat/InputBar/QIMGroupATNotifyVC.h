//
//  QIMGroupATNotifyVC.h
//  qunarChatIphone
//
//  Created by wangshihai on 15/4/22.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

typedef void(^onSelectMemberBlock)(NSDictionary * memeberInfo);

@interface QIMGroupATNotifyVC : QTalkViewController
{
    onSelectMemberBlock _funBlock;
}

@property(nonatomic,copy) NSString *groupID;

-(void)selectMember:(onSelectMemberBlock)block;

@end
