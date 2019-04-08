//
//  QIMMainVC.h
//  qunarChatIphone
//
//  Created by 平 薛 on 15/4/15.
//  Copyright (c) 2015年 ping.xue. All rights reserved.
//

#import "QIMCommonUIFramework.h"

@interface QIMMainVC : UIViewController

@property (nonatomic, strong) UIView *rootView;

@property (nonatomic, strong) UISearchDisplayController *mySearchDisplayController;

@property(nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, assign) BOOL skipLogin;

- (void)selectTabAtIndex : (NSInteger)index;

- (void)setLoadingViewWithHidden:(BOOL)hidden;

+ (instancetype)sharedInstanceWithSkipLogin:(BOOL)skipLogin;

@end
