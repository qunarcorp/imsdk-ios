//
//  QIMPushProductViewController.m
//  qunarChatIphone
//
//  Created by chenjie on 16/1/26.
//
//

#define kMainTableViewHeaderHeight  70

#import "QIMPushProductViewController.h"
#import "QIMPushProductCell.h"
#import "QIMJSONSerializer.h"
#import "MBProgressHUD.h"
#import "NSBundle+QIMLibrary.h"

@interface QIMPushProductViewController ()<UITableViewDataSource,UITableViewDelegate,QIMPushProductCellDelegate>
{
    UITableView             * _mainTableView;
    UITextField             * _searchTextField;
    UIButton                * _searchBtn;
    
    NSMutableArray          * _dataSource;
    
    MBProgressHUD          * _HUDView;
}
@end

@implementation QIMPushProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = [NSBundle qim_localizedStringForKey:@"send_custom_pruduct"];
    
    [self setUpMainTableView];
    
    [_searchTextField becomeFirstResponder];
}

- (void)setUpMainTableView{
    if (_mainTableView == nil) {
        _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mainTableView.backgroundColor = [UIColor qtalkChatBgColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        [self.view addSubview:_mainTableView];
        
        [self setUpHeader];
    }
}

- (void)setUpHeader{
    UIView * header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kMainTableViewHeaderHeight)];
    header.backgroundColor = [UIColor whiteColor];
    [_mainTableView setTableHeaderView:header];
    
    if (_searchTextField == nil) {
        _searchTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, (header.height - 30) / 2, self.view.width - 70 - 15, 30)];
        _searchTextField.backgroundColor = [UIColor qtalkTableDefaultColor];
        _searchTextField.textColor = [UIColor qtalkTextBlackColor];
        _searchTextField.placeholder = [NSBundle qim_localizedStringForKey:@"check_product_please_input_name"];
        _searchTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        [header addSubview:_searchTextField];
    }
    
    if (_searchBtn == nil) {
        _searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchBtn setTitle:[NSBundle qim_localizedStringForKey:@"check_product"] forState:UIControlStateNormal];
        [_searchBtn setTitleColor:[UIColor qtalkIconSelectColor] forState:UIControlStateNormal];
        _searchBtn.frame = CGRectMake(_searchTextField.right + 10, _searchTextField.top + 5, 45, 20);
        [_searchBtn addTarget:self action:@selector(searchBtnHandle:) forControlEvents:UIControlEventTouchUpInside];
        [header addSubview:_searchBtn];
    }
}


#pragma mark - action

-(void)searchBtnHandle:(id)sender{
    if (_searchTextField.text.length == 0) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"产品Id不能为空！" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    [_searchTextField resignFirstResponder];
    
    if (_HUDView == nil) {
        _HUDView = [[MBProgressHUD alloc] initWithView:self.view];
        _HUDView.minSize = CGSizeMake(120, 120);
        _HUDView.minShowTime = 1;
        [self.view addSubview:_HUDView];
    }
    [_HUDView setLabelText:@""];
    [_HUDView setDetailsLabelText:@"正在查询..."];
    [_HUDView show:YES];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/api/pdt/productDtl.qunar?pdtId=%@&line=%@",@"https://qcadmin.qunar.com",_searchTextField.text,@"dujia"]];
        ASIHTTPRequest *request = [[ASIHTTPRequest alloc] initWithURL:url];
        [request addRequestHeader:@"Content-type" value:@"application/x-www-form-urlencoded;"];
        [request setRequestMethod:@"POST"];
        [request startSynchronous];
        
        NSError *error = [request error];
        if (([request responseStatusCode] == 200) && !error) {
            NSDictionary *infoDic = [[QIMJSONSerializer sharedInstance] deserializeObject:request.responseData error:nil];
            BOOL ret = [[infoDic objectForKey:@"ret"] boolValue];
            if (ret) {
                _dataSource = [NSMutableArray arrayWithObject:[infoDic objectForKey:@"data"]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_mainTableView reloadData];
                    [_HUDView hide:YES];
                });
            }
        } 
    });
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [QIMPushProductCell getCellHeight];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMPushProductCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[QIMPushProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.delegate = self;
    }
    [cell setCellInfo:_dataSource[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - QIMPushProductCellDelegate

- (void)sendBtnClickedForCell:(QIMPushProductCell *)cell{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendProductInfoStr:productDetailUrl:)]) {
        NSDictionary * infoDic = @{@"data":[_dataSource objectAtIndex:[_mainTableView indexPathForCell:cell].row]};
        [self.delegate sendProductInfoStr:[[QIMJSONSerializer sharedInstance] serializeObject:infoDic] productDetailUrl:[NSString stringWithFormat:@"[obj type=\"url\" value=\"%@\"]",[infoDic[@"data"] objectForKey:@"touchDtlUrl"]]];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
