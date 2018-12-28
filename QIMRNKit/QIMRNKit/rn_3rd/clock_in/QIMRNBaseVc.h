//
//  QIMRNBaseVc.h
//  QIMRNKit
//
//  Created by 李露 on 2018/8/23.
//  Copyright © 2018年 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import <React/RCTBridge.h>
#import "QIMMWPhotoBrowser.h"

@interface QIMRNBaseVc : UIViewController

@property (nonatomic, strong) NSString *rnName;
@property (nonatomic, assign) BOOL hiddenNav;
@property (nonatomic, strong) RCTBridge *bridge;

@end

@interface QIMRNBaseVc (PhotoBrowser) <QIMMWPhotoBrowserDelegate>

- (void)browseBigHeader:(NSNotification *)notify;

@end
