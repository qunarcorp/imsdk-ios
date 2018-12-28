//
//  NewAddTodoListVc.m
//  qunarChatIphone
//
//  Created by 李露 on 2017/7/27.
//
//

#import "NewAddTodoListVc.h"
#import "QIMWSDatePickerView.h"
#import "QIMNoteUICommonFramework.h"

@interface NewAddTodoListVc () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *addNewTodoListField;

@property (nonatomic, strong) UIButton *clockBtn;

@property (nonatomic, strong) QIMNoteModel *todoListModel;

@property (nonatomic, strong) NSMutableArray *randomTexts;

@property (nonatomic, assign) BOOL Edited;

@end

@implementation NewAddTodoListVc

- (void)setEdited:(BOOL)edited {
    _Edited = edited;
}

- (void)setTodoListModel:(QIMNoteModel *)model {
    if (model) {
        _todoListModel = model;
    }
}

- (NSMutableArray *)randomTexts {
    if (!_randomTexts) {
        _randomTexts = [NSMutableArray arrayWithCapacity:50];
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"random" ofType:@"plist"];
        NSArray *randomDicts = [[NSArray alloc] initWithContentsOfFile:bundlePath];
        for (NSDictionary *dict in randomDicts) {
            NSString *randomTextStr = @"";
            if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"zh-Hant"]) {
                randomTextStr = [dict objectForKey:@"zh-Hant"];
                [_randomTexts addObject:randomTextStr];
            } else if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"en"]) {
                randomTextStr = [dict objectForKey:@"en"];
                [_randomTexts addObject:randomTextStr];
            } else if ([[[QIMKit sharedInstance] currentLanguage] containsString:@"zh-Hans"]) {
                randomTextStr = [dict objectForKey:@"zh-Hans"];
                [_randomTexts addObject:randomTextStr];
            }
        }
    }
    return _randomTexts;
}

- (UITextField *)addNewTodoListField {
    if (!_addNewTodoListField) {
        _addNewTodoListField = [[UITextField alloc] initWithFrame:CGRectMake(20, 30, self.view.width - 80, 30)];
        NSDictionary *attributedPlaceholderDict = @{NSForegroundColorAttributeName : [UIColor qunarTextGrayColor]};
        _addNewTodoListField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:[NSBundle qim_localizedStringForKey:@"todolist_think"] attributes:attributedPlaceholderDict];
        _addNewTodoListField.borderStyle = UITextBorderStyleRoundedRect;
        _addNewTodoListField.font = [UIFont systemFontOfSize:14];
        _addNewTodoListField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_addNewTodoListField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        if (_Edited) {
            _addNewTodoListField.text = self.todoListModel.q_title;
        }
    }
    return _addNewTodoListField;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.addNewTodoListField];
    self.clockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.clockBtn.frame = CGRectMake(_addNewTodoListField.right + 2, 20, 40, 40);
    if (_Edited) {
        [self.clockBtn setImage:[UIImage imageNamed:@"clock_16x14_"] forState:UIControlStateNormal];
    } else {
        [self.clockBtn setImage:[UIImage imageNamed:@"随机_13x12_"] forState:UIControlStateNormal];
    }
    self.clockBtn.centerY = self.addNewTodoListField.centerY;
    [self.clockBtn addTarget:self action:@selector(randomTextField:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.clockBtn];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(self.addNewTodoListField.left, self.addNewTodoListField.bottom + 8, self.clockBtn.right - self.addNewTodoListField.left, 0.5)];
    lineView.backgroundColor = [UIColor darkGrayColor];
    lineView.alpha = 0.5;
    [self.view addSubview:lineView];
    [self.addNewTodoListField becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.addNewTodoListField.text.length > 0) {
        if (!self.todoListModel) {
            self.todoListModel = [[QIMNoteModel alloc] init];
        }
        QIMVerboseLog(@"saveTodoList");
        [self saveTodoList];
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.addNewTodoListField resignFirstResponder];
    } completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField == self.addNewTodoListField) {
        [self updateClockBtnAction];
    }
}

- (void)updateClockBtnAction {
    if (self.addNewTodoListField.text.length > 0) {
        [self.clockBtn setImage:[UIImage imageNamed:@"clock_16x14_"] forState:UIControlStateNormal];
        [self.clockBtn removeTarget:self action:@selector(randomTextField:) forControlEvents:UIControlEventTouchUpInside];
        [self.clockBtn addTarget:self action:@selector(setRemindTime:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.clockBtn setImage:[UIImage imageNamed:@"随机_13x12_"] forState:UIControlStateNormal];
        [self.clockBtn removeTarget:self action:@selector(setRemindTime:) forControlEvents:UIControlEventTouchUpInside];
        [self.clockBtn addTarget:self action:@selector(randomTextField:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)randomTextField:(id)sender {
    int random = arc4random() % self.randomTexts.count;
    if (self.randomTexts.count > 0) {
        NSString *str = [self.randomTexts objectAtIndex:random];
        if (str.length > 0) {
            self.addNewTodoListField.text = str;
            [self updateClockBtnAction];
        }
    }
}

- (void)setRemindTime:(id)sender {
    [self.addNewTodoListField resignFirstResponder];
    __weak typeof(self) weakSelf = self;
    QIMWSDatePickerView *datePicker = [[QIMWSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDayHourMinute CompleteBlock:^(NSDate *completeDate) {
        NSTimeInterval completeTime = [completeDate timeIntervalSince1970];
        if (!weakSelf.todoListModel) {
            weakSelf.todoListModel = [[QIMNoteModel alloc] init];
        }
        NSDictionary *dict = @{@"completeTime":@(completeTime)};
        NSString *str = [[QIMJSONSerializer sharedInstance] serializeObject:dict];
        weakSelf.todoListModel.q_content = str;
        weakSelf.todoListModel.q_time = [[NSDate date] timeIntervalSince1970];
        [weakSelf saveTodoList];
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    datePicker.doneButtonColor = [UIColor orangeColor];//确定按钮的颜色
    [datePicker show];
}

/**
 保存TodoList Model
 */
- (void)saveTodoList {
    
    self.todoListModel.c_id = ((self.todoListModel.c_id > 0) && self.todoListModel.c_id) ? self.todoListModel.c_id : [[QIMNoteManager sharedInstance] getMaxQTNoteSubItemCSid] + 1;
    self.todoListModel.q_title = self.addNewTodoListField.text ? self.addNewTodoListField.text : [NSBundle qim_localizedStringForKey:@"todolist_think"];
    self.todoListModel.q_type = QIMNoteTypeTodoList;
    self.todoListModel.q_state = QIMNoteStateNormal;
    if (self.todoListModel.q_ExtendedFlag == QIMNoteExtendedFlagStateLocalCreated) {
        self.todoListModel.q_ExtendedFlag = QIMNoteExtendedFlagStateLocalModify;
    } else {
        self.todoListModel.q_ExtendedFlag = QIMNoteExtendedFlagStateLocalCreated;
    }
    if (!self.todoListModel.q_time) {
        self.todoListModel.q_time = [[NSDate date] timeIntervalSince1970];
    }
    [[QIMNoteManager sharedInstance] saveNewQTNoteMainItem:self.todoListModel];
}

@end
