//
//  QIMBaseChatVc.h
//  QIMUIKit
//
//  Created by 李露 on 10/15/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCommonUIFramework.h"
#import "QIMTextBar.h"
#import "QIMMessageTableViewManager.h"
#import "QIMMessageRefreshHeader.h"

#define kPageCount 20

NS_ASSUME_NONNULL_BEGIN

@interface QIMBaseChatVc : QTalkViewController

@property (nonatomic, strong) NSString *chatId;

@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) ChatType chatType;

@property (nonatomic, strong) QIMTextBar *textBar;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) QIMMessageTableViewManager *messageManager;

@property (nonatomic, assign) CGRect tableViewFrame;

@property (nonatomic, strong) UIImageView *chatBGImageView;

@property (nonatomic, strong) UIButton *forwardBtn;

@property (nonatomic, strong) UIView *forwardNavTitleView;
@property (nonatomic, strong) UIView *maskRightTitleView;

@property (nonatomic, copy) NSString *forwardExportMsgJsonFilePath;

@property (nonatomic, strong) NSMutableDictionary *photos;

@property (nonatomic, strong) NSMutableArray *imagesArr;

@property (nonatomic, strong) UIView *notificationView;

- (void)sendText:(NSString *)text;


- (void)scrollToBottom_tableView;

- (BOOL)shouldScrollToBottomForNewMessage;

- (void)scrollBottom;

- (void)scrollToBottomWithCheck:(BOOL)flag;

- (void)scrollToBottom:(BOOL)animated;

- (void)addImageToImageList;

@end

NS_ASSUME_NONNULL_END
