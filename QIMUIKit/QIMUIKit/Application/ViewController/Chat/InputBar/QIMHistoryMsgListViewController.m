//
//  QIMHistoryMsgListViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/7.
//
//

#import "QIMHistoryMsgListViewController.h"
#import "QIMHistoryMsgManager.h"
@interface QIMHistoryMsgListViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView         * _mainTableView;
    NSArray             * _dataSource;
}
@end

@implementation QIMHistoryMsgListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _dataSource = [[QIMHistoryMsgManager sharedInstance] getMsgHistoryList];
    
    [self setNavBar];
    [self setUpTableView];
}


- (void)setUpTableView{
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
//        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [self.view addSubview:_mainTableView];
    }
}

- (void)setNavBar{
    self.navigationItem.title = @"我的消息历史";
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(leftItemHandle:)];
    [self.navigationItem setLeftBarButtonItem:leftItem];
}

- (void)leftItemHandle:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDataSource,UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGSize size = [_dataSource[indexPath.row] qim_sizeWithFontCompatible:[UIFont systemFontOfSize:15] forWidth:MAXFLOAT lineBreakMode:NSLineBreakByCharWrapping];
    return ceilf(size.width / (tableView.width - 30)) * 20 + 20;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * identifier = @"historyListCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    }
    cell.textLabel.text = _dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(QIMHistoryMsgListViewController:didSelectedText:)]) {
        [self.delegate QIMHistoryMsgListViewController:self didSelectedText:_dataSource[indexPath.row]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
