//
//  QIMCustomPopViewController.m
//  QIMUIVendorKit
//
//  Created by 李露 on 11/5/18.
//  Copyright © 2018 QIM. All rights reserved.
//

#import "QIMCustomPopViewController.h"
#import "QIMTableView.h"

@interface QIMCustomPopViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) QIMTableView *popTableView;

@end

@implementation QIMCustomPopViewController

- (QIMTableView *)popTableView {
    if (!_popTableView) {
        _popTableView = [[QIMTableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), self.preferredContentSize.height - [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]) style:UITableViewStylePlain];
        _popTableView.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        _popTableView.estimatedRowHeight = 0;
        _popTableView.estimatedSectionHeaderHeight = 0;
        _popTableView.estimatedSectionFooterHeight = 0;
#endif
        _popTableView.separatorInset = UIEdgeInsetsMake(0,20, 0, 20);           //top left bottom right 左右边距相同
        _popTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _popTableView.delegate = self;
        _popTableView.dataSource = self;
        _popTableView.rowHeight = 40.0f;
        _popTableView.bounces = NO;
    }
    return _popTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updatePreferredContentSizeWithTraitCollection:self.traitCollection];
}

- (void)dealloc {
    
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    [self updatePreferredContentSizeWithTraitCollection:newCollection];
}

- (void)updatePreferredContentSizeWithTraitCollection:(UITraitCollection *)traitCollection {
    self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, (self.items.count <= 4) ? 270 + [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT] : 520 + [[QIMDeviceManager sharedInstance] getHOME_INDICATOR_HEIGHT]);
    self.view.backgroundColor = [UIColor qtalkChatBgColor];
    [self.view addSubview:self.popTableView];
    self.popTableView.tableHeaderView = [self getHeaderView];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *questionItemDic = [self.items objectAtIndex:indexPath.row];
    NSString * itemText = [questionItemDic objectForKey:@"text"];
    cell.textLabel.text = (itemText.length > 0) ? itemText : @"";
    cell.textLabel.textColor = [UIColor qim_colorWithHex:0x5CC57F];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *questionItemDic = [self.items objectAtIndex:indexPath.row];
    NSString * itemText = [questionItemDic objectForKey:@"text"];
    NSDictionary * eventDic = questionItemDic[@"event"];
    NSString * clickType = [eventDic objectForKey:@"type"];
    NSString * url = [eventDic objectForKey:@"url"];
    NSString * afterClickSendMsg = [eventDic objectForKey:@"msgText"];
    if ([[clickType lowercaseString] isEqualToString:@"interface"]) {
        if (url.length > 0) {
            [[QIMKit sharedInstance] sendTPPOSTRequestWithUrl:url withSuccessCallBack:^(NSData *responseData) {
                
            } withFailedCallBack:^(NSError *error) {
                
            }];

        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSendRobotQuestion object:@{@"msgText":(afterClickSendMsg.length > 0) ? afterClickSendMsg : itemText, @"isSendToServer": (afterClickSendMsg.length > 0) ? @(YES) : @(NO), @"userType":@"cRbt"}];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dimmingViewTappedNotify" object:nil];
        }
    } else if ([[clickType lowercaseString] isEqualToString:@"forward"]) {
        if (url.length ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"openWebView" object:url];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (UIView *)getHeaderView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.popTableView.frame), 70)];
    view.backgroundColor = [UIColor whiteColor];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, CGRectGetWidth(view.frame), 70)];
    [label setBackgroundColor:[UIColor whiteColor]];
    [label setFont:[UIFont boldSystemFontOfSize:15]];
    [label setTextColor:[UIColor qim_colorWithHex:0x212121]];
    [label setText:self.popHeaderTitle];
    [view addSubview:label];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

@end
