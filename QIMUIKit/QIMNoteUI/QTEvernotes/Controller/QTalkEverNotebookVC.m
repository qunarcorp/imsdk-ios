//
//  QTalkEverNotebookVC.m
//  Text
//
//  Created by lihuaqi on 2017/9/19.
//  Copyright © 2017年 lihuaqi. All rights reserved.
//

#import "QTalkEverNotebookVC.h"
#import "QTalkEverNoteListVC.h"
#import <SCLAlertView-Objective-C/SCLAlertView.h>
#import "QIMNoteManager.h"
#import "QIMNoteModel.h"
#import "QTNotebookCell.h"
#import "QIMNoteUICommonFramework.h"

typedef enum {
    ENUM_Notebook_OptionTypeNew = 0,//新建操作
    ENUM_Notebook_OptionTypeEdit,//编辑
    ENUM_Notebook_OptionTypeDelete//删除
} ENUM_Notebook_OptionType;

@interface QTalkEverNotebookVC () <UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) UIButton *rightBtn;//新建按钮
@property(nonatomic, strong) UITableView *tableView;//笔记本列表
@property(nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation QTalkEverNotebookVC
- (void)getLocalEverNotes {
    self.dataSource = [NSMutableArray arrayWithCapacity:1];
    NSArray *array = [[QIMNoteManager sharedInstance] getMainItemWithType:QIMNoteTypeEverNote WithExceptState:QIMNoteStateDelete];
    [self.dataSource addObjectsFromArray:array];
    [self.tableView reloadData];
}

- (void)getRemoteEverNotes {
    NSInteger version = [[QIMNoteManager sharedInstance] getQTNoteMainItemMaxTimeWithType:QIMNoteTypeEverNote];
    [[QIMNoteManager sharedInstance] getCloudRemoteMainWithVersion:version WithType:QIMNoteTypeEverNote];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getRemoteEverNotes];
    
    [self getLocalEverNotes];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self topbar];
    [self createUI];
    [self registerNotification];
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getLocalEverNotes) name:QTNoteManagerGetCloudMainSuccessNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)topbar {
    self.title = @"笔记本";
    
    _rightBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    _rightBtn.frame = CGRectMake(0,0, 50, 25);
    _rightBtn.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_rightBtn setTitle:@"新建" forState:UIControlStateNormal];
    [_rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButton=[[UIBarButtonItem alloc]initWithCustomView:_rightBtn];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void)rightBtnAction {
    [self alertViewWithNotebookOptionType:ENUM_Notebook_OptionTypeNew evernoteModel:nil];
}

- (void)createUI {
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-64) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc]init];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QIMNoteModel *evernoteModel = self.dataSource[indexPath.row];
    QTNotebookCell *cell = [QTNotebookCell cellWithTableView:tableView];
    [cell refreshCellWithModel:evernoteModel];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 88;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *evernoteModel = self.dataSource[indexPath.row];
    QTalkEverNoteListVC *vc = [[QTalkEverNoteListVC alloc] init];
    vc.evernoteModel = evernoteModel;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 *  左滑cell时出现什么按钮
 */
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMNoteModel *evernoteModel = self.dataSource[indexPath.row];
    
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self alertViewWithNotebookOptionType:ENUM_Notebook_OptionTypeEdit evernoteModel:evernoteModel];
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self alertViewWithNotebookOptionType:ENUM_Notebook_OptionTypeDelete evernoteModel:evernoteModel];
    }];
    
    return @[action1, action0];
}

//新建,编辑或者删除笔记本
- (void)alertViewWithNotebookOptionType:(ENUM_Notebook_OptionType)optionType evernoteModel:(QIMNoteModel *)model{
    
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.horizontalButtons = YES;
    alert.shouldDismissOnTapOutside = YES;
    alert.customViewColor = [UIColor qim_colorWithHex:0x22B573 alpha:1.0];
    
    SCLButton *cancelBtn = [alert addButton:@"取消" actionBlock:^(void) {}];
    cancelBtn.buttonFormatBlock = ^NSDictionary* (void) {
        NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
        buttonConfig[@"backgroundColor"] = [UIColor redColor];
        buttonConfig[@"textColor"] = [UIColor whiteColor];
        return buttonConfig;
    };
    
    if (optionType == ENUM_Notebook_OptionTypeNew) {
        UITextField *nameTF = [alert addTextField:@"笔记本的名字(不可为空)"];
        UITextField *descriptionTF = [alert addTextField:@"笔记本的描述"];
        [alert addButton:@"确认" validationBlock:^BOOL {
            BOOL passedValidation = NO;
            if (nameTF.text.length == 0) {
                passedValidation = NO;
            }else if (nameTF.text.length >20) {
                passedValidation = NO;
            }else {
                passedValidation = YES;
            }
            return passedValidation;
        } actionBlock:^{
            QIMVerboseLog(@"新建笔记本：%@--%@",nameTF.text,descriptionTF.text);
            QIMNoteModel *evernoteModel = [[QIMNoteModel alloc] init];
            evernoteModel.c_id = ((evernoteModel.c_id > 0) && evernoteModel.c_id) ? evernoteModel.c_id : [[QIMNoteManager sharedInstance] getMaxQTNoteMainItemCid] + 1;
            evernoteModel.q_title = nameTF.text;
            evernoteModel.q_introduce = descriptionTF.text?descriptionTF.text:@"";
            evernoteModel.q_type = QIMNoteTypeEverNote;
            evernoteModel.q_state = QIMNoteStateNormal;
            if (evernoteModel.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
                evernoteModel.q_ExtendedFlag = QIMNoteExtendedFlagStateLocalModify;
            } else {
                evernoteModel.q_ExtendedFlag = QIMNoteExtendedFlagStateLocalCreated;
            }
            if (!evernoteModel.q_time) {
                evernoteModel.q_time = [[NSDate date] timeIntervalSince1970];
            }
            [[QIMNoteManager sharedInstance] saveNewQTNoteMainItem:evernoteModel];
            
            [self getLocalEverNotes];
        }];
        [alert showEdit:self title:@"提示" subTitle:@"新建笔记本" closeButtonTitle:nil duration:0.0f];
        
    }else if (optionType == ENUM_Notebook_OptionTypeEdit) {
        if (model) {
            UITextField *nameTF = [alert addTextField:@"笔记本的名字(不可为空)"];
            UITextField *descriptionTF = [alert addTextField:@"笔记本的描述"];
            nameTF.text = [NSString stringWithFormat:@"%@",model.q_title];
            descriptionTF.text = [NSString stringWithFormat:@"%@",model.q_introduce];
            
            [alert addButton:@"确认" validationBlock:^BOOL {
                BOOL passedValidation = NO;
                if (nameTF.text.length == 0) {
                    passedValidation = NO;
                }else if (nameTF.text.length >20) {
                    passedValidation = NO;
                }else {
                    passedValidation = YES;
                }
                return passedValidation;
            } actionBlock:^{
                QIMVerboseLog(@"编辑笔记本：%@--%@",nameTF.text,descriptionTF.text);
                if ( model.q_title != nameTF.text || model.q_introduce != descriptionTF.text) {
                    model.q_title = nameTF.text;
                    model.q_introduce = descriptionTF.text;
                    [[QIMNoteManager sharedInstance] updateQTNoteMainItemWithModel:model];
                }
                [self getLocalEverNotes];
            }];
            [alert showEdit:self title:@"提示" subTitle:@"编辑笔记本" closeButtonTitle:nil duration:0.0f];
        }
    }else if (optionType == ENUM_Notebook_OptionTypeDelete) {
        if (model) {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            alert.horizontalButtons = YES;
            alert.shouldDismissOnTapOutside = YES;
            alert.customViewColor = [UIColor qim_colorWithHex:0x22B573 alpha:1.0];
            
            SCLButton *cancelBtn = [alert addButton:@"取消" actionBlock:^(void) {}];
            cancelBtn.buttonFormatBlock = ^NSDictionary* (void) {
                NSMutableDictionary *buttonConfig = [[NSMutableDictionary alloc] init];
                buttonConfig[@"backgroundColor"] = [UIColor redColor];
                buttonConfig[@"textColor"] = [UIColor whiteColor];
                return buttonConfig;
            };
            
            [alert addButton:@"确定" actionBlock:^(void) {
                [[QIMNoteManager sharedInstance] deleteQTNoteMainItemWithModel:model];
                [self getLocalEverNotes];
            }];
            [alert showWarning:@"提示" subTitle:@"确定要删除此笔记本吗？此笔记本中的任何笔记都将被删除" closeButtonTitle:nil duration:0.0f];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]){
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
