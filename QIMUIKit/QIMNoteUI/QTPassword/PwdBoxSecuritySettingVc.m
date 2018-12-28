//
//  PwdBoxSecuritySettingVc.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/20.
//
//

#import "PwdBoxSecuritySettingVc.h"
#import "QIMPwdBoxSecuritySettingCell.h"
#import "QIMNoteUICommonFramework.h"

@interface PwdBoxSecuritySettingVc () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSArray *securityNumbers;

@property (nonatomic, strong) UILabel *promptLabel;

@end

@implementation PwdBoxSecuritySettingVc

- (NSArray *)securityNumbers {
    if (!_securityNumbers) {
        NSDictionary *oneM = @{@"intro":[NSBundle qim_localizedStringForKey:@"1分钟"], @"value":@(1 * 60)};
        NSDictionary *twoM = @{@"intro":[NSBundle qim_localizedStringForKey:@"2分钟"], @"value":@(2 * 60)};
        NSDictionary *fiveM = @{@"intro":[NSBundle qim_localizedStringForKey:@"5分钟"], @"value":@(5 * 60)};
        NSDictionary *tenM = @{@"intro":[NSBundle qim_localizedStringForKey:@"10分钟"], @"value":@(10 * 60)};
        NSDictionary *M15 = @{@"intro":[NSBundle qim_localizedStringForKey:@"15分钟"], @"value":@(15 * 60)};
        NSDictionary *M30 = @{@"intro":[NSBundle qim_localizedStringForKey:@"30分钟"], @"value":@(30 * 60)};
        NSDictionary *M60 = @{@"intro":[NSBundle qim_localizedStringForKey:@"60分钟"], @"value":@(60 * 60)};
        _securityNumbers = @[oneM, twoM, fiveM, tenM, M15, M30, M60];
    }
    return _securityNumbers;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor whiteColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mainTableView;
}

- (void)setUpNavBar {
    
    self.title = [NSBundle qim_localizedStringForKey:@"password_box_security"];
}

- (UILabel *)promptLabel {
    
    if (!_promptLabel) {
        
        _promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.width, 60)];
        _promptLabel.text = [NSBundle qim_localizedStringForKey:@"password_box_securityIntro"];
        _promptLabel.font = [UIFont systemFontOfSize:14];
        _promptLabel.numberOfLines = 4;
        [_promptLabel sizeToFit];
        _promptLabel.textColor = [UIColor qtalkTextLightColor];
    }
    return _promptLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];
    self.view = self.mainTableView;
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.securityNumbers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *minuteDict = [self.securityNumbers objectAtIndex:indexPath.row];
    int value = 0;
    static NSString *statusCellId = nil;
    if (minuteDict) {
        statusCellId = [minuteDict objectForKey:@"intro"];
        value = [[[self.securityNumbers objectAtIndex:indexPath.row] objectForKey:@"value"] intValue];
    }
    QIMPwdBoxSecuritySettingCell *cell = [tableView dequeueReusableCellWithIdentifier:statusCellId];
    if (!cell) {
        cell = [[QIMPwdBoxSecuritySettingCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:statusCellId];
    }
    [cell setServiceStatusTitle:statusCellId];
    if (value == [[[QIMKit sharedInstance] userObjectForKey:@"securityMinute"] integerValue]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *minuteDict = [self.securityNumbers objectAtIndex:indexPath.row];
    int value = 0;
    if (minuteDict) {
        value = [[[self.securityNumbers objectAtIndex:indexPath.row] objectForKey:@"value"] intValue];
    }
    [[QIMKit sharedInstance] setUserObject:@(value) forKey:@"securityMinute"];
    [self.mainTableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 36)];
    [view addSubview:self.promptLabel];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

@end
