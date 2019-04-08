//
//  QIMWorkMomentUserIdentityVC.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/4.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentUserIdentityVC.h"
#import "QIMWorkMomentUserIdentityModel.h"
#import "QIMWorkMomentUserIdentityCell.h"

@interface QIMWorkMomentUserIdentityVC () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *userIdentityListView;

@property (nonatomic, strong) NSMutableArray *userIdentityList;

@end

@implementation QIMWorkMomentUserIdentityVC

- (UITableView *)userIdentityListView {
    if (!_userIdentityListView) {
        _userIdentityListView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _userIdentityListView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8];
        _userIdentityListView.delegate = self;
        _userIdentityListView.dataSource = self;
        _userIdentityListView.estimatedRowHeight = 0;
        _userIdentityListView.estimatedSectionHeaderHeight = 0;
        _userIdentityListView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _userIdentityListView.tableFooterView = [UIView new];
        _userIdentityListView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _userIdentityListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _userIdentityListView;
}

- (NSMutableArray *)userIdentityList {
    if (!_userIdentityList) {
        _userIdentityList = [NSMutableArray arrayWithCapacity:2];
        QIMWorkMomentUserIdentityModel *model = [[QIMWorkMomentUserIdentityModel alloc] init];
        model.isAnonymous = NO;
        [_userIdentityList addObject:model];
    }
    return _userIdentityList;
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"发帖身份";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage qimIconWithInfo:[QIMIconInfo iconInfoWithText:@"\U0000f3cd" size:20 color:[UIColor qim_colorWithHex:0x333333]]] style:UIBarButtonItemStylePlain target:self action:@selector(backBtnClick:)];

    self.view.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    [self.view addSubview:self.userIdentityListView];
    __weak __typeof(self) weakSelf = self;
    [[QIMKit sharedInstance] getAnonyMouseDicWithMomentId:self.momentId WithCallBack:^(NSDictionary *anonymousDic) {
        NSLog(@"anonymousDic : %@", anonymousDic);
        if (anonymousDic.count > 0) {
            NSString *anonymousName = [anonymousDic objectForKey:@"anonymous"];
            NSString *anonymousPhoto = [anonymousDic objectForKey:@"anonymousPhoto"];
            NSInteger anonymousId = [[anonymousDic objectForKey:@"id"] integerValue];
            QIMWorkMomentUserIdentityModel *model = [[QIMWorkMomentUserIdentityModel alloc] init];
            model.isAnonymous = YES;
            model.anonymousId = anonymousId;
            model.anonymousName = anonymousName;
            model.anonymousPhoto = anonymousPhoto;
            [weakSelf.userIdentityList addObject:model];
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.userIdentityListView reloadData];
            });
        }
    }];
}

- (void)backBtnClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userIdentityList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = [NSString stringWithFormat:@"cellId-%d", indexPath.row];
    NSLog(@"cellId : %@", cellId);
    QIMWorkMomentUserIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell) {
        cell = [[QIMWorkMomentUserIdentityCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    QIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    NSLog(@"[[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] : %ld", [[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO);
    if (userIdentityModel.isAnonymous == NO) {
        cell.textLabel.text = @"实名发布";
        if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]) {
            [cell setUserIdentitySelected:NO];
        } else {
            [cell setUserIdentitySelected:YES];
        }
    } else {
        cell.textLabel.text = @"匿名发布";
        cell.detailTextLabel.text = [NSString stringWithFormat:@"花名：%@", userIdentityModel.anonymousName];
        cell.detailTextLabel.textColor = [UIColor qim_colorWithHex:0x999999];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]) {
            [cell setUserIdentitySelected:YES];
        } else {
            [cell setUserIdentitySelected:NO];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    if (userIdentityModel.isAnonymous == NO) {
        return 48.0f;
    } else {
        return 70.0f;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMWorkMomentUserIdentityModel *userIdentityModel = [self.userIdentityList objectAtIndex:indexPath.row];
    if (userIdentityModel.isAnonymous == NO) {
        [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousId:userIdentityModel.anonymousId];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
    } else {
        [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:YES];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousId:userIdentityModel.anonymousId];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:userIdentityModel.anonymousName];
        [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:userIdentityModel.anonymousPhoto];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kReloadUserIdentifier" object:nil];
    });
    [self.navigationController popViewControllerAnimated:YES];
}

@end
