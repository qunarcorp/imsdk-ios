//
//  QIMServiceStatusViewController.m
//  qunarChatIphone
//
//  Created by Qunar-Lu on 2017/4/10.
//
//

#import "QIMServiceStatusViewController.h"
#import "QIMServiceStatusTableViewCell.h"
#import "NSBundle+QIMLibrary.h"
@interface QIMServiceStatusViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *mainTableView;

@property (nonatomic, strong) NSArray *serviceStatus;

@property (nonatomic, strong) NSArray *serviceShops;

@end

@implementation QIMServiceStatusViewController

- (NSArray *)serviceStatus {
    if (!_serviceStatus) {
        _serviceStatus = [[QIMKit sharedInstance] availableUserSeatStatus];
    }
    return _serviceStatus;
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.backgroundColor = [UIColor qtalkTableDefaultColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _mainTableView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.serviceShops.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.serviceStatus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *statusDict = [self.serviceStatus objectAtIndex:indexPath.row];
    int status = -1;
    static NSString *statusCellId = nil;
    if (statusDict) {
        statusCellId = [statusDict objectForKey:@"StatusTitle"];
        status = [[[self.serviceStatus objectAtIndex:indexPath.row] objectForKey:@"Status"] intValue];
    }
    NSDictionary *serviceShop = [self.serviceShops objectAtIndex:indexPath.section];
    NSInteger shopServiceStatus = [[serviceShop objectForKey:@"st"] integerValue];
    QIMServiceStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:statusCellId];
    if (!cell) {
        cell = [[QIMServiceStatusTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:statusCellId];
    }
    [cell setServiceStatusTitle:[statusDict objectForKey:@"StatusTitle"]];
    [cell setServiceStatusDetail:[statusDict objectForKey:@"StatusDesc"]];
    if (status == shopServiceStatus) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *serviceShop = [self.serviceShops objectAtIndex:section];
    NSString *sname = [serviceShop objectForKey:@"sname"];
    return [NSString stringWithFormat:@"店铺名 : %@", sname];
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 5, 320, 20);
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor lightGrayColor];
    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont systemFontOfSize:14];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSInteger status = [[[self.serviceStatus objectAtIndex:indexPath.row] objectForKey:@"Status"] integerValue];
    NSDictionary *serviceShop = [self.serviceShops objectAtIndex:indexPath.section];
    NSInteger shopId = [[serviceShop objectForKey:@"sid"] integerValue];
    NSInteger shopServiceStatus = [[serviceShop objectForKey:@"st"] integerValue];
    if (status != shopServiceStatus) {
        BOOL updateShopServiceSuccess = [[QIMKit sharedInstance] updateSeatSeStatusWithShopId:shopId WithStatus:status];
        if (updateShopServiceSuccess) {
            self.serviceShops = [[QIMKit sharedInstance] getSeatSeStatus];
            [self.mainTableView reloadData];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [QIMServiceStatusTableViewCell getCellHeight];
}

- (void)setUpNavBar {
    
    self.title = [NSBundle qim_localizedStringForKey:@"myself_tab_service"];
}

- (void)goBack {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpNavBar];
    self.serviceShops = [[QIMKit sharedInstance] getSeatSeStatus];
    QIMVerboseLog(@"self.serviceShops : %@", self.serviceShops);
    [self.view addSubview:self.mainTableView];
    [self.view setBackgroundColor:[UIColor grayColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
