//
//  QIMWorkMomentPushViewController.m
//  QIMUIKit
//
//  Created by lilu on 2019/1/2.
//  Copyright © 2019 QIM. All rights reserved.
//

#import "QIMWorkMomentPushViewController.h"
#import "QTImagePickerController.h"
#import "QIMAuthorizationManager.h"
#import "QTPHImagePickerManager.h"
#import "QTPHImagePickerController.h"
#import "QIMWorkMomentUserIdentityVC.h"
#import "UIApplication+QIMApplication.h"
#import "QTalkTextView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "QIMCollectionEmotionPanView.h"
#import "QIMWorkMomentPanelModel.h"
#import "QIMImageUtil.h"
#import "QIMStringTransformTools.h"
#import "QIMWorkMomentPushCell.h"
#import "QIMMWPhotoBrowser.h"
#import "QIMPhotoBrowserNavController.h"
#import "QIMWorkMomentUserIdentityModel.h"
#import "QIMWorkMomentModel.h"
#import "QIMUUIDTools.h"
#import "YYModel.h"
#import "MBProgressHUD.h"
#import "QIMProgressHUD.h"

@interface QIMWorkMomentPushUserIdentityCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *textLab;

@end

@implementation QIMWorkMomentPushUserIdentityCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundView = nil;
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.selectedBackgroundView = nil;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 9, 32, 32)];
    self.iconView.layer.cornerRadius = 16.0f;
    self.iconView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.iconView];
    
    self.textLab = [[UILabel alloc] init];
    self.textLab.textColor = [UIColor qim_colorWithHex:0x333333];
    self.textLab.font = [UIFont systemFontOfSize:15];
    self.textLab.adjustsFontSizeToFitWidth = YES;
    [self.contentView addSubview:self.textLab];
    [self.textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_offset(18);
        make.left.mas_equalTo(self.iconView.mas_right).offset(10);
        make.bottom.mas_offset(-18);
    }];
}

@end

@interface QIMWorkMomentPushViewController () <QTPHImagePickerControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, QIMDragCellCollectionViewDelegate, QIMDragCellCollectionViewDataSource, UITableViewDelegate, UITableViewDataSource, QIMMWPhotoBrowserDelegate, QIMWorkMomentPushCellDeleteDelegate, UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) QIMCollectionEmotionPanView *photoCollectionView;

@property (nonatomic, strong) UITableView *panelListView;

@property (nonatomic, strong) NSMutableArray *workmomentPushPanelModels;

@property (nonatomic, strong) UIButton *pushBtn;

@property (nonatomic, strong) NSMutableArray *selectPhotos;

@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSString *momentId;

@end

@implementation QIMWorkMomentPushViewController

- (MBProgressHUD *)progressHUD {
    if (!_progressHUD) {
        _progressHUD = [[MBProgressHUD alloc] initWithView:self.photoCollectionView];
        _progressHUD.minSize = CGSizeMake(120, 120);
        _progressHUD.minShowTime = 1;
        [self.photoCollectionView addSubview:_progressHUD];
    }
    return _progressHUD;
}

- (void)showProgressHUDWithMessage:(NSString *)message {
    self.progressHUD.hidden = NO;
    self.progressHUD.labelText = message;
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self.progressHUD show:YES];
    self.navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)hideProgressHUD:(BOOL)animated {
    [self.progressHUD hide:animated];
    self.navigationController.navigationBar.userInteractionEnabled = YES;
}

#pragma mark - setter and getter

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 150)];
        _textView.backgroundColor = [UIColor whiteColor];
        [_textView setFont:[UIFont systemFontOfSize:17]];
        [_textView setTextColor:[UIColor qim_colorWithHex:0x333333]];
        [_textView setTintColor:[UIColor qim_colorWithHex:0x333333]];
        
        UILabel *placeHolderLabel = [[UILabel alloc] init];
        placeHolderLabel.text = @"来吧，尽情发挥吧…";
        placeHolderLabel.numberOfLines = 0;
        placeHolderLabel.textColor = [UIColor qim_colorWithHex:0xBFBFBF];
        [placeHolderLabel sizeToFit];
        [_textView addSubview:placeHolderLabel];
        // same font
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.3) {
            [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
        }
    }
    return _textView;
}

- (QIMCollectionEmotionPanView *)photoCollectionView {
    if (!_photoCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat cellHeight = (SCREEN_WIDTH - 75) / 3;
        CGFloat cellWidth = (SCREEN_WIDTH - 75) / 3;
        
        layout.itemSize = CGSizeMake(cellWidth, cellHeight);
        layout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 25);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.headerReferenceSize = CGSizeMake(0, 180);
        layout.footerReferenceSize = CGSizeMake(0, 300);
        // 水平间隔
        layout.minimumInteritemSpacing = 15.0f;
        // 上下垂直间隔
        layout.minimumLineSpacing = 15.0f;
        
        _photoCollectionView = [[QIMCollectionEmotionPanView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        [_photoCollectionView registerClass:[QIMWorkMomentPushCell class] forCellWithReuseIdentifier:@"cellId"];
        [_photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView"];
        [_photoCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView"];
        _photoCollectionView.delegate = self;
        _photoCollectionView.dataSource = self;
        _photoCollectionView.qimDragDelegate = self;
        _photoCollectionView.qimDragDataSource = self;
        _photoCollectionView.shakeLevel = 0.1f;
        _photoCollectionView.shakeWhenMoveing = YES;
        _photoCollectionView.isOpenMove = YES;
        if (@available(iOS 11.0, *)) {
            _photoCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _photoCollectionView.showsVerticalScrollIndicator = NO;
        _photoCollectionView.backgroundColor = [UIColor whiteColor];
        _photoCollectionView.alwaysBounceVertical = YES;
    }
    return _photoCollectionView;
}

- (UITableView *)panelListView {
    if (!_panelListView) {
        _panelListView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 500) style:UITableViewStylePlain];
        _panelListView.backgroundColor = [UIColor qim_colorWithHex:0xf8f8f8];
        _panelListView.delegate = self;
        _panelListView.dataSource = self;
        _panelListView.estimatedRowHeight = 0;
        _panelListView.estimatedSectionHeaderHeight = 0;
        _panelListView.estimatedSectionFooterHeight = 0;
        CGRect tableHeaderViewFrame = CGRectMake(0, 0, 0, 0.0001f);
        _panelListView.tableFooterView = [UIView new];
        _panelListView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);           //top left bottom right 左右边距相同
        _panelListView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _panelListView.bounces = NO;
        _panelListView.scrollEnabled = NO;
    }
    return _panelListView;
}

- (NSMutableArray *)workmomentPushPanelModels {
    if (!_workmomentPushPanelModels) {
        _workmomentPushPanelModels = [NSMutableArray arrayWithCapacity:3];
        QIMWorkMomentPanelModel *model1 = [[QIMWorkMomentPanelModel alloc] init];
        model1.icon = @"";
        model1.title = @"发帖身份";
        [_workmomentPushPanelModels addObject:model1];
        
        /*
        QIMWorkMomentPanelModel *model2 = [[QIMWorkMomentPanelModel alloc] init];
        model2.icon = @"";
        model2.title = @"发起活动";
        [_workmomentPushPanelModels addObject:model2];
        
        QIMWorkMomentPanelModel *model3 = [[QIMWorkMomentPanelModel alloc] init];
        model3.icon = @"";
        model3.title = @"发起投票";
        [_workmomentPushPanelModels addObject:model3];
        */
    }
    return _workmomentPushPanelModels;
}

- (NSMutableArray *)selectPhotos {
    if (!_selectPhotos) {
        _selectPhotos = [NSMutableArray arrayWithCapacity:1];
        [_selectPhotos addObject:@"Q_Work_Add"];
    }
    return _selectPhotos;
}

- (void)beginSortSelectPhotos {
    NSString * item = self.selectPhotos.lastObject;
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    [self.photoCollectionView reloadData];
}

- (void)updateSelectPhotos {
    
    if (self.selectPhotos.count >= 9) {
        //新增图片之后>=9，移除➕
        [self.selectPhotos removeObject:@"Q_Work_Add"];
    } else {
        //新增图片之后<9，新增➕
        
        NSInteger maxCount = 9 - self.selectPhotos.count;
        [[QTPHImagePickerManager sharedInstance] setMaximumNumberOfSelection:maxCount];
        [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:YES];
        [self.selectPhotos addObject:@"Q_Work_Add"];
    }
    [self.photoCollectionView reloadData];
}

#pragma mark - life ctyle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.panelListView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)setupNav {

    self.navigationItem.title = @"发布动态";
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:19],NSForegroundColorAttributeName:[UIColor qim_colorWithHex:0x333333]}];
    UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [[self navigationItem] setLeftBarButtonItem:cancelBtn];
    UIBarButtonItem *newMomentBtn = [[UIBarButtonItem alloc] initWithCustomView:self.pushBtn];
    [[self navigationItem] setRightBarButtonItem:newMomentBtn];
}

- (UIButton *)pushBtn {
    if (!_pushBtn) {
        _pushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushBtn setFrame:CGRectMake(0, 0, 36, 18)];
        [_pushBtn setTitle:@"发布" forState:UIControlStateNormal];
        [_pushBtn setTitle:@"发布" forState:UIControlStateDisabled];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0xBFBFBF] forState:UIControlStateDisabled];
        [_pushBtn setTitleColor:[UIColor qim_colorWithHex:0x00CABE] forState:UIControlStateNormal];
        [_pushBtn addTarget:self action:@selector(pushNewMoment:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pushBtn;
}

- (void)setupUI {
    [self.view addSubview:self.photoCollectionView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.photoCollectionView addSubview:_progressHUD];
    _progressHUD.hidden = YES;
    [[QTPHImagePickerManager sharedInstance] setMaximumNumberOfSelection:9];
    [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor qim_colorWithHex:0xF7F7F7];
    self.view.backgroundColor = [UIColor qim_colorWithHex:0xF3F3F5];
    [self setupNav];
    [self setupUI];
    self.momentId = [NSString stringWithFormat:@"0-%@", [QIMUUIDTools UUID]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)onPhotoButtonClick:(UIButton *)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
       [self.view endEditing:YES];
    });
    [QIMAuthorizationManager sharedManager].authorizedBlock = ^{
        QTPHImagePickerController *picker = [[QTPHImagePickerController alloc] init];
        picker.delegate = self;
        picker.title = @"选取照片";
        picker.customDoneButtonTitle = @"";
        picker.customCancelButtonTitle = @"取消";
        picker.customNavigationBarPrompt = nil;
        
        picker.colsInPortrait = 4;
        picker.colsInLandscape = 5;
        picker.minimumInteritemSpacing = 2.0;
        [[[UIApplication sharedApplication] visibleViewController] presentViewController:picker animated:YES completion:nil];
    };
    [[QIMAuthorizationManager sharedManager] requestAuthorizationWithType:ENUM_QAM_AuthorizationTypePhotos];
}

- (void)goBack:(id)sender {
    [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
    [[QTPHImagePickerManager sharedInstance] setNotAllowSelectVideo:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)pushNewMoment:(id)sender {
    QIMVerboseLog(@"发布了一条新动态");
    
    BOOL selectPhoto = (self.selectPhotos.count == 1) && ([[self.selectPhotos firstObject] isEqualToString:@"Q_Work_Add"]);
    
    if (self.textView.text.length <= 0 && selectPhoto)  {
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"提示" message:@"请尽情发挥吧..." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVc addAction:okAction];
        [self.navigationController presentViewController:alertVc animated:YES completion:nil];
    } else {
        [self showProgressHUDWithMessage:@"动态上传中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showProgressHUDWithMessage:@"动态上传中..."];
            NSMutableDictionary *momentDic = [NSMutableDictionary dictionaryWithCapacity:3];
            [momentDic setObject:self.momentId forKey:@"uuid"];
            [momentDic setObject:[QIMKit getLastUserName] forKey:@"owner"];
            [momentDic setObject:[[QIMKit sharedInstance] getDomain] forKey:@"ownerHost"];
            [momentDic setObject:@([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous]) forKey:@"isAnonymous"];
            if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
                [momentDic setObject:@"" forKey:@"AnonymousName"];
                [momentDic setObject:@"" forKey:@"AnonymousPhoto"];
            } else {
                [momentDic setObject:[[QIMWorkMomentUserIdentityManager sharedInstance] anonymousName] forKey:@"AnonymousName"];
                [momentDic setObject:[[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto] forKey:@"AnonymousPhoto"];
            }
            
            NSMutableDictionary *momentContentDic = [[NSMutableDictionary alloc] initWithCapacity:3];
            [momentContentDic setQIMSafeObject:self.textView.text forKey:@"content"];
            NSMutableArray *imageList = [[NSMutableArray alloc] init];
            dispatch_group_t group = dispatch_group_create();
            for (id imageData in self.selectPhotos) {
                if ([imageData isKindOfClass:[NSData class]]) {
                    dispatch_group_enter(group);
                    NSString *fileUrl = [QIMKit updateLoadFile:imageData WithMsgId:[QIMUUIDTools UUID] WithMsgType:QIMMessageType_Image WihtPathExtension:@"png"];
                    if (fileUrl.length > 0) {
                        NSDictionary *imageDic = @{@"addTime":@(0), @"data":fileUrl};
                        [imageList addObject:imageDic];
                        dispatch_group_leave(group);
                    }
                }
            }
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                
                [momentContentDic setQIMSafeObject:imageList forKey:@"imgList"];
                NSString *momentContent = [[QIMJSONSerializer sharedInstance] serializeObject:momentContentDic];
                [momentDic setObject:momentContent forKey:@"content"];
                QIMVerboseLog(@"momentContentDic : %@", momentContentDic);
                QIMVerboseLog(@"imageList : %@", imageList);
                [[QIMKit sharedInstance] pushNewMomentWithMomentDic:momentDic];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[QIMProgressHUD sharedInstance] closeHUD];
                });
                [self goBack:nil];
            });
        });
    }
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDatasource

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.textView resignFirstResponder];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectPhotos.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkMomentPushCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellId" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.backgroundColor = [UIColor whiteColor];
    id photoData = [self.selectPhotos objectAtIndex:indexPath.row];
    cell.dDelegate = self;
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:cell.bounds];
    iconView.contentMode = UIViewContentModeScaleAspectFill;
    iconView.layer.cornerRadius = 2.4f;
    iconView.layer.masksToBounds = YES;
    if ([photoData isKindOfClass:[NSString class]]) {
        if ([photoData isEqualToString:@"Q_Work_Add"]) {
            iconView.image = [UIImage imageNamed:@"q_work_add"];
            iconView.backgroundColor = [UIColor whiteColor];
            [cell.contentView addSubview:iconView];
            [cell setCanDelete:NO];
        }
    } else {
        iconView.image = [UIImage imageWithData:photoData];
        [cell.contentView addSubview:iconView];
        [cell setCanDelete:YES];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    id photoData = [self.selectPhotos objectAtIndex:indexPath.row];
    if ([photoData isKindOfClass:[NSString class]]) {
        if ([photoData isEqualToString:@"Q_Work_Add"]) {
            QIMVerboseLog(@"进去选图界面");
            [self onPhotoButtonClick:nil];
        }
    } else {
        //初始化图片浏览控件
        QIMMWPhotoBrowser *browser = [[QIMMWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = NO;
        browser.zoomPhotosToFill = YES;
        browser.enableSwipeToDismiss = NO;
        [browser setCurrentPhotoIndex:indexPath.row];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
        browser.wantsFullScreenLayout = YES;
#endif
        
        //初始化navigation
        QIMPhotoBrowserNavController *nc = [[QIMPhotoBrowserNavController alloc] initWithRootViewController:browser];
        nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"HeaderView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor whiteColor];
        [headerView addSubview:self.textView];
        return headerView;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        headerView.backgroundColor = [UIColor qim_colorWithHex:0xF8F8F8];
        [headerView addSubview:self.panelListView];
        return headerView;
    } else {
        return nil;
    }
}

#pragma mark - QIMDragCellCollectionViewDelegate, QIMDragCellCollectionViewDataSource

- (NSArray *)dataSourceArrayOfCollectionView:(QIMCollectionEmotionPanView *)collectionView{
    
    return _selectPhotos;
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray{
    
    [_selectPhotos removeAllObjects];
    [_selectPhotos addObjectsFromArray:newDataArray];
}

- (void)dragCellCollectionView:(QIMCollectionEmotionPanView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath{
    //拖动时候最后禁用掉编辑按钮的点击
}

- (void)dragCellCollectionViewCellEndMoving:(QIMCollectionEmotionPanView *)collectionView{
    
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.workmomentPushPanelModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    QIMWorkMomentPushUserIdentityCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
    if (!cell) {
        cell = [[QIMWorkMomentPushUserIdentityCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cellId"];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    QIMWorkMomentPanelModel *model = [self.workmomentPushPanelModels objectAtIndex:indexPath.row];
    cell.textLab.text = model.title;
    cell.iconView.contentMode = UIViewContentModeScaleAspectFill;
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        [cell.iconView qim_setImageWithJid:[[QIMKit sharedInstance] getLastJid]];
    } else {
        NSString *anonymousPhoto = [[QIMWorkMomentUserIdentityManager sharedInstance] anonymousPhoto];
        [cell.iconView qim_setImageWithURL:[NSURL URLWithString:anonymousPhoto]];
    }
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.textColor = [UIColor qim_colorWithHex:0x999999];
    if ([[QIMWorkMomentUserIdentityManager sharedInstance] isAnonymous] == NO) {
        cell.detailTextLabel.text = @"实名发布";
    } else {
        cell.detailTextLabel.text = @"匿名发布";
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QIMWorkMomentPanelModel *model = [self.workmomentPushPanelModels objectAtIndex:indexPath.row];
    NSString *modelId = model.title;
    if ([modelId isEqualToString:@"发帖身份"]) {
        QIMWorkMomentUserIdentityVC *identityVc = [[QIMWorkMomentUserIdentityVC alloc] init];
        identityVc.momentId = self.momentId;
        [self.navigationController pushViewController:identityVc animated:YES];
    } else if ([modelId isEqualToString:@""]) {
        
    } else {
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8.0f;
}

#pragma mark - QTPHImagePickerControllerDelegate

- (void)assetsPickerController:(QTPHImagePickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [self sendAssetList:[NSMutableArray arrayWithArray:assets] ForPickerController:picker];
}

-(void)assetsPickerController:(QTPHImagePickerController *)picker didFinishEditWithImage:(UIImage *)image
{
    NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    [self.selectPhotos addObject:imageData];
    [self updateSelectPhotos];
    [picker dismissViewControllerAnimated:NO completion:nil];
}

- (void)sendAssetList:(NSMutableArray *)assetList ForPickerController:(QTPHImagePickerController *)picker{
    PHCachingImageManager * imageManager = [[PHCachingImageManager alloc] init];
    
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    CGSize targetSize = picker.isOriginal ? PHImageManagerMaximumSize : screenSize;
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = false;
    
    __block PHAsset *asset = assetList.firstObject;
    [assetList removeObject:asset];
    if (asset) {
        if (asset.mediaType ==  PHAssetMediaTypeImage) {
            [self showProgressHUDWithMessage:@"图片处理中"];
            [imageManager requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                //gif 图片
                QIMVerboseLog(@"choose Image Url : %@", dataUTI);
                if ([dataUTI isEqualToString:(__bridge NSString *)kUTTypeGIF]) {
                    BOOL downloadFinined = (![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey]);
                    if (downloadFinined && imageData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.selectPhotos removeObject:@"Q_Work_Add"];
                            [self.selectPhotos addObject:imageData];
                            [self updateSelectPhotos];
                            [self hideProgressHUD:YES];
                        });
                    }
                } else if ([dataUTI isEqualToString:@"public.heic"] || [dataUTI isEqualToString:@"public.heif"]) {
                    CIImage *ciImage = [CIImage imageWithData:imageData];
                    CIContext *context = [CIContext context];
                    NSData *pngData = [context PNGRepresentationOfImage:ciImage format:kCIFormatARGB8 colorSpace:ciImage.colorSpace options:@{}];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.selectPhotos removeObject:@"Q_Work_Add"];
                        [self.selectPhotos addObject:pngData];
                        [self updateSelectPhotos];
                        [self hideProgressHUD:YES];
                    });
                } else {
                    BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey] && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                    if (downloadFinined) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage * imageFix = [QIMImageUtil fixOrientation:[UIImage imageWithData:imageData]];
                            if ((imageFix.size.width > 512 || imageFix.size.height > 512) && (!picker.isOriginal)) {
                                CGFloat height = (imageFix.size.height / imageFix.size.width) * 512;
                                imageFix = [imageFix qim_imageByScalingAndCroppingForSize:CGSizeMake(512, height)];
                            }
                            [self.selectPhotos removeObject:@"Q_Work_Add"];
                            [self.selectPhotos addObject:imageData];
                            [self updateSelectPhotos];
                            [self hideProgressHUD:YES];
                        });
                    }
                }
            }];
            [self sendAssetList:assetList ForPickerController:picker];
        }else{
            
        }
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - QIMMWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(QIMMWPhotoBrowser *)photoBrowser {
    if (self.selectPhotos.count >= 9) {
        return self.selectPhotos.count;
    }
    return self.selectPhotos.count - 1;
}

- (id <QIMMWPhoto>)photoBrowser:(QIMMWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    NSArray *tempImageArr = _selectPhotos;
    if (index > tempImageArr.count) {
        return nil;
    }
    
    NSData *imageData = [self.selectPhotos objectAtIndex:index];
    if (imageData.length > 0) {
        QIMMWPhoto *photo = [[QIMMWPhoto alloc] initWithImage:[UIImage qim_animatedImageWithAnimatedGIFData:imageData]];
        photo.photoData = imageData;
        return photo;
    }
    return nil;
}

- (void)photoBrowserDidFinishModalPresentation:(QIMMWPhotoBrowser *)photoBrowser {
    //界面消失
    [photoBrowser dismissViewControllerAnimated:YES completion:^{
        //tableView 回滚到上次浏览的位置
    }];
}

- (void)removeSelectPhoto:(QIMWorkMomentPushCell *)cell {
    NSInteger cellTag = cell.tag;
    [self.selectPhotos removeObjectAtIndex:cellTag];
    [self.selectPhotos removeObject:@"Q_Work_Add"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateSelectPhotos];
    });
}

- (void)dealloc {
    [[QIMWorkMomentUserIdentityManager sharedInstance] setIsAnonymous:NO];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousName:nil];
    [[QIMWorkMomentUserIdentityManager sharedInstance] setAnonymousPhoto:nil];
}

@end
