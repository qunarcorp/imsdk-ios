//
//  QIMColorfulBubblesController.m
//  qunarChatIphone
//
//  Created by chenjie on 15/7/17.
//
//

#import "QIMColorfulBubblesController.h"
#import "QIMColorfulBubbleCell.h"

@interface QIMColorfulBubblesController ()<UITableViewDataSource,UITableViewDelegate,QIMColorfulBubbleCellDelegate>
{
    UITableView         * _mainTableView;
}

@end

@implementation QIMColorfulBubblesController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initMainTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initMainTableView
{
    _mainTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.backgroundColor = [UIColor lightGrayColor];
    _mainTableView.dataSource = self;
    _mainTableView.delegate = self;
    [self.view addSubview:_mainTableView];
}

#pragma mark - UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * cellIdentifier = @"cell";
    QIMColorfulBubbleCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[QIMColorfulBubbleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.contentView.backgroundColor = [UIColor blueColor];
        cell.backgroundColor = [UIColor clearColor];
        cell.backgroundView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    [cell setBubbles:@[[UIImage imageNamed:[NSString stringWithFormat:@"balloon_left_%@",@(indexPath.row * 2 + 1)]],[UIImage imageNamed:[NSString stringWithFormat:@"balloon_left_%@",@(indexPath.row * 2 + 2)]]]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

#pragma mark - QIMColorfulBubbleCellDelegate

-(void)colorfulBubbleCell:(QIMColorfulBubbleCell *)cell didSelectedBubbleAtIndex:(NSInteger)index
{
    
}


@end
