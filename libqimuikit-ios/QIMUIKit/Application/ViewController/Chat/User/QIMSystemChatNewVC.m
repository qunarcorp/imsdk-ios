//
//  QIMSystemChatNewVC.m
//  QIMUIKit
//
//  Created by 李露 on 10/18/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMSystemChatNewVC.h"

@interface QIMSystemChatNewVC ()

@end

@implementation QIMSystemChatNewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)setChatTitle {
    [self.navigationItem setTitle:self.title];
}

- (void)setTitleRight {
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    headerView.layer.cornerRadius  = 2.0;
    headerView.layer.masksToBounds = YES;
    headerView.clipsToBounds       = YES;
    headerView.backgroundColor     = [UIColor clearColor];
    UIImage *headImage = [UIImage imageNamed:@"icon_speaker_h39"];
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQChat) {
        if ([self.chatId hasPrefix:@"rbt-notice"]) {
            headImage = [UIImage imageNamed:@"rbt_notice"];
        } else if ([self.chatId hasPrefix:@"rbt-qiangdan"] || [self.chatId hasPrefix:@"rbt-zhongbao"]) {
            headImage = [UIImage imageNamed:@"rbt-qiangdan"];
        } else {
            headImage = [UIImage imageNamed:@"icon_speaker_h39"];
        }
    } else {
        headImage = [UIImage imageNamed:@"icon_speaker_h39"];
    }
    [headerView setImage:headImage];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:headerView];
    
    [self.navigationItem setRightBarButtonItem:rightItem];
}

- (void)loadData {
    [self.messageManager.dataSource removeAllObjects];
    __weak typeof(self) weakSelf = self;
    if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
        
        NSString *domain = [[QIMKit sharedInstance] getDomain];
        [[QIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:domain WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            [weakSelf scrollToBottom_tableView];
        }];
    } else {
        [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WihtLimit:kPageCount WithOffset:0 WihtComplete:^(NSArray *list) {
            [self.messageManager.dataSource addObjectsFromArray:list];
            [weakSelf.tableView reloadData];
            [weakSelf scrollToBottom_tableView];
        }];
    }
    [[QIMKit sharedInstance] clearSystemMsgNotReadWithJid:self.chatId];
}

- (void)loadNewMsgList {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([QIMKit getQIMProjectType] == QIMProjectTypeQTalk) {
            [[QIMKit sharedInstance] getSystemMsgLisByUserId:self.chatId WithFromHost:[[QIMKit sharedInstance] getDomain] WithLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WithComplete:^(NSArray *list) {
                CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
                NSRange range = NSMakeRange(0, [list count]);
                NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                [self.tableView reloadData];
                
                self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
                //重新获取一次大图展示的数组
                [self addImageToImageList];
                [self.tableView.mj_header endRefreshing];
            }];
        } else {
            [[QIMKit sharedInstance] getMsgListByUserId:self.chatId WithRealJid:nil WihtLimit:kPageCount WithOffset:(int)self.messageManager.dataSource.count WihtComplete:^(NSArray *list) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat offsetY = self.tableView.contentSize.height -  self.tableView.contentOffset.y;
                    NSRange range = NSMakeRange(0, [list count]);
                    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
                    [self.messageManager.dataSource insertObjects:list atIndexes:indexSet];
                    [self.tableView reloadData];
                    
                    self.tableView.contentOffset = CGPointMake(0, self.tableView.contentSize.height - offsetY - 30);
                    //重新获取一次大图展示的数组
                    [self addImageToImageList];
                    [self.tableView.mj_header endRefreshing];
                });
            }];
        }
    });
}

- (void)synchronizeChatSession {
    
}

#pragma mark - NSNotifications

- (void)updateMessageList:(NSNotification *)notify{
    
    if ([self.chatId isEqualToString:notify.object]) {
        Message *msg = [notify.userInfo objectForKey:@"message"];
        
        if (msg) {
            [self.messageManager.dataSource addObject:msg];
            [self.tableView reloadData];
            [self addImageToImageList];
            [self scrollToBottomWithCheck:YES];
            [[QIMKit sharedInstance] clearSystemMsgNotReadWithJid:self.chatId];
        }
    }
}

@end
